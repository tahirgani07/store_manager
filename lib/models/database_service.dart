import 'package:cloud_firestore/cloud_firestore.dart';

// Singleton Class
class DatabaseService {
  static final DatabaseService _singletonDbService =
      DatabaseService._internal();

  factory DatabaseService() {
    return _singletonDbService;
  }

  DatabaseService._internal();

  FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference getRefToItemsCollection(String uid) {
    return _db.collection("users").doc(uid).collection("items");
  }

  CollectionReference getRefToStockTransCollection(String uid) {
    return _db.collection("users").doc(uid).collection("stockTrans");
  }

  CollectionReference getRefToCustomersCollection(String uid) {
    return _db.collection("users").doc(uid).collection("customers");
  }

  CollectionReference getRefToBillsCollection(String uid) {
    return _db.collection("users").doc(uid).collection("bills");
  }

  DocumentReference getRefToUsersDocument(String uid) {
    return _db.collection("users").doc(uid);
  }

  Future<DocumentSnapshot> fetchPersonalDetail(String uid) async {
    DatabaseService databaseService = DatabaseService();
    DocumentSnapshot snapshot =
        await databaseService.getRefToUsersDocument(uid).get();
    return snapshot;
  }
}
