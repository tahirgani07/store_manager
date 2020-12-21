import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:store_manager/models/stocks_model/stock_items_model.dart';
import 'package:store_manager/models/stocks_model/stock_trans_model.dart';
import 'package:store_manager/models/unit_model.dart';
import 'package:store_manager/screens/utils/loading_screen.dart';
import 'package:store_manager/screens/utils/theme.dart';

//---------------------ADD NEW ITEM-----------------------
Future<void> showAddItemDialog(BuildContext context, String uid,
    {String name = ""}) async {
  String unitDropDown = "BAGS";
  bool loading = false;
  TextEditingController itemNameController = TextEditingController(text: name);
  TextEditingController pricePerUnitController = TextEditingController();
  TextEditingController openingStockController = TextEditingController();

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            elevation: 8.0,
            contentPadding: EdgeInsets.all(10.0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ADD NEW ITEM"),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: 1,
                ),
              ],
            ),
            content: Container(
              width: 500,
              child: loading
                  ? LoadingScreen(message: "Adding Item Please wait...")
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          customTextField(
                            label: "ITEM NAME",
                            controller: itemNameController,
                            autofocus: true,
                          ),
                          Container(
                            margin: EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Text("SELECT A UNIT"),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: DropdownButton(
                                      isExpanded: true,
                                      underline: SizedBox(),
                                      value: unitDropDown,
                                      items: unitList.map((unit) {
                                        return DropdownMenuItem(
                                          value: unit,
                                          child: Text(unit),
                                        );
                                      }).toList(),
                                      onChanged: (String newVal) =>
                                          setState(() {
                                        unitDropDown = newVal;
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          customTextField(
                            label: "PRICE PER UNIT",
                            controller: pricePerUnitController,
                            numeric: true,
                          ),
                          customTextField(
                            label: "OPENING STOCK",
                            controller: openingStockController,
                            numeric: true,
                          ),
                        ],
                      ),
                    ),
            ),
            actions: <Widget>[
              alertActionButton(
                context: context,
                title: "Add Item",
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  setState(() => loading = true);
                  await ItemsModel().addItem(
                    uid: uid,
                    name: itemNameController.text,
                    unit: unitDropDown,
                    pricePerUnit: double.tryParse(pricePerUnitController.text),
                    remainingStock:
                        double.tryParse(openingStockController.text),
                  );
                  setState(() => loading = false);
                  Navigator.of(context).pop();
                },
              ),
              alertActionButton(context: context),
            ],
          );
        },
      );
    },
  );
}

//---------------------STOCK DETAILS-----------------------
Future<void> showStockDetailsDialog(
    BuildContext context, String uid, Items item) async {
  return showDialog<void>(
    context: context,
    //barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('${item.name}'),
        content: SingleChildScrollView(
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Unit - ${item.unit}'),
                  Text('Price Per ${item.unit} - ${item.pricePerUnit}'),
                  Text('Remaining Stock - ${item.remainingStock}'),
                  Text('Stock Sold- ${item.stockSold}'),
                ],
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                height: 100,
                width: 100,
                child: QrImage(
                  data: item.creationDate,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          alertActionButton(
            context: context,
            title: "Add Stock",
            color: Colors.green,
            onPressed: () {
              Navigator.of(context).pop();
              updateStockDialog(context, uid, item, StockTransType.add);
            },
          ),
          alertActionButton(
              context: context,
              title: "Reduce Stock",
              color: Colors.yellow,
              onPressed: () {
                Navigator.of(context).pop();
                updateStockDialog(context, uid, item, StockTransType.reduce);
              }),
          alertActionButton(context: context),
        ],
      );
    },
  );
}

//---------------------------ADD STOCK-----------------------------
Future<void> updateStockDialog(
    BuildContext context, String uid, Items item, StockTransType type) async {
  TextEditingController updateStockVal = TextEditingController();
  bool loading = false;
  return showDialog<void>(
    context: context,
    //barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: type == StockTransType.add
                ? Text('Add Stocks - ${item.name}')
                : Text('Reduce Stocks - ${item.name}'),
            content: Container(
              width: 500,
              child: loading
                  ? LoadingScreen(message: "Updating Stocks Please wait...")
                  : SingleChildScrollView(
                      child: customTextField(
                        label: "Quantity",
                        controller: updateStockVal,
                        autofocus: true,
                        numeric: true,
                      ),
                    ),
            ),
            actions: <Widget>[
              alertActionButton(
                context: context,
                title:
                    type == StockTransType.add ? "Add Stock" : "Reduce Stock",
                color:
                    type == StockTransType.add ? Colors.green : Colors.yellow,
                onPressed: () async {
                  setState(() => loading = true);
                  await ItemsModel().addStock(
                    uid: uid,
                    item: item,
                    qty: double.tryParse(updateStockVal.text),
                    type: type,
                  );
                  setState(() => loading = false);
                  Navigator.of(context).pop();
                },
              ),
              alertActionButton(context: context),
            ],
          );
        },
      );
    },
  );
}
