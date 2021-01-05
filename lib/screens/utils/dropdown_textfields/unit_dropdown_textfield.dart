import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/bills_model/offline_bill_items_model.dart';
import 'package:store_manager/models/unit_model.dart';
import 'package:store_manager/screens/utils/CustomTextStyle.dart';
import 'package:store_manager/screens/utils/theme.dart';

class UnitDropDownTextField extends StatefulWidget {
  final int counter;
  final double addWidth;
  final bool readOnly;

  const UnitDropDownTextField({
    Key key,
    @required this.counter,
    this.addWidth = 150,
    this.readOnly = false,
  }) : super(key: key);

  @override
  _DropDownTextFieldState createState() => _DropDownTextFieldState();
}

class _DropDownTextFieldState extends State<UnitDropDownTextField> {
  GlobalKey _textFieldKey;
  double width, height, xPosition, yPosition;
  OverlayEntry overlayDropdown;
  List<String> _searchList = [];
  List<String> unitsList;
  List<String> shortFormUnitsList;
  String uid;
  TextEditingController searchUnitController;
  OfflineBillItemsModel _offlineBillItemsModel;
  FocusNode focusNode = FocusNode();
  bool isClicked = false;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    _textFieldKey = GlobalKey();
    focusNode.addListener(_onFocusChange);
    unitsList = unitList;
    shortFormUnitsList = unitsList.map((unit) => getShortForm(unit)).toList();
    super.initState();
  }

  void _onFocusChange() {
    if (focusNode.hasFocus) {
      String name = searchUnitController.text.toLowerCase();
      if (name.isNotEmpty) {
        _searchList.clear();
        unitsList.forEach((unit) {
          {
            if (unit.toLowerCase().contains(name) ||
                getShortForm(unit).toLowerCase().contains(name))
              _searchList.add(unit);
          }
        });
      }
      _showOverlay();
    } else {
      searchUnitController.text = searchUnitController.text.toUpperCase();
      bool inUnitList = unitsList.contains(searchUnitController.text);
      bool inShotFormUnitList =
          shortFormUnitsList.contains(searchUnitController.text);
      if (searchUnitController.text.isEmpty) {
      } else {
        if (!inUnitList && !inShotFormUnitList) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Error"),
                  content: Text("Select a Unit from the DropDown"),
                  actions: [
                    alertActionButton(context: context),
                  ],
                );
              });
          searchUnitController.clear();
        } else if (!inUnitList) {
          _onSubmitted(searchUnitController.text);
        } else {
          _onSubmitted(getShortForm(searchUnitController.text));
        }
      }
      overlayDropdown.remove();
      setState(() {
        isClicked = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    _offlineBillItemsModel = Provider.of<OfflineBillItemsModel>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    uid = Provider.of<User>(context).uid;
    return InkWell(
      focusColor: Colors.transparent,
      onTap: () {
        if (isClicked) return;
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        searchUnitController = new TextEditingController(
            text:
                _offlineBillItemsModel.getOfflineBillItem(widget.counter).unit);
        setState(() {
          isClicked = true;
        });
        focusNode.requestFocus();
      },
      child: Container(
        child: isClicked
            ? CompositedTransformTarget(
                link: _layerLink,
                child: TextField(
                  key: _textFieldKey,
                  readOnly: widget.readOnly,
                  autofocus: true,
                  focusNode: focusNode,
                  controller: searchUnitController,
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
                  _offlineBillItemsModel
                      .getOfflineBillItem(widget.counter)
                      .unit,
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
    return OverlayEntry(builder: (context) {
      int listLength = (searchUnitController.text.isNotEmpty)
          ? _searchList.length
          : unitsList.length;
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
              child: (searchUnitController.text.isNotEmpty)
                  ? _getList(_searchList)
                  : _getList(unitsList),
            ),
          ),
        ),
      );
    });
  }

  _getList(List<String> reqList) {
    return ListView.builder(
        itemCount: reqList.length,
        itemBuilder: (context, counter) {
          String name = reqList[counter];
          String shortName = getShortForm(name);
          return InkWell(
            onTap: () {
              _onSubmitted(shortName);
              focusNode.unfocus();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: (height + 10),
              alignment: Alignment.centerLeft,
              child: Text(
                "$name ($shortName)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        });
  }

  _onSearchTextChanged(String text) {
    if (overlayDropdown != null) overlayDropdown.remove();
    _showOverlay();
    _searchList.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    text = text.toLowerCase();
    unitsList.forEach((unit) {
      {
        if (unit.toLowerCase().contains(text) ||
            getShortForm(unit).toLowerCase().contains(text))
          _searchList.add(unit);
      }
      setState(() {});
    });
  }

  _onSubmitted(String shortUnit) {
    if (!widget.readOnly) {
      _offlineBillItemsModel.updateOfflineBillItem(
        widget.counter,
        unit: shortUnit,
      );
    }
    setState(() {
      isClicked = false;
    });
  }

  void findDropdownData() {
    RenderBox render = _textFieldKey.currentContext.findRenderObject();
    width = render.size.width;
    height = render.size.height;
    Offset offset = render.localToGlobal(Offset.zero);
    xPosition = offset.dx;
    yPosition = offset.dy;
  }
}
