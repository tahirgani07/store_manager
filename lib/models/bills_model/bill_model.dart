import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store_manager/models/database_service.dart';
import 'package:store_manager/screens/utils/theme.dart';

class BillModel extends ChangeNotifier {
  List<bool> unitReadOnlyListinBillItem = [];

  bool getUnitReadOnlyinBillItem(int index) =>
      unitReadOnlyListinBillItem[index];

  addNewUnitReadOnlyinBillItem() {
    unitReadOnlyListinBillItem.add(false);
    notifyListeners();
  }

  changeUnitReadOnlyListinBillItem(int index, bool val) {
    unitReadOnlyListinBillItem[index] = val;
    notifyListeners();
  }

  removeUnitReadOnlyListinBillItem(int index) {
    unitReadOnlyListinBillItem.removeAt(index);
    notifyListeners();
  }

  List<Bill> _convertBillsSnapshots(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Bill(
        customerId: doc['customerId'],
        customerName: doc['customerName'],
        invoiceNo: doc['invoiceNo'],
        invoiceDate: doc['invoiceDate'],
        grossAmt: doc['grossAmt'],
        taxAmt: doc['taxAmt'],
        discountAmt: doc['discountAmt'],
        finalAmt: doc['finalAmt'],
      );
    }).toList();
  }

  Stream<List<Bill>> fetchBillsDetails(String uid) {
    DatabaseService databaseService = DatabaseService();
    return databaseService
        .getRefToBillsCollection(uid)
        .snapshots()
        .map(_convertBillsSnapshots);
  }

  List<List<BillItem>> _convertBillItemsSnapshots(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return [];
    }).toList();
  }

  Stream<List<List<BillItem>>> fetchBillItemsDetails(String uid) {
    DatabaseService databaseService = DatabaseService();
    return databaseService
        .getRefToBillsCollection(uid)
        .snapshots()
        .map(_convertBillItemsSnapshots);
  }

  Future addBill({
    @required String uid,
    String customerId,
    String customerName,
    List<BillItem> billItemsList,
    double grossAmt,
    double taxAmt,
    double discountAmt,
    double finalAmt,
  }) async {
    String creationDate = DateTime.now().millisecondsSinceEpoch.toString();
    DatabaseService databaseService = DatabaseService();
    await databaseService.getRefToBillsCollection(uid).doc(creationDate).set({
      'customerId': customerId,
      'customerName': customerName.capitalizeFirstofEach,
      'grossAmt': grossAmt,
      'taxAmt': taxAmt,
      'discountAmt': discountAmt,
      'finalAmt': finalAmt,
      'invoiceDate': creationDate,
    }).catchError((e) => print(e.toString()));

    final billItemsCollectionRef = databaseService
        .getRefToBillsCollection(uid)
        .doc(creationDate)
        .collection('items');

    for (BillItem i in billItemsList) {
      await billItemsCollectionRef.doc(i.itemId).set({
        'itemId': i.itemId,
        'qty': i.qty,
      }).catchError((e) => print(e.toString()));
    }
  }
}

class Bill {
  final String customerId;
  final String customerName;
  final String invoiceNo;
  final String invoiceDate;
  final List<BillItem> billItemsList;
  final double grossAmt;
  final double taxAmt;
  final double discountAmt;
  final double finalAmt;

  Bill({
    this.customerId,
    this.customerName,
    this.invoiceNo,
    this.invoiceDate,
    this.grossAmt,
    this.billItemsList,
    this.taxAmt,
    this.discountAmt,
    this.finalAmt,
  });
}

class BillItem {
  final String itemId;
  final double qty;

  BillItem({this.itemId, this.qty});
}
