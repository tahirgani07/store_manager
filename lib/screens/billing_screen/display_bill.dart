import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/database_service.dart';

class DisplayBill extends StatefulWidget {
  final String billId;

  const DisplayBill({Key key, this.billId}) : super(key: key);

  @override
  _DisplayBillState createState() => _DisplayBillState();
}

class _DisplayBillState extends State<DisplayBill> {
  String uid;
  DatabaseService databaseService = DatabaseService();
  Stream billItemsCollectionStream;

  @override
  Widget build(BuildContext context) {
    uid = Provider.of<User>(context).uid ?? '';
    billItemsCollectionStream = databaseService
        .getRefToBillsCollection(uid)
        .doc(widget.billId)
        .collection("billItems")
        .snapshots();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: billItemsCollectionStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Text("Something Went Wrong!");
          if (snapshot.connectionState == ConnectionState.waiting)
            return Text("Loading...");
          return ListView(
            children: snapshot.data.docs.map((doc) {
              return ListTile(
                title: Text(doc["name"]),
                subtitle: Text(doc["qty"].toString()),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
