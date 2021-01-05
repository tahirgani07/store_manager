import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:store_manager/models/stocks_model/stock_trans_model.dart';
import 'package:store_manager/models/unit_model.dart';
import 'package:store_manager/screens/utils/CustomTextStyle.dart';
import 'package:store_manager/screens/utils/theme.dart';
import 'package:intl/intl.dart';

class StockTransList extends StatefulWidget {
  final bool fullScreen;

  const StockTransList({this.fullScreen = false});

  @override
  _StockTransListState createState() => _StockTransListState();
}

class _StockTransListState extends State<StockTransList> {
  TextEditingController _searchController;
  List<StockTrans> _searchList = [];
  List<StockTrans> _stockTransList = [];
  DateFormat formatter = DateFormat("dd/MM/yyyy");
  ScrollController _scrollController;

  @override
  void initState() {
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _stockTransList = Provider.of<List<StockTrans>>(context) ?? [];

    Widget temp = ResponsiveBuilder(builder: (context, sizingInfo) {
      return Container(
        margin: EdgeInsets.fromLTRB(!widget.fullScreen ? 0 : 10, 10, 10, 10),
        child: Column(
          children: [
            showOnlyForDesktop(
              sizingInfo: sizingInfo,
              widgetDesk: Text(
                "Stock Transactions",
                style: CustomTextStyle.h1,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: getSearchBar(
                _searchController,
                _onSearchTextChanged,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 10),
                color: Colors.white,
                child: Material(
                  elevation: 8.0,
                  child: Column(
                    children: [
                      _getHeaderRow(),
                      (_searchController.text.isNotEmpty)
                          ? _getStockTransList(context, _searchList, sizingInfo)
                          : _getStockTransList(
                              context, _stockTransList, sizingInfo),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });

    if (!widget.fullScreen) return temp;

    return Scaffold(
      appBar: AppBar(
        title: Text("Stock Transactions"),
      ),
      body: temp,
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

  Widget _getStockTransList(BuildContext context, List<StockTrans> transList,
      SizingInformation sizingInfo) {
    if (_stockTransList.isEmpty)
      return Expanded(
        child: noDataContainer(
          title: "No Stock Transactions",
          message: "When you Add or Subtract stock it gets added to this list.",
          imgName: "undraw_empty",
        ),
      );

    if (transList.isEmpty)
      return Expanded(
        child: noDataContainer(
          title: "No Transaction Found",
          imgName: "undraw_no_data",
        ),
      );

    return Expanded(
      child: CupertinoScrollbar(
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: transList.length,
          itemBuilder: (context, counter) {
            return Row(
              children: [
                getFlexContainer(
                  transList[counter].type,
                  4,
                ),
                getFlexContainer(transList[counter].itemName, 4,
                    color: CustomColors.lightGrey),
                getFlexContainer(
                    formatter.format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(transList[counter].creationDate)),
                    ),
                    4),
                getFlexContainer(
                  transList[counter].quantity.toString(),
                  3,
                  alignment: Alignment.centerRight,
                  color: CustomColors.lightGrey,
                ),
                getFlexContainer(getShortForm(transList[counter].unit), 2),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _getHeaderRow() {
    return Row(
      children: [
        getFlexContainer(
          "TYPE",
          4,
          header: true,
        ),
        getFlexContainer(
          "NAME",
          4,
          header: true,
          color: CustomColors.lightGrey,
        ),
        getFlexContainer(
          "DATE",
          4,
          header: true,
        ),
        getFlexContainer(
          "QTY UPDATED",
          3,
          header: true,
          color: CustomColors.lightGrey,
        ),
        getFlexContainer(
          "UNIT",
          2,
          header: true,
        ),
      ],
    );
  }
}
