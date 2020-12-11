import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/auth_manager.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User>.value(
            value: FirebaseAuth.instance.authStateChanges()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Store Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthManager(),
      ),
    );
  }
}
