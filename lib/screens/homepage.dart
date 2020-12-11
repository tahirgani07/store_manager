import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/bills_model/bill_model.dart';
import 'package:store_manager/models/customer_model/customer_model.dart';
import 'package:store_manager/models/navigation_model.dart';
import 'package:store_manager/models/stocks_model/stock_items_model.dart';
import 'package:store_manager/models/stocks_model/stock_trans_model.dart';
import 'package:store_manager/screens/billing_screen/bill_main_screen.dart';
import 'package:store_manager/screens/customer_screen/customers_screen.dart';
import 'package:store_manager/screens/utils/error_screen.dart';
import 'package:store_manager/screens/stocks_screen/stocks_screen.dart';
import 'package:store_manager/screens/utils/navdrawer/collapsing_nav_drawer.dart';
import 'package:store_manager/screens/utils/theme.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    bool mediumScreen = screenSize.width <= desktopWidth;
    String uid = Provider.of<User>(context).uid;
    uid = uid ?? '';

    return SafeArea(
      child: Scaffold(
        appBar: mediumScreen ? AppBar(title: Text("Stock Manager")) : null,
        drawer: mediumScreen ? CollapsingNavigationDrawer() : null,
        body: Row(
          children: [
            mediumScreen ? SizedBox() : CollapsingNavigationDrawer(),
            Consumer<NavigationModel>(
              builder: (context, data, child) {
                return Expanded(
                  child: MultiProvider(
                    providers: [
                      StreamProvider<List<Items>>.value(
                        value: ItemsModel().fetchItems(uid),
                        /*catchError: (context, obj) {
                          return [];
                        },*/
                      ),
                      StreamProvider<List<StockTrans>>.value(
                        value: StockTransModel().fetchStockTransactions(uid),
                      ),
                      StreamProvider<List<Customer>>.value(
                        value: CustomerModel().fetchCustomers(uid),
                      ),
                      StreamProvider<List<Bill>>.value(
                        value: BillModel().fetchBillsDetails(uid),
                      ),
                    ],
                    child: getScreen(data.getScreenIndex()),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getScreen(int index) {
    if (index == 0) return new BillMainScreen();
    if (index == 1) return new StocksScreen();
    if (index == 2) return new CustomersScreen();
    return ErrorScreen();
  }
}
