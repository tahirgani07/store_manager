import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:store_manager/screens/utils/CustomTextStyle.dart';
import 'package:store_manager/screens/utils/decimal_input_text_formatter.dart';
import 'package:store_manager/screens/utils/marquee_widget.dart';

// Collapsing Navigation Drawer
double navMaxWidth = 200;
double navMinWidth = 70;
double desktopWidth = 1000;
double naveSizeToHideText = 180;

//-------------Billing Scren-------------
double numWidth = 45;
double itemWidth = 675;
double qtyWidth = 112;
double unitWidth = 112;
double pricePerUnitWidth = 140;
double discountWidth = 140;
double taxWidth = 180;
double amountWidth = 112;

extension StringExtension on String {
  String get inCaps =>
      '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach =>
      this.split(" ").map((str) => str.inCaps).join(" ");
}

Widget customTextField({
  String label,
  TextEditingController controller,
  int maxLines = 1,
  bool autofocus = false,
  bool readOnly = false,
  Function onTap,
  Function(String) onChanged,
  bool numeric = false,
  String name = "",
  TextStyle textStyle,
  TextAlign textAlign,
  EdgeInsetsGeometry contentPadding,
  bool noMargin = false,
  bool enabled = true,
}) {
  return Container(
    margin: noMargin ? EdgeInsets.zero : EdgeInsets.all(10.0),
    child: TextField(
      readOnly: readOnly,
      onTap: onTap,
      enabled: enabled,
      onChanged: onChanged,
      autofocus: autofocus,
      controller: controller,
      inputFormatters: (numeric)
          ? <TextInputFormatter>[
              DecimalTextInputFormatter(decimalRange: 5),
            ]
          : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
        isDense: true,
        alignLabelWithHint: true,
        contentPadding: contentPadding,
      ),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      style: textStyle,
    ),
  );
}

Widget addSomethingButton(
    {@required BuildContext context, String text, Function onPressed}) {
  return RaisedButton(
    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
    shape: RoundedRectangleBorder(
      borderRadius: new BorderRadius.circular(30.0),
    ),
    onPressed: onPressed,
    color: Colors.blue,
    textColor: Colors.white,
    child: Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
          child: Icon(Icons.add, size: 18),
        ),
        SizedBox(width: 8),
        Text(text ?? ""),
      ],
    ),
  );
}

Widget alertActionButton({
  @required BuildContext context,
  @required SizingInformation sizingInfo,
  String title,
  Color color,
  Function onPressed,
}) {
  if (!sizingInfo.isDesktop && !sizingInfo.isTablet && title == null)
    return SizedBox();

  return RaisedButton(
    padding: sizingInfo.isDesktop
        ? EdgeInsets.symmetric(horizontal: 30, vertical: 15)
        : EdgeInsets.symmetric(horizontal: 5, vertical: 3),
    color: color ?? Colors.red,
    child: Text(title ?? "Close"),
    onPressed: onPressed ?? () => Navigator.of(context).pop(),
  );
}

showOnlyForDesktop({
  @required SizingInformation sizingInfo,
  @required Widget widgetDesk,
  Widget widgetMob,
}) {
  if (sizingInfo.isDesktop) return widgetDesk;
  if (widgetMob == null) return SizedBox();
  return widgetMob;
}

Widget getSearchBar(
  TextEditingController controller,
  Function onSearchTextChanged,
) {
  return Container(
    height: 35,
    alignment: Alignment.center,
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        // hintText: 'Search',
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
        contentPadding: EdgeInsets.symmetric(vertical: 13),
        isDense: true,
        prefixIcon: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Icon(Icons.search, size: 20),
        ),
        prefixIconConstraints: BoxConstraints(maxWidth: 30, maxHeight: 30),
        alignLabelWithHint: true,
      ),
      style: TextStyle(
        fontSize: 14,
      ),
      onChanged: onSearchTextChanged,
    ),
  );
}

getFlexContainer(
  String title,
  int flex, {
  double height = 40,
  Color color,
  Alignment alignment,
  bool header = false,
}) {
  return Flexible(
    flex: flex,
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
        child: Text(
          title,
          style: (header)
              ? CustomTextStyle.grey_bold_small
              : TextStyle(
                  fontSize: 13,
                  color: CustomColors.darkBlue,
                  fontWeight: FontWeight.bold,
                ),
        ),
      ),
    ),
  );
}

Widget noDataContainer({
  String title = "",
  String message = "",
  String imgName = "undraw_empty",
  double topForText = 10,
}) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Image.asset(
        "assets/images/$imgName.png",
        fit: BoxFit.contain,
      ),
      Positioned(
        top: topForText,
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 30,
                color: CustomColors.darkBlue,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              message,
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ],
  );
}
