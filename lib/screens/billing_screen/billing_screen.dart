import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:store_manager/screens/utils/theme.dart';
import 'package:intl/intl.dart';

class BillingScreen extends StatefulWidget {
  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
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

  @override
  void initState() {
    _custNameController = TextEditingController();
    _totalAmtCont = TextEditingController();
    formatter = DateFormat('dd/MM/yyyy');
    String currentDateString = formatter.format(DateTime.now());
    _invoiceDateController = TextEditingController(text: currentDateString);
    offlineBillItemsList = [];
    super.initState();
  }

  @override
  void dispose() {
    _custNameController.dispose();
    _invoiceNoController.dispose();
    _invoiceDateController.dispose();
    _totalAmtCont.dispose();
    _offlineBillItemsModel.clearOfflineBillItemsList();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    billsList = Provider.of<List<Bill>>(context) ?? [];
    itemsList = Provider.of<List<Items>>(context) ?? [];
    _offlineBillItemsModel = Provider.of<OfflineBillItemsModel>(context);
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

    return GestureDetector(
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
                  border: Border.symmetric(horizontal: BorderSide(width: 0.5)),
                ),
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Billing",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Icon(Icons.calculate_outlined),
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
    );
  }

  _getItemsList() {
    return Expanded(
      child: Container(
        color: Colors.grey.shade200,
        child: Column(
          children: [
            RaisedButton(
              child: Text("ADD ITEM"),
              onPressed: () {
                _addNewBillItemRow();
              },
            ),
            itemListHeader(),
            Expanded(
              child: ListView.builder(
                itemCount:
                    _offlineBillItemsModel.getLengthOfOfflineBillItemsList(),
                itemBuilder: (context, counter) {
                  return _getItemsRow(
                    counter: counter,
                    color:
                        (counter % 2 == 0) ? Color(0xffF2F4F8) : Colors.white,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getFooter() {
    double totalAmt = 0;
    for (int i = 0;
        i < _offlineBillItemsModel.getLengthOfOfflineBillItemsList();
        i++) {
      totalAmt += _offlineBillItemsModel.getOfflineBillItem(i).amt;
    }
    _totalAmtCont.text = totalAmt.toStringAsFixed(2);
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
              children: [
                Flexible(flex: 3, child: Container()),
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
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Row(
                  children: [
                    RaisedButton(
                      onPressed: () {},
                      child: Text("Share", style: TextStyle(fontSize: 18)),
                      color: Colors.blue,
                      textColor: Colors.white,
                    ),
                    SizedBox(width: 20.0),
                    RaisedButton(
                      onPressed: () {},
                      child: Text("Print", style: TextStyle(fontSize: 18)),
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
    );
  }

  _addNewBillItemRow() {
    setState(() {
      _offlineBillItemsModel.addToOfflineBillItemsList(OfflineBillItem());
      billModel.addNewUnitReadOnlyinBillItem();
    });
  }

  _updateTotalAmtTextField() {
    double totalAmt = 0;
    for (int i = 0;
        i < _offlineBillItemsModel.getLengthOfOfflineBillItemsList();
        i++) {
      double amt = _offlineBillItemsModel.getOfflineBillItem(i).amt;
      totalAmt += amt;
    }

    setState(() {
      _totalAmtCont.text = totalAmt.toStringAsFixed(2);
    });
  }

  Widget _getItemsRow({
    int counter,
    Color color,
  }) {
    return Container(
      color: color,
      child: Row(
        children: [
          getFlexContainer("${counter + 1}", 1,
              alignment: Alignment.center, border: false),
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
                  _updateTotalAmtTextField();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _customeTextField(
    TextEditingController controller, {
    bool leftBorder = false,
    bool rightBorder = false,
    bool numeric = false,
    bool readOnly: false,
    FocusNode focusNode,
    String value,
  }) {
    return Container(
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        border: Border(
          left: (leftBorder) ? BorderSide(color: Colors.grey) : BorderSide.none,
          right:
              (rightBorder) ? BorderSide(color: Colors.grey) : BorderSide.none,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        textAlign: (numeric) ? TextAlign.end : TextAlign.start,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        inputFormatters: [
          (numeric) ? DecimalTextInputFormatter(decimalRange: 4) : null,
        ],
        textInputAction: TextInputAction.next,
      ),
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
              getFlexContainer("#", 1,
                  alignment: Alignment.center, textBold: true),
              getFlexContainer("ITEM", 15, textBold: true),
              getFlexContainer("QTY", 3, textBold: true),
              getFlexContainer("UNIT", 3, textBold: true),
              getFlexContainer("PRICE/UNIT", 4, textBold: true),
              getFlexContainer("DISCOUNT", 5,
                  alignment: Alignment.center, textBold: true),
              getFlexContainer("TAX", 6,
                  alignment: Alignment.center, textBold: true),
              getFlexContainer("AMOUNT", 3, textBold: true),
              getFlexContainer("", 1),
            ],
          ),
        ),
      ],
    );
  }
}
