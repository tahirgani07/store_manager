import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/bills_model/bill_model.dart';
import 'package:store_manager/models/bills_model/offline_bill_items_model.dart';
import 'package:store_manager/models/customer_model/customer_model.dart';
import 'package:store_manager/models/stocks_model/stock_items_model.dart';
import 'package:store_manager/models/stocks_model/stock_trans_model.dart';
import 'package:store_manager/routing/route_names.dart';
import 'package:store_manager/screens/billing_screen/add_bill_screen.dart';
import 'package:store_manager/screens/billing_screen/bill_main_screen.dart';
import 'package:store_manager/screens/customer_screen/customers_screen.dart';
import 'package:store_manager/screens/settings_screen/settings_screen.dart';
import 'package:store_manager/screens/stocks_screen/stock_trans_list.dart';
import 'package:store_manager/screens/stocks_screen/stocks_screen.dart';

Route<dynamic> generateRoute(String uid, RouteSettings settings) {
  switch (settings.name) {
    case BillTransRoute:
      return getRouteWithProviders(uid, BillMainScreen(), settings.name);
    case AddBillRoute:
      return getRouteWithProviders(uid, AddBillScreen(), settings.name);
    case StocksRoute:
      return getRouteWithProviders(uid, StocksScreen(), settings.name);
    case StockTransRoute:
      return getRouteWithProviders(
          uid, StockTransList(fullScreen: true), settings.name);
    case CustomersRoute:
      return getRouteWithProviders(uid, CustomersScreen(), settings.name);
    case SettingsRoute:
      return MaterialPageRoute(
        settings: RouteSettings(name: settings.name),
        builder: (context) => SettingsScreen(),
      );
    default:
      return getRouteWithProviders(uid, BillMainScreen(), BillTransRoute);
  }
}

MaterialPageRoute getRouteWithProviders(
    String uid, Widget screen, String name) {
  return MaterialPageRoute(
      settings: RouteSettings(name: name),
      builder: (context) {
        return MultiProvider(
          providers: [
            StreamProvider<List<Items>>.value(
              value: ItemsModel().fetchItems(uid),
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
            ChangeNotifierProvider(
              create: (context) => BillModel(),
            ),
            ChangeNotifierProvider(
              create: (context) => OfflineBillItemsModel(),
            ),
          ],
          child: screen,
        );
      });
}
