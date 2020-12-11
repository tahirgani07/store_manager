import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/stocks_model/stock_trans_model.dart';
import 'package:store_manager/screens/utils/theme.dart';
import 'package:intl/intl.dart';

class StockTransDataTable extends StatefulWidget {
  @override
  _StockTransDataTableState createState() => _StockTransDataTableState();
}

class _StockTransDataTableState extends State<StockTransDataTable> {
  TextEditingController _searchController;
  List<StockTrans> _searchList = [];
  List<StockTrans> _stockTransList = [];
  DateFormat formatter = DateFormat("dd/MM/yyyy");

  @override
  void initState() {
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _stockTransList = Provider.of<List<StockTrans>>(context) ?? [];

    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
        children: [
          Text(
            "STOCK TRANSACTIONS",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: getSearchBar(_searchController, _onSearchTextChanged),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
              color: Colors.white,
              child: Material(
                elevation: 8.0,
                child: Column(
                  children: [
                    _getHeaderRow(),
                    (_searchController.text.isNotEmpty)
                        ? _getStockTransList(context, _searchList)
                        : _getStockTransList(context, _stockTransList),
                  ],
                ),
              ),
            ),
          )
        ],
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
    _stockTransList.forEach((trans) {
      String date = formatter.format(DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(trans.creationDate)));
      if (trans.itemName.toLowerCase().contains(text) ||
          trans.type.toLowerCase().contains(text) ||
          trans.quantity.toString().contains(text) ||
          date.contains(text)) {
        _searchList.add(trans);
      }
      setState(() {});
    });
  }

  Widget _getStockTransList(BuildContext context, List<StockTrans> transList) {
    return Expanded(
      child: ListView.builder(
        itemCount: transList.length,
        itemBuilder: (context, counter) {
          return Row(
            children: [
              getFlexContainer(transList[counter].type, 4),
              getFlexContainer(transList[counter].itemName, 4),
              getFlexContainer(
                  formatter.format(DateTime.fromMillisecondsSinceEpoch(
                      int.parse(transList[counter].creationDate))),
                  4),
              getFlexContainer(transList[counter].quantity.toString(), 3,
                  alignment: Alignment.centerRight),
              getFlexContainer(transList[counter].unit, 2),
            ],
          );
        },
      ),
    );
  }

  Widget _getHeaderRow() {
    return Row(
      children: [
        getFlexContainer("TYPE", 4, height: 57, textBold: true),
        getFlexContainer("NAME", 4, height: 57, textBold: true),
        getFlexContainer("DATE", 4, height: 57, textBold: true),
        getFlexContainer("QTY UPDATED", 3, height: 57, textBold: true),
        getFlexContainer("UNIT", 2, height: 57, textBold: true),
      ],
    );
  }
}
