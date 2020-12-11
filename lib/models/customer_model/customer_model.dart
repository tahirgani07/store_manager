import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:store_manager/models/database_service.dart';
import 'package:store_manager/screens/utils/theme.dart';

class CustomerModel {
  List<Customer> _convertSnapshots(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Customer(
        firstName: doc['firstName'],
        lastName: doc['lastName'],
        address: doc['address'],
        email: doc['email'],
        phoneNo: doc['phoneNo'],
        birthDate: doc['birthDate'],
        creationDate: doc['creationDate'],
      );
    }).toList();
  }

  Stream<List<Customer>> fetchCustomers(String uid) {
    DatabaseService databaseService = DatabaseService();
    return databaseService
        .getRefToCustomersCollection(uid)
        .orderBy("firstName")
        .snapshots()
        .map(_convertSnapshots);
  }

  Future addCustomer({
    @required String uid,
    String firstName,
    String lastName,
    String address,
    String email,
    String phoneNo,
    String birthDate,
  }) async {
    String creationDate = DateTime.now().millisecondsSinceEpoch.toString();
    DatabaseService databaseService = DatabaseService();
    await databaseService
        .getRefToCustomersCollection(uid)
        .doc(creationDate)
        .set({
      'firstName': firstName.capitalizeFirstofEach,
      'lastName': lastName.capitalizeFirstofEach,
      'address': address,
      'birthDate': birthDate,
      'email': email,
      'phoneNo': phoneNo,
      'creationDate': creationDate,
    }).catchError((e) => print(e.toString()));
  }
}

class Customer {
  final String firstName;
  final String lastName;
  final String address;
  final String birthDate;
  final String email;
  final String phoneNo;
  final String creationDate;

  Customer({
    this.firstName,
    this.lastName,
    this.birthDate,
    this.address,
    this.email,
    this.phoneNo,
    this.creationDate,
  });
}
