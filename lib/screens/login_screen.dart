import 'package:flutter/material.dart';
import 'package:store_manager/models/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: FlatButton(
        onPressed: () async {
          await AuthService().signInWithGoogle();
        },
        child: Text("Sign in with google"),
      ),
    ));
  }
}
