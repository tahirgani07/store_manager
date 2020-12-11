import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/stocks_model/stock_items_model.dart';
import 'package:store_manager/screens/stocks_screen/stock_screen_alert_dialogs.dart';
import 'package:store_manager/screens/utils/theme.dart';

class StockItemsDataTable extends StatefulWidget {
  @override
  _StockItemsDataTableState createState() => _StockItemsDataTableState();
}

class _StockItemsDataTableState extends State<StockItemsDataTable> {
  TextEditingController _searchController;
  List<Items> _searchList = [];
  bool _sortDatatable = true;
  int _sortColumnIndex = 0;
  List<Items> _itemsList = [];

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
    _itemsList = Provider.of<List<Items>>(context) ?? [];
    String uid = Provider.of<User>(context).uid;
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "STOCK ITEMS",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(width: 20),
              RaisedButton(
                onPressed: () => showAddItemDialog(context, uid),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text("ADD ITEM"),
              ),
            ],
          ),
          Container(
            width: 400,
            child: getSearchBar(_searchController, _onSearchTextChanged),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(10.0),
              color: Colors.white,
              child: Material(
                elevation: 8.0,
                child: SingleChildScrollView(
                  child: DataTable(
                    showCheckboxColumn: false,
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortDatatable,
                    columns: [
                      DataColumn(
                        label: Text('ITEM'),
                        onSort: (i, b) => _itemsList = _onSortColumn(i, b),
                      ),
                      DataColumn(
                        label: Text('SOLD'),
                        onSort: (i, b) => _itemsList = _onSortColumn(i, b),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('REMAINING'),
                        onSort: (i, b) => _itemsList = _onSortColumn(i, b),
                        numeric: true,
                      ),
                    ],
                    rows: _searchController.text.isNotEmpty
                        ? _getDataRows(context, uid, _searchList)
                        : _getDataRows(context, uid, _itemsList),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow> _getDataRows(
      BuildContext context, String uid, List<Items> reqList) {
    List<DataRow> temp = reqList
        .map((item) => DataRow(
              onSelectChanged: (b) =>
                  showStockDetailsDialog(context, uid, item),
              cells: [
                DataCell(
                  Tooltip(
                    message: "Test Message",
                    child: Text("${item.name}"),
                  ),
                ),
                DataCell(Text("${item.stockSold}")),
                DataCell(Text("${item.remainingStock}")),
              ],
            ))
        .toList();
    return temp ?? [];
  }

  _onSearchTextChanged(String text) {
    _searchList.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    text = text.toLowerCase();
    _itemsList.forEach((item) {
      if (item.name.toLowerCase().contains(text) ||
          item.stockSold.toString().contains(text) ||
          item.remainingStock.toString().contains(text)) {
        _searchList.add(item);
      }
      setState(() {});
    });
  }

  List<Items> _onSortColumn(int columnIndex, bool ascending) {
    setState(() {
      _sortDatatable = ascending;
      _sortColumnIndex = columnIndex;
    });
    List<Items> reqList =
        (_searchController.text.isEmpty) ? _itemsList : _searchList;
    if (ascending) {
      if (columnIndex == 0) reqList.sort((a, b) => a.name.compareTo(b.name));
      if (columnIndex == 1)
        reqList.sort((a, b) => a.stockSold.compareTo(b.stockSold));
      if (columnIndex == 2)
        reqList.sort((a, b) => a.remainingStock.compareTo(b.remainingStock));
    } else {
      if (columnIndex == 0) reqList.sort((a, b) => b.name.compareTo(a.name));
      if (columnIndex == 1)
        reqList.sort((a, b) => b.stockSold.compareTo(a.stockSold));
      if (columnIndex == 2)
        reqList.sort((a, b) => b.remainingStock.compareTo(a.remainingStock));
    }
    return reqList;
  }
}
