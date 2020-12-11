import 'package:flutter/material.dart';
import 'package:store_manager/models/customer_model/customer_model.dart';
import 'package:store_manager/screens/utils/loading_screen.dart';
import 'package:store_manager/screens/utils/theme.dart';
import 'package:intl/intl.dart';

Future<void> showAddCustomerDialog(BuildContext context, String uid,
    {String name = ""}) async {
  bool loading = false;
  TextEditingController firstNameController = TextEditingController(text: name);
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            elevation: 8.0,
            contentPadding: EdgeInsets.all(10.0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ADD NEW CUSTOMER"),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: 1,
                ),
              ],
            ),
            content: loading
                ? LoadingScreen(message: "Adding Customer Please wait...")
                : Container(
                    width: 500,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: customTextField(
                                  label: "First Name",
                                  controller: firstNameController,
                                  autofocus: true,
                                  name: name,
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: customTextField(
                                  label: "Last Name",
                                  controller: lastNameController,
                                ),
                              ),
                            ],
                          ),
                          customTextField(
                            label: "Email",
                            controller: emailController,
                          ),
                          customTextField(
                            label: "Phone No",
                            controller: phoneNoController,
                          ),
                          customTextField(
                              label: "Birth Date",
                              controller: birthDateController,
                              readOnly: true,
                              onTap: () async {
                                DateTime date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1990),
                                  lastDate: DateTime.now(),
                                  initialDatePickerMode: DatePickerMode.year,
                                );
                                DateFormat formatter = DateFormat('dd/MM/yyyy');
                                birthDateController.text = date != null
                                    ? formatter.format(date)
                                    : birthDateController.text;
                              }),
                          customTextField(
                            label: "Address",
                            controller: addressController,
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
            actions: <Widget>[
              alertActionButton(
                context: context,
                title: "Add Item",
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  setState(() => loading = true);
                  await CustomerModel().addCustomer(
                    uid: uid,
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    address: addressController.text,
                    email: emailController.text,
                    phoneNo: phoneNoController.text,
                    birthDate: birthDateController.text,
                  );
                  setState(() => loading = false);
                  Navigator.of(context).pop();
                },
              ),
              alertActionButton(context: context),
            ],
          );
        },
      );
    },
  );
}

//---------------------CUSTOMER DETAILS-----------------------
Future<void> showCustomerDetailsDialog(
    BuildContext context, String uid, Customer cust) async {
  return showDialog<void>(
    context: context,
    //barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('${cust.firstName} ${cust.lastName}'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Email - ${cust.email}'),
              Text('Phone No - ${cust.phoneNo}'),
              Text('D.O.B - ${cust.birthDate}'),
              Text('Address - ${cust.address}'),
            ],
          ),
        ),
        actions: <Widget>[
          alertActionButton(context: context),
        ],
      );
    },
  );
}
