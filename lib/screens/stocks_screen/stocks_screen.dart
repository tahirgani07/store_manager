import 'package:flutter/material.dart';
import 'package:store_manager/screens/stocks_screen/stock_items_datatable.dart';
import 'package:store_manager/screens/stocks_screen/stock_trans_list.dart';
import 'package:store_manager/screens/utils/theme.dart';

class StocksScreen extends StatefulWidget {
  @override
  _StocksScreenState createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StockItemsDataTable(),
          Expanded(
            child: StockTransDataTable(),
          ),
        ],
      ),
    );
  }
}
