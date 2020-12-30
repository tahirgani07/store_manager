import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:store_manager/models/stocks_model/stock_items_model.dart';
import 'package:store_manager/screens/stocks_screen/stock_screen_alert_dialogs.dart';
import 'package:store_manager/screens/utils/CustomTextStyle.dart';
import 'package:store_manager/screens/utils/marquee_widget.dart';
import 'package:store_manager/screens/utils/theme.dart';

class StockItemsDataTable extends StatefulWidget {
  @override
  _StockItemsDataTableState createState() => _StockItemsDataTableState();
}

class _StockItemsDataTableState extends State<StockItemsDataTable> {
  TextEditingController _searchController;
  List<Items> _searchList = [];
  int _sortColumnIndex = 0;
  List<Items> _itemsList = [];

  bool itemsColSortBool = false;
  bool remainingColSortBool = false;
  bool soldColSortBool = false;

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
    return ResponsiveBuilder(builder: (context, sizingInfo) {
      return Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            showOnlyForDesktop(
              sizingInfo: sizingInfo,
              widgetDesk: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Stock Items",
                    style: CustomTextStyle.h1,
                  ),
                  SizedBox(width: 20),
                  addSomethingButton(
                    context: context,
                    text: "Add an Item",
                    onPressed: () => showAddItemDialog(context, uid),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              width: sizingInfo.isDesktop ? 400 : double.infinity,
              child: getSearchBar(_searchController, _onSearchTextChanged),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 10),
                color: Colors.white,
                child: Material(
                  elevation: 8.0,
                  child: Column(
                    children: [
                      _headerRow(),
                      Expanded(
                        child: _searchController.text.isNotEmpty
                            ? _getDataRows(context, uid, _searchList)
                            : _getDataRows(context, uid, _itemsList),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _headerRow() {
    return Row(
      children: [
        _getFlexCotainerForHeader("ITEMS", 3, 0, itemsColSortBool),
        _getFlexCotainerForHeader(
          "SOLD",
          2,
          1,
          soldColSortBool,
          color: CustomColors.lightGrey,
          alignment: Alignment.center,
        ),
        _getFlexCotainerForHeader(
          "REMIANING",
          2,
          2,
          remainingColSortBool,
          alignment: Alignment.center,
        ),
      ],
    );
  }

  _getFlexCotainerForHeader(
    String title,
    int flex,
    int columnIndex,
    bool columnsSortBool, {
    double height = 40,
    Alignment alignment,
    Color color,
  }) {
    return Flexible(
      flex: flex,
      child: Container(
        child: InkWell(
          onTap: () {
            _itemsList = _onSortColumn(columnIndex, columnsSortBool);
          },
          child: Container(
            height: height,
            alignment: alignment ?? Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              color: color,
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: MarqueeWidget(
              child: Row(
                children: [
                  Text(
                    title,
                    style: CustomTextStyle.grey_bold_small,
                  ),
                  SizedBox(width: 5),
                  (_sortColumnIndex == columnIndex)
                      ? Icon(
                          (columnsSortBool)
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          size: 16,
                          color: Colors.grey[700],
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getDataRows(BuildContext context, String uid, List<Items> reqList) {
    // onSelectChanged: (b) =>
    //     showStockDetailsDialog(context, uid, item),
    List<dynamic> temp = [];
    temp = reqList
        .map((item) => InkWell(
              onTap: () => showStockDetailsDialog(context, uid, item),
              child: Row(
                children: [
                  getFlexContainer("${item.name}", 3),
                  getFlexContainer(
                    "${item.stockSold}",
                    2,
                    color: CustomColors.lightGrey,
                    alignment: Alignment.centerRight,
                  ),
                  getFlexContainer(
                    "${item.remainingStock}",
                    2,
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),
            ))
        .toList();
    return ListView.builder(
        itemCount: temp.length,
        itemBuilder: (context, counter) {
          return temp[counter];
        });
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
    if (columnIndex == 0) {
      setState(() {
        itemsColSortBool = !ascending;
      });
    } else if (columnIndex == 1) {
      setState(() {
        soldColSortBool = !ascending;
      });
    } else {
      setState(() {
        remainingColSortBool = !ascending;
      });
    }

    setState(() {
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
