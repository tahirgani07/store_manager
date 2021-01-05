import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/bills_model/bill_model.dart';
import 'package:store_manager/models/bills_model/offline_bill_items_model.dart';
import 'package:store_manager/models/stocks_model/stock_items_model.dart';
import 'package:store_manager/models/unit_model.dart';
import 'package:store_manager/screens/stocks_screen/stock_screen_alert_dialogs.dart';
import 'package:store_manager/screens/utils/CustomTextStyle.dart';

class BillItemNameDropDownTextField extends StatefulWidget {
  final double addWidth;
  final List<Items> itemsList;
  final int counter;

  const BillItemNameDropDownTextField({
    Key key,
    this.addWidth = 100,
    @required this.itemsList,
    @required this.counter,
  }) : super(key: key);

  @override
  _DropDownTextFieldState createState() => _DropDownTextFieldState();
}

class _DropDownTextFieldState extends State<BillItemNameDropDownTextField> {
  GlobalKey _textFieldKey;
  double width, height, xPosition, yPosition;
  OverlayEntry overlayDropdown;
  List<Items> _searchList = [];
  String uid;
  BillModel billModel;
  TextEditingController nameController;
  FocusNode focusNode = FocusNode();
  bool isClicked = false;
  OfflineBillItemsModel _offlineBillItemsModel;
  BillItem currentOfflineBillItem;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    _textFieldKey = GlobalKey();
    focusNode.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _offlineBillItemsModel = Provider.of<OfflineBillItemsModel>(context);
    super.didChangeDependencies();
  }

  void _onFocusChange() {
    if (focusNode.hasFocus) {
      String itemName = nameController.text.toLowerCase();
      if (itemName.isNotEmpty) {
        _searchList.clear();
        widget.itemsList.forEach((item) {
          {
            if (item.name.toLowerCase().contains(itemName))
              _searchList.add(item);
          }
          setState(() {});
        });
      }
      _showOverlay();
    } else {
      overlayDropdown.remove();
      String text = (nameController != null) ? nameController.text : "";
      _searchItemAndSetFields(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    currentOfflineBillItem =
        _offlineBillItemsModel.getOfflineBillItem(widget.counter);
    uid = Provider.of<User>(context).uid;
    billModel = Provider.of<BillModel>(context) ?? BillModel();

    return InkWell(
      focusColor: Colors.transparent,
      onTap: () {
        if (isClicked) return;
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        nameController =
            new TextEditingController(text: currentOfflineBillItem.name);
        setState(() {
          isClicked = true;
        });
        focusNode.requestFocus();
      },
      child: Container(
        child: (isClicked)
            ? CompositedTransformTarget(
                link: _layerLink,
                child: TextField(
                  key: _textFieldKey,
                  focusNode: focusNode,
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        gapPadding: 0, borderRadius: BorderRadius.zero),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                  style: CustomTextStyle.blue_bold_med,
                  maxLines: 1,
                  onChanged: _onSearchTextChanged,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => focusNode.unfocus(),
                ),
              )
            : Container(
                child: Text(
                  currentOfflineBillItem.name,
                  style: CustomTextStyle.blue_bold_med,
                ),
                alignment: Alignment.centerLeft,
              ),
      ),
    );
  }

  _showOverlay() {
    findDropdownData();
    overlayDropdown = _createFloatingDropdown(context);
    Overlay.of(context).insert(overlayDropdown);
  }

  OverlayEntry _createFloatingDropdown(BuildContext context) {
    return OverlayEntry(
      builder: (context) {
        int listLength = (nameController.text.isNotEmpty)
            ? _searchList.length
            : widget.itemsList.length;
        // +1 for the last add row.
        listLength++;
        return Positioned(
          top: yPosition + height + 10,
          left: xPosition,
          width: width + widget.addWidth,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, height + 5.0),
            child: Material(
              elevation: 8.0,
              child: Container(
                height: (listLength > 4)
                    ? 4 * (height + 10)
                    : listLength * (height + 10),
                child: (nameController.text.isNotEmpty)
                    ? _getList(_searchList)
                    : _getList(widget.itemsList),
              ),
            ),
          ),
        );
      },
    );
  }

  _getList(List<Items> reqList) {
    return ListView.builder(
        itemCount: reqList.length + 1,
        itemBuilder: (context, counter) {
          String name = "";
          if (counter > 0) name = reqList[counter - 1].name;
          return (counter > 0)
              ? InkWell(
                  onTap: () {
                    overlayDropdown.remove();
                    _searchItemAndSetFields(name);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    height: (height + 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : _addNewItemListTile();
        });
  }

  Widget _addNewItemListTile() {
    return Container(
      height: (height + 10),
      child: ListTile(
        title: RaisedButton(
            child: Text("Add New Item"),
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () {
              showAddItemDialog(context, uid, name: nameController.text);
              nameController.clear();
              focusNode.unfocus();
            }),
      ),
    );
  }

  _onSearchTextChanged(String text) {
    if (overlayDropdown != null) overlayDropdown.remove();
    _searchList.clear();
    if (text.isEmpty) {
      setState(() {});
      // return;
    } else {
      text = text.toLowerCase();
      widget.itemsList.forEach((item) {
        {
          if (item.name.toLowerCase().contains(text)) _searchList.add(item);
        }
        setState(() {});
      });
    }
    _showOverlay();
  }

  void findDropdownData() {
    RenderBox render = _textFieldKey.currentContext.findRenderObject();
    width = render.size.width;
    height = render.size.height;
    Offset offset = render.localToGlobal(Offset.zero);
    xPosition = offset.dx;
    yPosition = offset.dy;
  }

  _searchItemAndSetFields(String text) {
    Items item;
    widget.itemsList.forEach((i) {
      if (i.name.toLowerCase() == text.toLowerCase()) {
        item = i;
        return;
      }
    });
    if (item != null) {
      // widget.pricePerUnitController.text = item.pricePerUnit.toString();
      // widget.qtyController.text = "1";
      // widget.unitController.text = getShortForm(item.unit);
      _offlineBillItemsModel.updateOfflineBillItem(
        widget.counter,
        name: item.name,
        unit: getShortForm(item.unit),
        // qty: 1,
        pricePerUnit: item.pricePerUnit,
      );
      billModel.changeUnitReadOnlyListinBillItem(widget.counter, true);
    } else {
      _offlineBillItemsModel.updateOfflineBillItem(
        widget.counter,
        pricePerUnit: 0,
        name: text,
        unit: "",
      );
      billModel.changeUnitReadOnlyListinBillItem(widget.counter, false);
    }
    setState(() {
      isClicked = false;
    });
  }
}
