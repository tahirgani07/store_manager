import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store_manager/models/database_service.dart';
import 'package:store_manager/models/stocks_model/stock_trans_model.dart';
import 'package:store_manager/screens/utils/theme.dart';

class ItemsModel {
  List<Items> itemsList = [];

  List<Items> _convertSnapshots(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Items(
        name: doc['name'],
        unit: doc['unit'],
        pricePerUnit: doc['pricePerUnit'].toDouble(),
        stockSold: doc['stockSold'].toDouble(),
        remainingStock: doc['remainingStock'].toDouble(),
        creationDate: doc['creationDate'],
      );
    }).toList();
  }

  Stream<List<Items>> fetchItems(String uid) {
    DatabaseService databaseService = DatabaseService();
    return databaseService
        .getRefToItemsCollection(uid)
        .orderBy("name")
        .snapshots()
        .map(_convertSnapshots);
  }

  Future addItem({
    @required String uid,
    String name,
    String unit,
    double pricePerUnit,
    double remainingStock,
  }) async {
    String creationDate = DateTime.now().millisecondsSinceEpoch.toString();
    DatabaseService databaseService = DatabaseService();
    await databaseService.getRefToItemsCollection(uid).doc(creationDate).set({
      'name': name.capitalizeFirstofEach,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'remainingStock': remainingStock,
      'stockSold': 0,
      'creationDate': creationDate,
    }).catchError((e) => print(e.toString()));
    await addStockTrans(
      uid: uid,
      itemName: name,
      unit: unit,
      qty: remainingStock,
      type: StockTransType.newStock,
    );
  }

  Future updateMultipleSoldStockItem({
    @required String uid,
    List<Items> items,
    List<double> amtSold,
  }) async {
    bool success = true;
    DatabaseService databaseService = DatabaseService();
    for (int i = 0; i < items.length; i++) {
      await databaseService
          .getRefToItemsCollection(uid)
          .doc(items[i].creationDate)
          .update({
        'remainingStock': items[i].remainingStock - amtSold[i],
        'stockSold': items[i].stockSold + amtSold[i],
      }).catchError((e) {
        success = false;
        print(e.toString());
      });
    }
    return success;
  }

  Future addStock({
    @required String uid,
    Items item,
    double qty,
    StockTransType type,
  }) async {
    DatabaseService databaseService = DatabaseService();
    double finalStock = (type == StockTransType.add)
        ? (item.remainingStock + qty)
        : (item.remainingStock - qty);
    await databaseService
        .getRefToItemsCollection(uid)
        .doc(item.creationDate)
        .update({
      'remainingStock': finalStock,
    }).catchError((e) => print(e.toString()));
    await addStockTrans(
      uid: uid,
      itemName: item.name,
      unit: item.unit,
      qty: qty,
      type: type,
    );
  }

  Future addStockTrans({
    @required String uid,
    @required String itemName,
    @required String unit,
    @required double qty,
    @required StockTransType type,
  }) async {
    DatabaseService databaseService = DatabaseService();
    String creationDate = DateTime.now().millisecondsSinceEpoch.toString();
    String transType;
    if (type == StockTransType.newStock) transType = "New Item Added";
    if (type == StockTransType.add) transType = "Stock Added";
    if (type == StockTransType.reduce) transType = "Stock Reduced";

    await databaseService
        .getRefToStockTransCollection(uid)
        .doc(creationDate)
        .set({
      "type": transType,
      "itemName": itemName,
      "unit": unit,
      "quantity": qty,
      "creationDate": creationDate,
    }).catchError((e) => print(e.toString()));
  }
}

class Items {
  final String name;
  final String unit;
  final double pricePerUnit;
  final double stockSold;
  final double remainingStock;
  final String creationDate;

  Items({
    this.stockSold,
    this.remainingStock,
    this.name,
    this.unit,
    this.pricePerUnit,
    this.creationDate,
  });
}
