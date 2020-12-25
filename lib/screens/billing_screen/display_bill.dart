import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/bills_model/bill_model.dart';
import 'package:store_manager/models/database_service.dart';

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
