import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/bills_model/bill_model.dart';
import 'package:store_manager/models/bills_model/offline_bill_items_model.dart';
import 'package:store_manager/models/customer_model/customer_model.dart';
import 'package:store_manager/models/stocks_model/stock_items_model.dart';
import 'package:store_manager/screens/utils/container_to_textfield.dart';
import 'package:store_manager/screens/utils/dropdown_textfields/bill_item_names_dropdown_textfield.dart';
import 'package:store_manager/screens/utils/dropdown_textfields/customer_dropdown_textfield.dart';
import 'package:store_manager/screens/utils/dropdown_textfields/unit_dropdown_textfield.dart';
import 'package:store_manager/screens/utils/loading_screen.dart';
import 'package:store_manager/screens/utils/navdrawer/toggle_nav_bar.dart';
import 'package:store_manager/screens/utils/pdf_functions.dart';
import 'package:store_manager/screens/utils/theme.dart';
import 'package:intl/intl.dart';

class AddBillScreen extends StatefulWidget {
  @override
  _AddBillScreenState createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  DateFormat formatter;
  int invoiceNo = 0;
  String uid;
  TextEditingController _custNameController;
  TextEditingController _invoiceNoController;
  TextEditingController _invoiceDateController;
  TextEditingController _totalAmtCont;
  List<Customer> customersList;
  List<Bill> billsList;
  List<BillItem> offlineBillItemsList;
  List<Items> itemsList;
  BillModel billModel;
  OfflineBillItemsModel _offlineBillItemsModel;
  ScrollController _scrollController;
  double _totalAmt = 0, _totalDiscount = 0, _totalTax = 0;
  ToggleNavBar toggleNavBar;

  @override
  void initState() {
    _custNameController = TextEditingController();
    _totalAmtCont = TextEditingController();
    formatter = DateFormat('dd/MM/yyyy');
    String currentDateString = formatter.format(DateTime.now());
    _invoiceDateController = TextEditingController(text: currentDateString);
    offlineBillItemsList = [];
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add Initial Items Row
      _addNewBillItemRow();
      toggleNavBar.updateShow(false);
    });
    super.initState();
  }

  @override
  void dispose() {
    _custNameController.dispose();
    _invoiceNoController.dispose();
    _invoiceDateController.dispose();
    _totalAmtCont.dispose();
    _offlineBillItemsModel.clearOfflineBillItemsList();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    billsList = Provider.of<List<Bill>>(context) ?? [];
    itemsList = Provider.of<List<Items>>(context) ?? [];
    _offlineBillItemsModel = Provider.of<OfflineBillItemsModel>(context);
    toggleNavBar = Provider.of<ToggleNavBar>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    billModel = Provider.of<BillModel>(context) ?? BillModel();

    invoiceNo = billsList.length + 1;
    _invoiceNoController = TextEditingController(text: invoiceNo.toString());
    uid = Provider.of<User>(context).uid;
    customersList = Provider.of<List<Customer>>(context);
    var currentScreenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        toggleNavBar.updateShow(true);
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          body: Column(
            children: [
              Material(
                elevation: 8.0,
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.symmetric(horizontal: BorderSide(width: 0.5)),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Billing",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(),
                          Row(
                            children: [
                              RaisedButton(
                                onPressed: () async {
                                  /* We have to take the invoice number first as after the bill is updated it increases and wron invoice number will be entered in the pdf.*/
                                  int number = invoiceNo;
                                  await _addBill();
                                  await PdfFunctions(
                                    billItemsList: _offlineBillItemsModel
                                        .getCompleteList(),
                                    invoiceDate: _invoiceDateController.text,
                                    invoiceNo: number,
                                    customerName: _custNameController.text,
                                    totalAmt: _totalAmt,
                                    amtReceived: 0.00,
                                    amtBalance: 0.00,
                                  ).writeAndSaveAndPrintPdf();
                                },
                                child: Text("Save and Print",
                                    style: TextStyle(fontSize: 18)),
                                color: Colors.blue,
                                textColor: Colors.white,
                              ),
                              SizedBox(width: 20.0),
                              RaisedButton(
                                onPressed: () async {
                                  /* We have to take the invoice number first as after the bill is updated it increases and wron invoice number will be entered in the pdf.*/
                                  int number = invoiceNo;
                                  await _addBill();
                                  await PdfFunctions(
                                    billItemsList: _offlineBillItemsModel
                                        .getCompleteList(),
                                    invoiceDate: _invoiceDateController.text,
                                    invoiceNo: number,
                                    customerName: _custNameController.text,
                                    totalAmt: _totalAmt,
                                    amtReceived: 0.00,
                                    amtBalance: 0.00,
                                  ).writeAndSavePdf();
                                },
                                child: Text("Save",
                                    style: TextStyle(fontSize: 18)),
                                color: Colors.blue,
                                textColor: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 200,
                padding: EdgeInsets.all(40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: (currentScreenSize.width >= desktopWidth) ? 1 : 2,
                      child: Container(
                        //color: Colors.green,
                        alignment: Alignment.topLeft,
                        child: CustomerDropDownTextField(
                          controller: _custNameController,
                          labelText: "Customer",
                          customersList: customersList,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Container(
                        width: 300,
                        //color: Colors.red,
                        alignment: Alignment.topRight,
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Inovice Number"),
                                SizedBox(height: 20.0),
                                Text("Invoice Date"),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    height: 25,
                                    width: 150,
                                    // Invoice Number TextField.
                                    child: TextField(
                                      controller: _invoiceNoController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(0))),
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(8.0),
                                      ),
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Container(
                                    height: 25,
                                    width: 150,
                                    // Invoice Date TextField.
                                    child: TextField(
                                      controller: _invoiceDateController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(0)),
                                        ),
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(8.0),
                                      ),
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _getItemsList(),
              _getFooter(),
            ],
          ),
        ),
      ),
    );
  }

  _getItemsList() {
    return Expanded(
      child: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: [
            itemListHeader(),
            Expanded(
              child: CupertinoScrollbar(
                thickness: 5,
                isAlwaysShown: true,
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      _offlineBillItemsModel.getLengthOfOfflineBillItemsList(),
                  itemBuilder: (context, counter) {
                    return _getItemsRow(
                      counter: counter,
                      color:
                          (counter % 2 == 0) ? Color(0xffF2F4F8) : Colors.white,
                      lastRow: counter ==
                          _offlineBillItemsModel
                                  .getLengthOfOfflineBillItemsList() -
                              1,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _updateAllTotals() {
    _totalAmt = 0;
    _totalDiscount = 0;
    _totalTax = 0;
    for (int i = 0;
        i < _offlineBillItemsModel.getLengthOfOfflineBillItemsList();
        i++) {
      BillItem current = _offlineBillItemsModel.getOfflineBillItem(i);
      _totalAmt += current.amt;
      _totalTax += current.tax;
      _totalDiscount += current.discount;
    }
  }

  _getFooter() {
    _updateAllTotals();
    _totalAmtCont.text = _totalAmt.toStringAsFixed(2);
    return Material(
      elevation: 8.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.symmetric(
            horizontal: BorderSide(width: 0.5),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 3,
                  child: _addItemRaisedButton(),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    children: [
                      Text("TO PAY"),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          child: TextField(
                            readOnly: true,
                            controller: _totalAmtCont,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.black,
                              contentPadding: EdgeInsets.all(5.0),
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 50),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _addNewBillItemRow() {
    setState(() {
      _offlineBillItemsModel.addToOfflineBillItemsList(BillItem());
      billModel.addNewUnitReadOnlyinBillItem();
    });
  }

  Widget _getItemsRow({
    int counter,
    Color color,
    bool lastRow: false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: color,
          child: Row(
            children: [
              getFlexContainer(
                "${counter + 1}",
                1,
                alignment: Alignment.center,
              ),
              Flexible(
                flex: 15,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.grey),
                    ),
                  ),
                  padding: EdgeInsets.all(5.0),
                  child: BillItemNameDropDownTextField(
                    itemsList: itemsList,
                    counter: counter,
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: ContainerToTextField(
                  counter: counter,
                  leftBorder: true,
                  numeric: true,
                  type: ContainerToTextFieldType.qty,
                ),
              ),
              Flexible(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.grey)),
                  ),
                  child: UnitDropDownTextField(
                    counter: counter,
                    readOnly: billModel.getUnitReadOnlyinBillItem(counter),
                  ),
                ),
              ),
              Flexible(
                flex: 4,
                child: ContainerToTextField(
                  counter: counter,
                  leftBorder: true,
                  numeric: true,
                  type: ContainerToTextFieldType.pricePerUnit,
                ),
              ),
              Flexible(
                flex: 5,
                child: ContainerToTextField(
                  counter: counter,
                  leftBorder: true,
                  numeric: true,
                  type: ContainerToTextFieldType.discount,
                ),
              ),
              Flexible(
                flex: 6,
                child: ContainerToTextField(
                  counter: counter,
                  leftBorder: true,
                  numeric: true,
                  type: ContainerToTextFieldType.tax,
                ),
              ),
              Flexible(
                flex: 3,
                child: ContainerToTextField(
                  counter: counter,
                  leftBorder: true,
                  rightBorder: true,
                  numeric: true,
                  readOnly: true,
                  type: ContainerToTextFieldType.amt,
                ),
              ),
              Flexible(
                flex: 1,
                child: IconButton(
                  icon: Icon(Icons.delete),
                  iconSize: 18,
                  splashRadius: 1,
                  onPressed: () {
                    setState(() {
                      _offlineBillItemsModel
                          .removeFromOfflineBillItemsList(counter);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        !lastRow
            ? SizedBox()
            : Container(
                margin: EdgeInsets.only(left: 50),
                child: _addItemFlatButton(),
              )
      ],
    );
  }

  Widget _addItemRaisedButton() {
    return RaisedButton(
      child: Text("ADD A ROW"),
      color: Colors.blue,
      textColor: Colors.white,
      onPressed: () {
        _addNewBillItemRow();
      },
    );
  }

  Widget _addItemFlatButton() {
    return FlatButton(
      child: Text("ADD A ROW"),
      color: Colors.blue,
      textColor: Colors.white,
      onPressed: () {
        _addNewBillItemRow();
      },
    );
  }

  Widget itemListHeader() {
    return Column(
      children: [
        Container(
          height: 37,
          color: Colors.white,
          child: Row(
            children: [
              getFlexContainer(
                "#",
                1,
                alignment: Alignment.center,
              ),
              getFlexContainer(
                "ITEM",
                15,
              ),
              getFlexContainer(
                "QTY",
                3,
              ),
              getFlexContainer(
                "UNIT",
                3,
              ),
              getFlexContainer(
                "PRICE/UNIT",
                4,
              ),
              getFlexContainer(
                "DISCOUNT",
                5,
                alignment: Alignment.center,
              ),
              getFlexContainer(
                "TAX",
                6,
                alignment: Alignment.center,
              ),
              getFlexContainer(
                "AMOUNT",
                3,
              ),
              getFlexContainer("", 1),
            ],
          ),
        ),
      ],
    );
  }

  _addBill() async {
    _pleaseWaitAlertDialog();

    double finalAmt = _totalAmt - _totalDiscount + _totalTax;
    double amtPaid = 0;

    List<BillItem> offlineBillItemsList =
        _offlineBillItemsModel.getCompleteList();
    List<BillItem> billItemsList = [];

    List<Items> stockItemsToUpdate = [];
    List<double> stockItemsQtyToUpdate = [];

    offlineBillItemsList.forEach((offlineBill) {
      // Add to billItems List to pass to the addBill method.
      billItemsList.add(
        BillItem(
          name: offlineBill.name,
          qty: offlineBill.qty,
          unit: offlineBill.unit,
          pricePerUnit: offlineBill.pricePerUnit,
          discount: offlineBill.discount,
          tax: offlineBill.tax,
          amt: offlineBill.amt,
        ),
      );

      // Check if the billItem is in the stock so you can update it.
      for (Items i in itemsList) {
        if (i.name.toLowerCase() == offlineBill.name.toLowerCase()) {
          stockItemsToUpdate.add(i);
          stockItemsQtyToUpdate.add(offlineBill.qty);
        }
      }
    });

    bool successfull = await billModel.addBill(
      uid: uid,
      invoiceNo: invoiceNo.toString(),
      customerId: "",
      customerName: _custNameController.text,
      grossAmt: _totalAmt,
      taxAmt: _totalTax,
      discountAmt: _totalDiscount,
      finalAmt: finalAmt,
      amtPaid: amtPaid,
      amtBalance: finalAmt - amtPaid,
      billItemsList: billItemsList,
      stockItemsToUpdate: stockItemsToUpdate,
      stockItemsQtyToUpdate: stockItemsQtyToUpdate,
    );

    if (successfull) {
      Navigator.pop(context);
    } else {
      Flushbar(
        title: "Something Went Wrong",
        message: "Could Not Add The Bill. Please Try Again.",
        duration: Duration(seconds: 3),
      )..show(context);
    }

    /// show NavBar
    toggleNavBar.updateShow(true);
    Navigator.pop(context);
  }

  Future<void> _pleaseWaitAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Preparing Bill"),
          content: SingleChildScrollView(
            child: LoadingScreen(
              message: "Please Wait...",
            ),
          ),
        );
      },
    );
  }
}
