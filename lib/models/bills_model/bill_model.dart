import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store_manager/models/database_service.dart';
import 'package:store_manager/models/stocks_model/stock_items_model.dart';
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
        amtPaid: doc['amtPaid'],
        amtBalance: doc['amtBalance'],
      );
    }).toList();
  }

  Stream<List<Bill>> fetchBillsDetails(String uid) {
    DatabaseService databaseService = DatabaseService();
    return databaseService
        .getRefToBillsCollection(uid)
        .orderBy('invoiceNo', descending: true)
        .snapshots()
        .map(_convertBillsSnapshots);
  }

  Future<bool> addBill({
    @required String uid,
    String invoiceNo,
    String customerId = "",
    String customerName = "",
    List<BillItem> billItemsList,
    double grossAmt = 0,
    double taxAmt = 0,
    double discountAmt = 0,
    double finalAmt = 0,
    double amtPaid = 0,
    double amtBalance = 0,
    List<Items> stockItemsToUpdate,
    List<double> stockItemsQtyToUpdate,
  }) async {
    bool success = true;
    String creationDate = DateTime.now().millisecondsSinceEpoch.toString();
    DatabaseService databaseService = DatabaseService();
    await databaseService.getRefToBillsCollection(uid).doc(creationDate).set({
      'customerId': customerId,
      'customerName': customerName.capitalizeFirstofEach,
      'invoiceNo': invoiceNo,
      'grossAmt': grossAmt,
      'taxAmt': taxAmt,
      'discountAmt': discountAmt,
      'finalAmt': finalAmt,
      'invoiceDate': creationDate,
      'amtPaid': amtPaid,
      'amtBalance': amtBalance,
    }).catchError((e) {
      success = false;
      print(e.toString());
    });

    final billItemsCollectionRef = databaseService
        .getRefToBillsCollection(uid)
        .doc(creationDate)
        .collection('billItems');

    int counter = 1;
    for (BillItem i in billItemsList) {
      await billItemsCollectionRef.doc(counter.toString()).set({
        'name': i.name,
        'qty': i.qty,
        'unit': i.unit,
        'pricePerUnit': i.pricePerUnit,
        'discount': i.discount,
        'tax': i.tax,
        'amt': i.amt,
      }).catchError((e) {
        success = false;
        print(e.toString());
      });
      counter++;
    }

    ItemsModel().updateMultipleSoldStockItem(
      uid: uid,
      items: stockItemsToUpdate,
      amtSold: stockItemsQtyToUpdate,
    );

    return success;
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
  final double amtPaid;
  final double amtBalance;

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
    this.amtPaid,
    this.amtBalance,
  });
}

class BillItem {
  String name;
  double qty;
  String unit;
  double pricePerUnit;
  double discount;
  double tax;
  double amt;

  BillItem({
    this.name = "",
    this.qty = 1,
    this.unit = "",
    this.pricePerUnit = 0,
    this.discount = 0,
    this.tax = 0,
    this.amt = 0,
  });
}
