import 'package:flutter/material.dart';
import 'package:store_manager/models/bills_model/bill_model.dart';

class DisplayBill extends StatefulWidget {
  final List<BillItem> billItemsList;

  const DisplayBill({Key key, this.billItemsList}) : super(key: key);

  @override
  _DisplayBillState createState() => _DisplayBillState();
}

class _DisplayBillState extends State<DisplayBill> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: widget.billItemsList.map((billItem) {
          return ListTile(
            title: Text(billItem.name),
            subtitle: Text(billItem.qty.toString()),
          );
        }).toList(),
      ),
    );
  }
}
