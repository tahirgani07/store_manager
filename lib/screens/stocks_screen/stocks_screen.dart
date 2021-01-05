import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:store_manager/locator.dart';
import 'package:store_manager/models/navigation_model.dart';
import 'package:store_manager/routing/route_names.dart';
import 'package:store_manager/screens/stocks_screen/stock_items_datatable.dart';
import 'package:store_manager/screens/stocks_screen/stock_screen_alert_dialogs.dart';
import 'package:store_manager/screens/stocks_screen/stock_trans_list.dart';
import 'package:store_manager/screens/utils/CustomTextStyle.dart';
import 'package:store_manager/screens/utils/navdrawer/collapsing_nav_drawer.dart';
import 'package:store_manager/screens/utils/navdrawer/toggle_nav_bar.dart';
import 'package:store_manager/screens/utils/theme.dart';
import 'package:store_manager/services/navigation_service.dart';

class StocksScreen extends StatefulWidget {
  @override
  _StocksScreenState createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  NavigationModel navigationModel;
  ToggleNavBar toggleNavBar;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigationModel = Provider.of<NavigationModel>(context, listen: false);
      int index = 1;

      bool sameTab = navigationModel.currentScreenIndex == index;

      navigationModel.updateCurrentScreenIndex(index);

      if (!sameTab) navigationModel.addToStack(index);

      /// show NavBar
      toggleNavBar.updateShow(true);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    toggleNavBar = Provider.of<ToggleNavBar>(context);
    String uid = Provider.of<User>(context).uid;

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
            return locator<NavigationService>()
                .navigateTo(BillTransRoute, true);
          }
          return false;
        }
      },
      child: ResponsiveBuilder(
        builder: (context, sizingInfo) {
          return Scaffold(
            backgroundColor: CustomColors.bgBlue,
            floatingActionButton: showOnlyForDesktop(
              sizingInfo: sizingInfo,
              widgetDesk: SizedBox(),
              widgetMob: FloatingActionButton(
                tooltip: "Add a New Item",
                child: Text("+", style: CustomTextStyle.bigIcons),
                onPressed: () => showAddItemDialog(context, uid),
              ),
            ),
            ///////////////////////// APP BAR
            appBar: (!sizingInfo.isDesktop)
                ? AppBar(
                    title: Text("Stocks"),
                    actions: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: FlatButton(
                          onPressed: () => locator<NavigationService>()
                              .navigateTo(StockTransRoute, false),
                          child: Text(
                            "View Stock Transactions",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          color: Colors.white,
                          textColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                        ),
                      ),
                    ],
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
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(flex: 4, child: StockItemsDataTable()),
                showOnlyForDesktop(
                  sizingInfo: sizingInfo,
                  widgetDesk: Flexible(
                    flex: 6,
                    child: StockTransList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
