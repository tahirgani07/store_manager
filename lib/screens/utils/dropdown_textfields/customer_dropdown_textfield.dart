import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/customer_model/customer_model.dart';
import 'package:store_manager/screens/customer_screen/customer_screen_alert_dialog.dart';

class CustomerDropDownTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final double addWidth;
  final List<Customer> customersList;

  const CustomerDropDownTextField({
    Key key,
    @required this.controller,
    @required this.labelText,
    this.addWidth = 100,
    @required this.customersList,
  }) : super(key: key);

  @override
  _DropDownTextFieldState createState() => _DropDownTextFieldState();
}

class _DropDownTextFieldState extends State<CustomerDropDownTextField> {
  GlobalKey _textFieldKey;
  double width, height, xPosition, yPosition;
  OverlayEntry overlayDropdown;
  FocusNode _focusNode = new FocusNode();
  List<Customer> _searchList = [];
  String uid;

  @override
  void initState() {
    _textFieldKey = LabeledGlobalKey(widget.labelText);
    _focusNode.addListener(_onFocusChange);
    super.initState();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      overlayDropdown.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    uid = Provider.of<User>(context).uid;
    return TextField(
      key: _textFieldKey,
      focusNode: _focusNode,
      controller: widget.controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: widget.labelText ?? "",
        isDense: true,
      ),
      onChanged: _onSearchTextChanged,
    );
  }

  _showOverlay() {
    findDropdownData();
    overlayDropdown = _createFloatingDropdown(context);
    Overlay.of(context).insert(overlayDropdown);
  }

  OverlayEntry _createFloatingDropdown(BuildContext context) {
    return OverlayEntry(builder: (context) {
      int listLength = (widget.controller.text.isNotEmpty)
          ? _searchList.length
          : widget.customersList.length;
      // +1 for the last add row.
      listLength++;
      return Positioned(
        top: yPosition + height + 10,
        left: xPosition,
        width: width + widget.addWidth,
        child: Material(
          elevation: 8.0,
          child: Container(
            height: (listLength > 4) ? 4 * height : listLength * height,
            child: (widget.controller.text.isNotEmpty)
                ? _getList(_searchList)
                : _getList(widget.customersList),
          ),
        ),
      );
    });
  }

  _getList(List<Customer> reqList) {
    return ListView.builder(
        itemCount: reqList.length + 1,
        itemBuilder: (context, counter) {
          String fullName = "";
          if (counter > 0)
            fullName = reqList[counter - 1].firstName +
                " " +
                reqList[counter - 1].lastName;
          return (counter > 0)
              ? InkWell(
                  onTap: () {
                    widget.controller.text = fullName;
                    _focusNode.unfocus();
                  },
                  child: Container(
                    height: height,
                    child: ListTile(
                      title: Text(fullName),
                    ),
                  ),
                )
              : _addNewCustomerListTile();
        });
  }

  Widget _addNewCustomerListTile() {
    return Container(
      height: height,
      child: ListTile(
        title: RaisedButton(
            child: Text("Add New Customer"),
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () {
              showAddCustomerDialog(context, uid, name: widget.controller.text);
              widget.controller.clear();
              _focusNode.unfocus();
            }),
      ),
    );
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
    widget.customersList.forEach((customer) {
      {
        String name = customer.firstName.toLowerCase() +
            " " +
            customer.lastName.toLowerCase();
        if (name.contains(text)) _searchList.add(customer);
      }
      setState(() {});
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
