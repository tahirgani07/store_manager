import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/locator.dart';
import 'package:store_manager/models/navigation_model.dart';
import 'package:store_manager/routing/route_names.dart';
import 'package:store_manager/screens/stocks_screen/stock_items_datatable.dart';
import 'package:store_manager/screens/stocks_screen/stock_trans_list.dart';
import 'package:store_manager/screens/utils/theme.dart';
import 'package:store_manager/services/navigation_service.dart';

class StocksScreen extends StatefulWidget {
  @override
  _StocksScreenState createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(navigationModel.getIndexStack());
    return Consumer<NavigationModel>(builder: (context, navigationModel, _) {
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
              return locator<NavigationService>().navigateTo(BillTransRoute);
            }
            return false;
          }
        },
        child: Container(
          color: bgColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(flex: 4, child: StockItemsDataTable()),
              Flexible(
                flex: 6,
                child: StockTransList(),
              ),
            ],
          ),
        ),
      );
    });
  }
}
