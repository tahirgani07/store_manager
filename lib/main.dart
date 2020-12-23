import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/locator.dart';
import 'package:store_manager/routing/route_names.dart';
import 'package:store_manager/routing/router.dart';
import 'package:store_manager/screens/layout_template/layout_template.dart';
import 'package:store_manager/screens/login_screen.dart';
import 'package:store_manager/services/navigation_service.dart';

void main() async {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
        value: FirebaseAuth.instance.authStateChanges(),
        builder: (context, child) {
          String uid = "";
          User user = Provider.of<User>(context);
          bool loggedIn = user != null;
          if (user != null) {
            uid = user.uid;
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Store Manager',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Nunito',
            ),
            builder: (context, child) {
              if (loggedIn) return LayoutTemplate(child: child);
              return LoginScreen();
            },
            navigatorKey: locator<NavigationService>().navigatorKey,
            onGenerateRoute: (settings) => generateRoute(uid, settings),
            initialRoute: BillTransRoute,
          );
        });
  }
}
