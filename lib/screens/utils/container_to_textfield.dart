import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/bills_model/offline_bill_items_model.dart';
import 'package:store_manager/screens/utils/decimal_input_text_formatter.dart';
import 'package:store_manager/screens/utils/theme.dart';

class ContainerToTextField extends StatefulWidget {
  final int counter;
  final bool leftBorder;
  final bool rightBorder;
  final bool readOnly;
  final bool numeric;
  final ContainerToTextFieldType type;

  const ContainerToTextField({
    Key key,
    this.leftBorder = false,
    this.rightBorder = false,
    this.readOnly = false,
    this.numeric = false,
    @required this.counter,
    @required this.type,
  }) : super(key: key);

  @override
  _ContainerToTextFieldState createState() => _ContainerToTextFieldState();
}

class _ContainerToTextFieldState extends State<ContainerToTextField> {
  bool isClicked = false;
  TextEditingController controller;
  OfflineBillItemsModel _offlineBillItemsModel;
  FocusNode focusNode = FocusNode();
  String value = "";

  @override
  void initState() {
    focusNode.addListener(_onFocusChange);
    super.initState();
  }

  _onFocusChange() {
    if (!focusNode.hasFocus) {
      setState(() {
        isClicked = false;
      });
    }
  }

  _onSearchTextChanged(String text) {
    double val = (text.isNotEmpty) ? double.tryParse(text) : 0;
    _offlineBillItemsModel.updateOfflineBillItem(
      widget.counter,
      qty: widget.type == ContainerToTextFieldType.qty ? val : null,
      pricePerUnit:
          widget.type == ContainerToTextFieldType.pricePerUnit ? val : null,
      discount: widget.type == ContainerToTextFieldType.discount ? val : null,
      tax: widget.type == ContainerToTextFieldType.tax ? val : null,
    );
  }

  @override
  void didChangeDependencies() {
    _offlineBillItemsModel = Provider.of<OfflineBillItemsModel>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    value = _getValueAccToType();
    return InkWell(
      focusColor: Colors.transparent,
      onTap: () {
        if (isClicked) return;
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        controller = new TextEditingController(text: value == "0" ? "" : value);
        setState(() {
          isClicked = true;
        });
        focusNode.requestFocus();
      },
      child: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          border: Border(
            left: (widget.leftBorder)
                ? BorderSide(color: Colors.grey)
                : BorderSide.none,
            right: (widget.rightBorder)
                ? BorderSide(color: Colors.grey)
                : BorderSide.none,
          ),
        ),
        child: (isClicked)
            ? TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                readOnly: widget.readOnly,
                textAlign: (widget.numeric) ? TextAlign.end : TextAlign.start,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                inputFormatters: [
                  (widget.numeric)
                      ? DecimalTextInputFormatter(decimalRange: 4)
                      : null,
                ],
                textInputAction: TextInputAction.next,
                onChanged: _onSearchTextChanged,
                onSubmitted: (_) {
                  focusNode.unfocus();
                },
              )
            : ListTile(
                title: Container(
                  child: Text(value),
                  alignment: Alignment.centerRight,
                ),
              ),
      ),
    );
  }

  String _getValueAccToType() {
    String val = "";
    if (widget.type == ContainerToTextFieldType.qty) {
      val = _offlineBillItemsModel
          .getOfflineBillItem(widget.counter)
          .qty
          .toString();
    } else if (widget.type == ContainerToTextFieldType.pricePerUnit) {
      val = _offlineBillItemsModel
          .getOfflineBillItem(widget.counter)
          .pricePerUnit
          .toString();
    } else if (widget.type == ContainerToTextFieldType.discount) {
      val = _offlineBillItemsModel
          .getOfflineBillItem(widget.counter)
          .discount
          .toString();
    } else if (widget.type == ContainerToTextFieldType.tax) {
      val = _offlineBillItemsModel
          .getOfflineBillItem(widget.counter)
          .tax
          .toString();
    } else if (widget.type == ContainerToTextFieldType.amt) {
      val = _offlineBillItemsModel
          .getOfflineBillItem(widget.counter)
          .amt
          .toString();
    }
    return val;
  }
}
