import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:store_manager/models/database_service.dart';
import 'package:store_manager/routing/route_names.dart';
import 'package:store_manager/screens/utils/loading_screen.dart';
import 'package:store_manager/screens/utils/theme.dart';

Future<void> showPersonalDetailsAlertDialog(
    BuildContext context, String uid) async {
  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController companyNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController phoneNoCont = TextEditingController();
  bool showError = false;

  return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            elevation: 8.0,
            title: Text("Add a few Details Before You Begin"),
            content: SingleChildScrollView(
              child: Container(
                width: 500,
                child: Column(
                  children: [
                    showError
                        ? Text(
                            "Please Fill all the Fields!",
                            style: TextStyle(color: Colors.red),
                          )
                        : SizedBox(),
                    customTextField(
                        label: "First Name",
                        controller: firstNameCont,
                        autofocus: true),
                    customTextField(
                        label: "Last Name", controller: lastNameCont),
                    customTextField(
                        label: "Company Name", controller: companyNameCont),
                    customTextField(label: "Email", controller: emailCont),
                    customTextField(
                        label: "Phone No.",
                        controller: phoneNoCont,
                        numeric: true),
                  ],
                ),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 25),
                child: RaisedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return LoadingScreen(
                            message: "Updating Details",
                            textColor: Colors.white);
                      },
                    );

                    if (firstNameCont.text.isEmpty ||
                        lastNameCont.text.isEmpty ||
                        companyNameCont.text.isEmpty ||
                        emailCont.text.isEmpty ||
                        phoneNoCont.text.isEmpty) {
                      Navigator.pop(context);
                      setState(() {
                        showError = true;
                      });
                      return;
                    }

                    DatabaseService databaseService = DatabaseService();
                    try {
                      await databaseService.getRefToUsersDocument(uid).set({
                        "firstName": firstNameCont.text,
                        "lastName": lastNameCont.text,
                        "companyName": companyNameCont.text,
                        "email": emailCont.text,
                        "phoneNo": phoneNoCont.text,
                      });
                    } catch (e) {
                      Flushbar(
                              title: "Error..Please try again",
                              message: e.toString())
                          .show(context);
                      return;
                    }
                    Flushbar(
                      title: "Successful",
                      message: "Details Updated",
                      duration: Duration(seconds: 2),
                    ).show(context);
                    Navigator.popAndPushNamed(context, BillTransRoute);
                  },
                  child: Text("Save", style: TextStyle(fontSize: 17)),
                  color: Colors.blue,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      });
}
