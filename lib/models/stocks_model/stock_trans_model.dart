import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:store_manager/models/database_service.dart';

enum StockTransType { newStock, add, reduce }

class StockTransModel {
  List<StockTrans> _convertSnapshots(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return StockTrans(
        type: doc['type'],
        itemName: doc['itemName'],
        unit: doc['unit'],
        quantity: doc['quantity'].toDouble(),
        creationDate: doc['creationDate'],
      );
    }).toList();
  }

  Stream<List<StockTrans>> fetchStockTransactions(String uid) {
    DatabaseService databaseService = DatabaseService();
    return databaseService
        .getRefToStockTransCollection(uid)
        .orderBy("creationDate", descending: true)
        .snapshots()
        .map(_convertSnapshots);
  }
}

class StockTrans {
  final String type;
  final String itemName;
  final String unit;
  final double quantity;
  final String creationDate;

  StockTrans(
      {this.type, this.itemName, this.unit, this.quantity, this.creationDate});
}
