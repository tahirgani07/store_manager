import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/navigation_model.dart';
import 'package:store_manager/screens/homepage.dart';
import 'package:store_manager/screens/login_screen.dart';

class AuthManager extends StatefulWidget {
  @override
  _AuthManagerState createState() => _AuthManagerState();
}

class _AuthManagerState extends State<AuthManager> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    bool loggedIn = user != null;
    //print(user.uid);
    return loggedIn
        ? ChangeNotifierProvider(
            /* Need Navigations model to keep track of the index of the current screen in collapsing nav drawer*/
            create: (context) => NavigationModel(),
            child: HomePage(),
          )
        : LoginScreen();
  }
}
