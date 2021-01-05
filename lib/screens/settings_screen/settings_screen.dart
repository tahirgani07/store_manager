import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:store_manager/locator.dart';
import 'package:store_manager/models/database_service.dart';
import 'package:store_manager/models/navigation_model.dart';
import 'package:store_manager/routing/route_names.dart';
import 'package:store_manager/screens/utils/CustomTextStyle.dart';
import 'package:store_manager/screens/utils/loading_screen.dart';
import 'package:store_manager/screens/utils/navdrawer/collapsing_nav_drawer.dart';
import 'package:store_manager/screens/utils/navdrawer/toggle_nav_bar.dart';
import 'package:store_manager/screens/utils/theme.dart';
import 'package:store_manager/services/navigation_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  NavigationModel navigationModel;
  ToggleNavBar toggleNavBar;

  TextEditingController firstNameCont,
      lastNameCont,
      emailCont,
      phoneNoCont,
      companyNameCont;
  String uid = "";

  @override
  void initState() {
    firstNameCont = TextEditingController();
    lastNameCont = TextEditingController();
    emailCont = TextEditingController();
    phoneNoCont = TextEditingController();
    companyNameCont = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      navigationModel = Provider.of<NavigationModel>(context, listen: false);
      int index = 3;

      bool sameTab = navigationModel.currentScreenIndex == index;

      navigationModel.updateCurrentScreenIndex(index);

      if (!sameTab) navigationModel.addToStack(index);

      /// Show NavBar
      toggleNavBar.updateShow(true);

      ///////////////////////////////////////////
      DatabaseService databaseService = DatabaseService();
      DocumentSnapshot doc = await databaseService.fetchPersonalDetail(uid);
      try {
        firstNameCont.text = doc["firstName"];
        lastNameCont.text = doc["lastName"];
        companyNameCont.text = doc["companyName"];
        emailCont.text = doc["email"];
        phoneNoCont.text = doc["phoneNo"];
      } catch (e) {
        print(e);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    firstNameCont.dispose();
    lastNameCont.dispose();
    emailCont.dispose();
    companyNameCont.dispose();
    phoneNoCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    toggleNavBar = Provider.of<ToggleNavBar>(context);
    uid = Provider.of<User>(context).uid ?? "";

    return WillPopScope(
      onWillPop: () async {
        int lastIndex = 0;
        if (navigationModel.indexStack.length > 1) {
          lastIndex = navigationModel.popFromStack();
          navigationModel.updateCurrentScreenIndex(lastIndex);
          return true;
        } else {
          navigationModel.resetIndexStack();
          if (navigationModel.currentScreenIndex != lastIndex) {
            navigationModel.updateCurrentScreenIndex(lastIndex);
            locator<NavigationService>().navigateTo(BillTransRoute, true);
          }
          return false;
        }
      },
      child: ResponsiveBuilder(
        builder: (context, sizingInfo) {
          return Scaffold(
            backgroundColor: CustomColors.bgBlue,
            ///////////////////////// APP BAR
            appBar: (!sizingInfo.isDesktop)
                ? AppBar(
                    title: Text("Settings"),
                  )
                : null,
            ////////////////////// DRAWER
            drawer: (!sizingInfo.isDesktop)
                ? CollapsingNavigationDrawer(
                    onSelectTab: (routeName, sameTabPressed) {
                      if (!sizingInfo.isDesktop) Navigator.pop(context);
                      locator<NavigationService>()
                          .navigateTo(routeName, sameTabPressed);
                    },
                  )
                : SizedBox(),
            body: Container(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading for Desktop.
                        showOnlyForDesktop(
                          sizingInfo: sizingInfo,
                          widgetDesk: Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Text("Settings", style: CustomTextStyle.h1),
                          ),
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: customTextField(
                                  label: "First Name",
                                  controller: firstNameCont),
                            ),
                            Flexible(
                              flex: 1,
                              child: customTextField(
                                  label: "Last Name", controller: lastNameCont),
                            ),
                          ],
                        ),
                        Flexible(
                          flex: 1,
                          child: customTextField(
                              label: "Company Name",
                              controller: companyNameCont),
                        ),
                        Flexible(
                          flex: 1,
                          child: customTextField(
                              label: "Email", controller: emailCont),
                        ),
                        Flexible(
                          flex: 1,
                          child: customTextField(
                            label: "Phone No.",
                            controller: phoneNoCont,
                            numeric: true,
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(top: 20, left: 10),
                          child: RaisedButton(
                            onPressed: () async => _onSaveButtonPress(),
                            child: Text("Save", style: TextStyle(fontSize: 17)),
                            color: Colors.blue,
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  showOnlyForDesktop(
                    sizingInfo: sizingInfo,
                    widgetDesk: Flexible(
                      flex: 1,
                      child: Container(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _onSaveButtonPress() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return LoadingScreen(
            message: "Updating Details", textColor: Colors.white);
      },
    );

    if (firstNameCont.text.isEmpty ||
        lastNameCont.text.isEmpty ||
        companyNameCont.text.isEmpty ||
        emailCont.text.isEmpty ||
        phoneNoCont.text.isEmpty) {
      Navigator.pop(context);
      Flushbar(
        title: "Error",
        message: "Please Fill all the Fields",
        duration: Duration(seconds: 2),
      ).show(context);
      return;
    }

    DatabaseService databaseService = DatabaseService();
    try {
      await databaseService.getRefToUsersDocument(uid).update({
        "firstName": firstNameCont.text,
        "lastName": lastNameCont.text,
        "companyName": companyNameCont.text,
        "email": emailCont.text,
        "phoneNo": phoneNoCont.text,
      });
    } catch (e) {
      Navigator.pop(context);
      Flushbar(
        title: "Error",
        message: e.toString(),
        duration: Duration(seconds: 3),
      ).show(context);
      return;
    }

    Navigator.pop(context);
    Flushbar(
      title: "Successful",
      message: "Details Updated",
      duration: Duration(seconds: 3),
    ).show(context);
  }
}
