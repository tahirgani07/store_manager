import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:store_manager/models/bills_model/bill_model.dart';
import 'package:store_manager/models/database_service.dart';
import 'package:store_manager/screens/utils/CustomTextStyle.dart';
import 'package:store_manager/screens/utils/marquee_widget.dart';
import 'package:intl/intl.dart';
import 'package:store_manager/screens/utils/pdf_functions.dart';

class DisplayBill extends StatefulWidget {
  final Bill bill;

  DisplayBill({this.bill});

  @override
  _DisplayBillState createState() => _DisplayBillState();
}

class _DisplayBillState extends State<DisplayBill> {
  final DateFormat formatter = DateFormat("dd/MM/yyyy");
  DocumentSnapshot personalDoc;
  String uid = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      DatabaseService databaseService = DatabaseService();
      personalDoc = await databaseService.fetchPersonalDetail(uid);
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    uid = Provider.of<User>(context).uid;
    return Scaffold(
      appBar: AppBar(
        title: Text("Display Bill"),
        actions: [
          Container(
            width: 100,
            child: IconButton(
              onPressed: () async => PdfFunctions(
                paymentType: widget.bill.paymentType,
                companyName: personalDoc["companyName"],
                companyPhoneNo: personalDoc["phoneNo"],
                billItemsList: widget.bill.billItemsList,
                invoiceDate: widget.bill.invoiceDate,
                invoiceNo: int.parse(widget.bill.invoiceNo),
                customerName: widget.bill.customerName,
                totalAmt: widget.bill.finalAmt,
                amtBalance: widget.bill.amtPaid,
                amtReceived: widget.bill.amtBalance,
              ).writeAndPrintPdf(),
              icon: CircleAvatar(child: Icon(Icons.download_rounded)),
              color: Colors.white,
              splashRadius: 25,
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Customer Name:",
                      style: CustomTextStyle.bold_med,
                    ),
                    Text(
                      "${widget.bill.customerName}",
                      style: CustomTextStyle.blue_bold_med,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Invoice No: ",
                          style: CustomTextStyle.bold_med,
                        ),
                        Text(
                          "${widget.bill.invoiceNo}",
                          style: CustomTextStyle.blue_bold_med,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Invoice Date: ",
                          style: CustomTextStyle.bold_med,
                        ),
                        Text(
                          "${formatter.format(DateTime.fromMillisecondsSinceEpoch(int.parse(widget.bill.invoiceDate)))},",
                          style: CustomTextStyle.blue_bold_med,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            itemListHeader(),
            Expanded(
              child: ListView.builder(
                itemCount: widget.bill.billItemsList.length,
                itemBuilder: (context, counter) {
                  return _getItemsRow(
                    counter: counter,
                    billItem: widget.bill.billItemsList[counter],
                  );
                },
              ),
            ),
            _getFooter(),
          ],
        ),
      ),
    );
  }

  Widget _getFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        Row(
          children: [
            Text("Total: ", style: TextStyle(fontSize: 15)),
            SizedBox(width: 10),
            Text(
              "₹ ${widget.bill.finalAmt.toStringAsFixed(2)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: CustomColors.darkBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget itemListHeader() {
    return ResponsiveBuilder(builder: (context, sizingInfo) {
      return Container(
        height: 37,
        color: Colors.white,
        child: Row(
          children: [
            _getFlexContainer("#", 1,
                alignment: Alignment.center, header: true),
            _getFlexContainer("ITEM", (_getFlexVal(13, sizingInfo) + 2),
                color: Color(0xffF2F3F4), header: true),
            _getFlexContainer("QTY", _getFlexVal(3, sizingInfo),
                alignment: Alignment.center, header: true),
            _getFlexContainer("UNIT", _getFlexVal(3, sizingInfo),
                color: Color(0xffF2F3F4), header: true),
            _getFlexContainer("PRICE/UNIT", _getFlexVal(4, sizingInfo),
                alignment: Alignment.center, header: true),
            // _getFlexContainer("DISCOUNT", 5,
            //     alignment: Alignment.center),
            // _getFlexContainer("TAX", 6,
            //     alignment: Alignment.center),
            _getFlexContainer(
              sizingInfo.isDesktop ? "AMOUNT" : "AMT",
              _getFlexVal(3, sizingInfo),
              alignment: Alignment.center,
              color: Color(0xffF2F3F4),
              header: true,
            ),
          ],
        ),
      );
    });
  }

  _getFlexVal(int flex, sizingInfo) {
    if (sizingInfo.isDesktop) return flex;
    return 2;
  }

  Widget _getItemsRow({
    int counter,
    Color color,
    BillItem billItem,
  }) {
    return ResponsiveBuilder(builder: (context, sizingInfo) {
      return Container(
        color: color,
        child: Row(
          children: [
            _getFlexContainer("${counter + 1}", 1, alignment: Alignment.center),
            _getFlexContainer(
                "${billItem.name}", (_getFlexVal(13, sizingInfo) + 2),
                color: Color(0xffF2F3F4)),
            _getFlexContainer(
              "${billItem.qty}",
              _getFlexVal(3, sizingInfo),
              alignment: Alignment.centerRight,
            ),
            _getFlexContainer("${billItem.unit}", _getFlexVal(3, sizingInfo),
                color: Color(0xffF2F3F4)),
            _getFlexContainer(
                "${billItem.pricePerUnit}", _getFlexVal(4, sizingInfo),
                alignment: Alignment.centerRight),
            _getFlexContainer("${billItem.amt}", _getFlexVal(3, sizingInfo),
                alignment: Alignment.centerRight, color: Color(0xffF2F3F4)),
          ],
        ),
      );
    });
  }

  _getFlexContainer(
    String title,
    int flex, {
    Color color,
    Alignment alignment,
    bool header = false,
  }) {
    return Flexible(
      flex: flex,
      child: Container(
        height: 40,
        alignment: alignment ?? Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          color: color,
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        child: MarqueeWidget(
          child: Text(
            title,
            style: (header)
                ? CustomTextStyle.grey_bold_small
                : TextStyle(
                    fontSize: 13,
                    color: CustomColors.darkBlue,
                    fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
