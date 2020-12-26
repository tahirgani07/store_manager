import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/locator.dart';
import 'package:store_manager/models/bills_model/bill_model.dart';
import 'package:store_manager/models/database_service.dart';
import 'package:store_manager/models/navigation_model.dart';
import 'package:store_manager/routing/route_names.dart';
import 'package:store_manager/screens/billing_screen/display_bill.dart';
import 'package:store_manager/screens/utils/CustomTextStyle.dart';
import 'package:store_manager/screens/utils/marquee_widget.dart';
import 'package:store_manager/screens/utils/navdrawer/toggle_nav_bar.dart';
import 'package:store_manager/screens/utils/pdf_functions.dart';
import 'package:store_manager/screens/utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:store_manager/services/navigation_service.dart';

class BillMainScreen extends StatefulWidget {
  @override
  _BillMainScreenState createState() => _BillMainScreenState();
}

class _BillMainScreenState extends State<BillMainScreen> {
  String uid;
  List<Bill> _fullBillsList = [];
  List<Bill> _datedBillsList = [];
  List<Bill> _searchList = [];
  List<String> filterTransList = [
    "All Sale Invoices",
    "This Month",
    "This Year",
    "Custom",
  ];
  String filterTransDropdownVal;

  TextEditingController startDateController, endDateController;
  DateFormat formatter = DateFormat('dd/MM/yyyy');

  TextEditingController searchController;
  bool ranOnce = false;
  double totAmtPaid;
  double totAmtBalance;
  double totAmt;

  NavigationModel navigationModel;
  ToggleNavBar toggleNavBar;

  @override
  void initState() {
    filterTransDropdownVal = filterTransList[0];
    startDateController = TextEditingController();
    endDateController = TextEditingController();
    searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigationModel = Provider.of<NavigationModel>(context, listen: false);
      int index = 0;
      navigationModel.updateCurrentScreenIndex(index);

      navigationModel.addToStack(index);

      /// show NavBar
      toggleNavBar.updateShow(true);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _datedBillsList = Provider.of<List<Bill>>(context, listen: false) ?? [];
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    uid = Provider.of<User>(context).uid;
    _fullBillsList = Provider.of<List<Bill>>(context) ?? [];
    toggleNavBar = Provider.of<ToggleNavBar>(context);

    // Set the Paid-Unpaid Containers
    totAmtPaid = 0;
    totAmtBalance = 0;
    totAmt = 0;
    _datedBillsList.forEach((bill) {
      totAmtPaid += bill.amtPaid;
      totAmtBalance += bill.amtBalance;
    });
    totAmt = totAmtPaid + totAmtBalance;

    return WillPopScope(
      onWillPop: () async {
        int lastIndex = 0;
        if (navigationModel.indexStack.length > 1) {
          lastIndex = navigationModel.popFromStack();
          navigationModel.updateCurrentScreenIndex(lastIndex);
          return true;
        } else {
          navigationModel.resetIndexStack();
          if (navigationModel.currentScreenIndex != lastIndex) {
            navigationModel.updateCurrentScreenIndex(lastIndex);
            locator<NavigationService>().navigateTo(BillTransRoute);
          }
          return false;
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          body: Container(
            padding: EdgeInsets.all(10.0),
            color: bgColor,
            child: Column(
              children: [
                Material(
                  color: Colors.white,
                  elevation: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              child: DropdownButton(
                                  underline: SizedBox(),
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  value: filterTransDropdownVal,
                                  items: filterTransList.map((val) {
                                    return DropdownMenuItem(
                                      value: val,
                                      child: Text(
                                        val,
                                        style: CustomTextStyle.blue_bold_big,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String newVal) {
                                    changeDateTextfieldWrtDropdown(newVal);
                                    _onDateTextFieldChanged();
                                    setState(() {
                                      filterTransDropdownVal = newVal;
                                    });
                                  }),
                            ),
                            SizedBox(width: 10),
                            Container(
                              height: 32,
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(4),
                              child: Text("Between",
                                  style: TextStyle(color: Colors.white)),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    bottomLeft: Radius.circular(5)),
                              ),
                            ),
                            Container(
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _customDatePickerTextField(
                                      "START", startDateController),
                                  Text("To", style: TextStyle(fontSize: 12)),
                                  _customDatePickerTextField(
                                      "END", endDateController),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            RaisedButton(
                              color: Colors.redAccent,
                              textColor: Colors.white,
                              child: Text("Clear"),
                              onPressed: () {
                                startDateController.clear();
                                endDateController.clear();
                                filterTransDropdownVal = filterTransList[0];
                                _onDateTextFieldChanged();
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            customContainer(
                              title: "Paid",
                              amt: totAmtPaid.toStringAsFixed(2),
                              color: Color(0xffB9F3E7),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text("+", style: CustomTextStyle.bigIcons),
                            ),
                            customContainer(
                              title: "Unpaid",
                              amt: totAmtBalance.toStringAsFixed(2),
                              color: Color(0xffCFE6FE),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text("=", style: CustomTextStyle.bigIcons),
                            ),
                            customContainer(
                              title: "Total",
                              amt: totAmt.toStringAsFixed(2),
                              color: Color(0xffF8C889),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                _getBillTrans(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getBillTrans() {
    return Expanded(
      child: Material(
        color: Colors.white,
        elevation: 8.0,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("TRANSACTIONS", style: CustomTextStyle.blue_bold_med),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        width: 300,
                        child: _getSearchBar(_onSearchTextChanged),
                      ),
                      SizedBox(width: 50),
                      _addBillButton(),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _fullBillsList.length == 0
                  ? Center(child: Text("EMPTY"))
                  : Column(
                      children: [
                        _getHeadingRow(),
                        Expanded(
                          child: (searchController.text.isEmpty)
                              ? _getList(_datedBillsList)
                              : _getList(_searchList),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _addBillButton() {
    return RaisedButton(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(30.0),
      ),
      onPressed: () => Navigator.pushNamed(context, AddBillRoute),
      color: Colors.blue,
      textColor: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            child: Icon(Icons.add, size: 18),
          ),
          SizedBox(width: 8),
          Text("Add Bill"),
        ],
      ),
    );
  }

  _getHeadingRow() {
    return Row(
      children: [
        _getFlexContainer("DATE", 2, header: true),
        _getFlexContainer(
          "INVOICE NO",
          2,
          header: true,
          alignment: Alignment.center,
        ),
        _getFlexContainer("CUSTOMER NAME", 5, header: true),
        _getFlexContainer("PAYMENT TYPE", 2, header: true),
        _getFlexContainer(
          "AMOUNT",
          3,
          header: true,
          alignment: Alignment.center,
        ),
        _getFlexContainer(
          "BALANCE DUE",
          2,
          header: true,
          alignment: Alignment.center,
        ),
        _getFlexContainer("", 2, header: true),
      ],
    );
  }

  _getList(List<Bill> reqList) {
    return ListView.builder(
      itemCount: reqList.length,
      itemBuilder: (context, counter) {
        return InkWell(
          onTap: () async {
            List<BillItem> reqBillItemsList =
                await _getBillItemsList(reqList[counter].invoiceDate);

            Navigator.of(context).push(MaterialPageRoute(
              settings: RouteSettings(name: '/display_bill'),
              builder: (context) => DisplayBill(
                billItemsList: reqBillItemsList,
              ),
            ));
          },
          child: Row(
            children: [
              _getFlexContainer(
                formatter.format(DateTime.fromMillisecondsSinceEpoch(
                    int.parse(reqList[counter].invoiceDate))),
                2,
              ),
              _getFlexContainer(
                reqList[counter].invoiceNo,
                2,
                alignment: Alignment.centerRight,
              ),
              _getFlexContainer(reqList[counter].customerName, 5),
              _getFlexContainer("paymentType", 2),
              _getFlexContainer(
                "₹ ${reqList[counter].finalAmt.toStringAsFixed(2)}",
                3,
                alignment: Alignment.centerRight,
              ),
              _getFlexContainer(
                "₹ ${reqList[counter].amtBalance.toStringAsFixed(2)}",
                2,
                alignment: Alignment.centerRight,
              ),
              _downloadShareBillButtons(flex: 2, bill: reqList[counter]),
            ],
          ),
        );
      },
    );
  }

  _downloadShareBillButtons({@required int flex, @required Bill bill}) {
    return Flexible(
      flex: flex,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Download Pdf Button
            IconButton(
              splashRadius: 20,
              onPressed: () async {
                PdfFunctions pdfFunctions = await _getPdfFunctionFromBill(bill);
                pdfFunctions.writeAndSavePdf();
              },
              icon: Icon(
                Icons.download_outlined,
                color: Colors.grey[600],
              ),
            ),
            // Share Pdf button
            // IconButton(
            //   splashRadius: 20,
            //   onPressed: () async {},
            //   icon: Icon(
            //     Icons.share_outlined,
            //     color: Colors.grey[600],
            //   ),
            // ),
            // Print Pdf Button
            IconButton(
              splashRadius: 20,
              onPressed: () async {
                PdfFunctions pdfFunctions = await _getPdfFunctionFromBill(bill);
                pdfFunctions.writeAndPrintPdf();
              },
              icon: Icon(
                Icons.print_outlined,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<PdfFunctions> _getPdfFunctionFromBill(Bill bill) async {
    List<BillItem> reqBillItemsList = await _getBillItemsList(bill.invoiceDate);

    return PdfFunctions(
      billItemsList: reqBillItemsList ?? [],
      invoiceNo: int.parse(bill.invoiceNo),
      invoiceDate: formatter.format(
          DateTime.fromMillisecondsSinceEpoch(int.parse(bill.invoiceDate))),
      customerName: bill.customerName,
      totalAmt: bill.finalAmt,
      amtBalance: bill.amtBalance,
      amtReceived: bill.amtPaid,
    );
  }

  Future<List<BillItem>> _getBillItemsList(String invoiceDate) async {
    DatabaseService databaseService = DatabaseService();
    QuerySnapshot snapshotOfBillItems = await databaseService
        .getRefToBillsCollection(uid)
        .doc(invoiceDate)
        .collection("billItems")
        .get();

    List<BillItem> reqBillItemsList =
        _convertBillItemsSnapshot(snapshotOfBillItems);
    return reqBillItemsList;
  }

  List<BillItem> _convertBillItemsSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return BillItem(
        name: doc["name"],
        qty: doc["qty"],
        unit: doc["unit"],
        pricePerUnit: doc["pricePerUnit"],
        discount: doc["discount"],
        tax: doc["tax"],
        amt: doc["amt"],
      );
    }).toList();
  }

  _getFlexContainer(
    String title,
    int flex, {
    Alignment alignment,
    bool header = false,
  }) {
    return Flexible(
      flex: flex,
      child: Container(
        height: 40,
        alignment: alignment ?? Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          border: Border(
              bottom: (header)
                  ? BorderSide(color: Colors.grey, width: 0.5)
                  : BorderSide.none,
              right: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: MarqueeWidget(
          child: Text(
            title,
            style: (header)
                ? CustomTextStyle.grey_bold_small
                : TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }

  _onSearchTextChanged(String text) {
    _searchList.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    text = text.toLowerCase();
    _datedBillsList.forEach((bill) {
      String date = formatter.format(
          DateTime.fromMillisecondsSinceEpoch(int.parse(bill.invoiceDate)));
      if (bill.customerName.toLowerCase().contains(text) ||
          bill.invoiceNo.toLowerCase().contains(text) ||
          date.contains(text) ||
          // bill.finalAmt.toString().toLowerCase().contains(text) ||
          // bill.discountAmt.toString().toLowerCase().contains(text) ||
          // bill.taxAmt.toString().toLowerCase().contains(text) ||
          bill.grossAmt.toString().toLowerCase().contains(text)) {
        _searchList.add(bill);
      }
      setState(() {});
    });
  }

  void _onDateTextFieldChanged() {
    _datedBillsList = [];
    searchController.clear();
    if (startDateController.text.isEmpty && endDateController.text.isEmpty) {
      _datedBillsList.addAll(_fullBillsList);
      setState(() {});
      return;
    }
    int currentDate = DateTime.now().millisecondsSinceEpoch;
    int startDate = (startDateController.text.isEmpty)
        ? 1
        : _getIntDateFromFormattedStringDate(startDateController.text);
    int endDate = (endDateController.text.isEmpty)
        ? currentDate
        : _getIntDateFromFormattedStringDate(endDateController.text,
            endDate: true);
    _fullBillsList.forEach((bill) {
      if (int.parse(bill.invoiceDate) >= startDate &&
          int.parse(bill.invoiceDate) <= endDate) {
        _datedBillsList.add(bill);
      }
      setState(() {});
    });
  }

  int _getIntDateFromFormattedStringDate(String date, {bool endDate = false}) {
    int day = int.parse(date.substring(0, 2));
    int month = int.parse(date.substring(3, 5));
    int year = int.parse(date.substring(6));
    if (!endDate) return DateTime(year, month, day).millisecondsSinceEpoch;
    // Since endDate should be till End of the day.
    return DateTime(year, month, day, 24, 59, 59, 59, 59)
        .millisecondsSinceEpoch;
  }

  Widget customContainer(
      {@required String title, String amt = "0.00", Color color}) {
    return Container(
      width: 200,
      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MarqueeWidget(
              child: Text(title, style: CustomTextStyle.blue_reg_med)),
          MarqueeWidget(
              child: Text("₹ $amt", style: CustomTextStyle.blue_bold_big)),
        ],
      ),
    );
  }

  Widget _customDatePickerTextField(
      String type, TextEditingController controller) {
    return Container(
      alignment: Alignment.center,
      width: 120,
      child: TextField(
          controller: controller,
          readOnly: true,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "dd/mm/yyy",
            isDense: true,
            alignLabelWithHint: true,
          ),
          onTap: () async {
            DateTime date = await _getDateFromPopup(type, controller);
            controller.text =
                date != null ? formatter.format(date) : controller.text;
            _onDateTextFieldChanged();
            setState(() {
              filterTransDropdownVal = "Custom";
            });
          }),
    );
  }

  Future<DateTime> _getDateFromPopup(
      String type, TextEditingController controller) {
    return showDatePicker(
      context: context,
      helpText: "SELECT ${type.toUpperCase()} DATE",
      initialDate: (controller.text.isNotEmpty)
          ? DateTime.fromMillisecondsSinceEpoch(
              _getIntDateFromFormattedStringDate(controller.text))
          : DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
  }

  changeDateTextfieldWrtDropdown(String val) async {
    DateTime date = DateTime.now();
    switch (val) {
      case "This Month":
        startDateController.text = "01/${date.month}/${date.year}";
        endDateController.text = formatter.format(date);
        break;
      case "This Year":
        startDateController.text = "01/01/${date.year}";
        endDateController.text = formatter.format(date);
        break;
      case "Custom":
        DateTime date = await _getDateFromPopup("START", startDateController);
        startDateController.text =
            date != null ? formatter.format(date) : startDateController.text;
        _onDateTextFieldChanged();
        break;
      default:
        startDateController.clear();
        endDateController.clear();
    }
  }

  Widget _getSearchBar(Function onSearchTextChanged) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          // hintText: 'Search',
          border: InputBorder.none,
          isDense: true,
          prefixIcon: Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            child: Icon(Icons.search, size: 20),
          ),
          prefixIconConstraints: BoxConstraints(maxWidth: 30, maxHeight: 30),
        ),
        style: TextStyle(
          fontSize: 14,
        ),
        onChanged: onSearchTextChanged,
      ),
    );
  }
}
