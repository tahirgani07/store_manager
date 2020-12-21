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
import 'package:store_manager/screens/stocks_screen/stock_trans_list.dart';
import 'package:store_manager/screens/stocks_screen/stocks_screen.dart';
import 'package:store_manager/screens/utils/error_screen.dart';

Route<dynamic> generateRoute(String uid, RouteSettings settings) {
  switch (settings.name) {
    case BillTransRoute:
      return getRouteWithProviders(uid, BillMainScreen(), settings.name);
    case AddBillRoute:
      return getRouteWithProviders(uid, AddBillScreen(), settings.name);
    case StocksRoute:
      return getRouteWithProviders(uid, StocksScreen(), settings.name);
    case StockTransRoute:
      return getRouteWithProviders(uid, StockTransList(), settings.name);
    case CustomersRoute:
      return getRouteWithProviders(uid, CustomersScreen(), settings.name);
    default:
      return MaterialPageRoute(
        settings: RouteSettings(name: "/error"),
        builder: (_) => ErrorScreen(),
      );
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
