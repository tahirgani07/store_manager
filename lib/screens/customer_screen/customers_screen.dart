import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/locator.dart';
import 'package:store_manager/models/customer_model/customer_model.dart';
import 'package:store_manager/models/navigation_model.dart';
import 'package:store_manager/routing/route_names.dart';
import 'package:store_manager/screens/customer_screen/customer_screen_alert_dialog.dart';
import 'package:store_manager/screens/utils/theme.dart';
import 'package:store_manager/services/navigation_service.dart';

class CustomersScreen extends StatefulWidget {
  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  TextEditingController searchController;
  List<Customer> _searchList = [];
  List<Customer> _customersList;
  ScrollController _scrollController;
  NavigationModel navigationModel;

  @override
  void initState() {
    searchController = TextEditingController();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _customersList = Provider.of<List<Customer>>(context) ?? [];
    String uid = Provider.of<User>(context).uid ?? "";
    navigationModel = Provider.of<NavigationModel>(context);
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
            locator<NavigationService>().navigateTo(BillTransRoute);
          }
          return false;
        }
      },
      child: Scaffold(
        body: Material(
          color: bgColor,
          elevation: 8.0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("CUSTOMERS LIST"),
                  RaisedButton(
                    onPressed: () => showAddCustomerDialog(context, uid),
                    child: Text("ADD NEW CUSTOMER"),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                  ),
                ],
              ),
              getSearchBar(searchController, _onSearchTextChanged),
              _getHeaderRow(),
              Expanded(
                child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: (searchController.text.isNotEmpty)
                        ? getListView(context, uid, _searchList)
                        : getListView(context, uid, _customersList)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onSearchTextChanged(String text) {
    _searchList.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    text = text.toLowerCase();
    _customersList.forEach((customer) {
      String fullName =
          "${customer.firstName.toLowerCase()} ${customer.lastName.toLowerCase()}";
      if (fullName.contains(text) ||
          customer.email.toLowerCase().contains(text) ||
          customer.birthDate.toLowerCase().contains(text) ||
          customer.phoneNo.toLowerCase().contains(text)) {
        _searchList.add(customer);
      }
      setState(() {});
    });
  }

  Widget getListView(BuildContext context, String uid, List<Customer> reqList) {
    return CupertinoScrollbar(
      thickness: 5,
      isAlwaysShown: true,
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: reqList.length,
        itemBuilder: (context, counter) {
          return Material(
            elevation: 8.0,
            child: InkWell(
              hoverColor: Colors.grey.shade200,
              onTap: () => showCustomerDetailsDialog(
                context,
                uid,
                reqList[counter],
              ),
              child: Row(
                children: [
                  getFlexContainer(
                      "${reqList[counter].firstName} ${reqList[counter].lastName}",
                      2),
                  getFlexContainer(reqList[counter].email, 2),
                  getFlexContainer(reqList[counter].phoneNo, 1),
                  getFlexContainer(reqList[counter].birthDate, 1),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getHeaderRow() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Material(
        child: Row(
          children: [
            getFlexContainer("Name", 2, height: 57, textBold: true),
            getFlexContainer("Email", 2, height: 57, textBold: true),
            getFlexContainer("Phone No", 1, height: 57, textBold: true),
            getFlexContainer("D.O.B", 1, height: 57, textBold: true),
          ],
        ),
      ),
    );
  }
}
