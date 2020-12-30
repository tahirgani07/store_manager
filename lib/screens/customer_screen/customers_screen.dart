import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:store_manager/locator.dart';
import 'package:store_manager/models/customer_model/customer_model.dart';
import 'package:store_manager/models/navigation_model.dart';
import 'package:store_manager/routing/route_names.dart';
import 'package:store_manager/screens/customer_screen/customer_screen_alert_dialog.dart';
import 'package:store_manager/screens/utils/CustomTextStyle.dart';
import 'package:store_manager/screens/utils/navdrawer/collapsing_nav_drawer.dart';
import 'package:store_manager/screens/utils/navdrawer/toggle_nav_bar.dart';
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
  ToggleNavBar toggleNavBar;

  @override
  void initState() {
    searchController = TextEditingController();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigationModel = Provider.of<NavigationModel>(context, listen: false);
      int index = 2;

      bool sameTab = navigationModel.currentScreenIndex == index;

      navigationModel.updateCurrentScreenIndex(index);

      if (!sameTab) navigationModel.addToStack(index);

      /// Show NavBar
      toggleNavBar.updateShow(true);
    });
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
    toggleNavBar = Provider.of<ToggleNavBar>(context);

    String uid = Provider.of<User>(context).uid ?? "";
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
      child: ResponsiveBuilder(builder: (context, sizingInfo) {
        return Scaffold(
          backgroundColor: CustomColors.bgBlue,
          ///////////////////////// APP BAR
          appBar: (!sizingInfo.isDesktop)
              ? AppBar(
                  title: Text("Customers"),
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
          /////////////////////// BODY
          body: Material(
            elevation: 8.0,
            child: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  showOnlyForDesktop(
                    sizingInfo: sizingInfo,
                    widgetDesk: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Customers", style: CustomTextStyle.h1),
                        addSomethingButton(
                          context: context,
                          text: "Add a Customer",
                          onPressed: () => showAddCustomerDialog(context, uid),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: getSearchBar(
                      searchController,
                      _onSearchTextChanged,
                    ),
                  ),
                  _getHeaderRow(sizingInfo),
                  Expanded(
                    child: Container(
                        child: (searchController.text.isNotEmpty)
                            ? getListView(context, uid, _searchList, sizingInfo)
                            : getListView(
                                context, uid, _customersList, sizingInfo)),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
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

  Widget getListView(BuildContext context, String uid, List<Customer> reqList,
      SizingInformation sizingInfo) {
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
                    sizingInfo.isDesktop ? 2 : 3,
                  ),
                  showOnlyForDesktop(
                    sizingInfo: sizingInfo,
                    widgetDesk: getFlexContainer(
                      reqList[counter].email,
                      2,
                      color: CustomColors.lightGrey,
                    ),
                  ),
                  getFlexContainer(
                    reqList[counter].phoneNo,
                    sizingInfo.isDesktop ? 1 : 2,
                    color:
                        !sizingInfo.isDesktop ? CustomColors.lightGrey : null,
                  ),
                  getFlexContainer(
                    reqList[counter].birthDate,
                    sizingInfo.isDesktop ? 1 : 2,
                    color: sizingInfo.isDesktop ? CustomColors.lightGrey : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getHeaderRow(SizingInformation sizingInfo) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Material(
        elevation: 8.0,
        child: Row(
          children: [
            getFlexContainer(
              "Name",
              sizingInfo.isDesktop ? 2 : 3,
              header: true,
            ),
            showOnlyForDesktop(
              sizingInfo: sizingInfo,
              widgetDesk: getFlexContainer(
                "Email",
                2,
                header: true,
                color: CustomColors.lightGrey,
              ),
            ),
            getFlexContainer(
              "Phone No",
              sizingInfo.isDesktop ? 1 : 2,
              header: true,
              color: !sizingInfo.isDesktop ? CustomColors.lightGrey : null,
            ),
            getFlexContainer(
              "D.O.B",
              sizingInfo.isDesktop ? 1 : 2,
              header: true,
              color: sizingInfo.isDesktop ? CustomColors.lightGrey : null,
            ),
          ],
        ),
      ),
    );
  }
}
