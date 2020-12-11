import 'package:flutter/material.dart';
import 'package:store_manager/screens/utils/theme.dart';

class CollapsingListTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final AnimationController animationController;
  final bool isSelected;
  final Function onTap;

  CollapsingListTile(
      {@required this.title,
      @required this.icon,
      @required this.animationController,
      this.isSelected = false,
      this.onTap});

  @override
  _CollapsingListTileState createState() => _CollapsingListTileState();
}

class _CollapsingListTileState extends State<CollapsingListTile> {
  @override
  Widget build(BuildContext context) {
    Animation<double> widthAnimation =
        Tween<double>(begin: navMaxWidth, end: navMinWidth)
            .animate(widget.animationController);

    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          color: (widget.isSelected)
              ? Colors.transparent.withOpacity(0.3)
              : Colors.transparent,
        ),
        width: widthAnimation.value,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: (widthAnimation.value >= naveSizeToHideText)
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(widget.icon,
                color: (widget.isSelected) ? selectedColor : Colors.white30,
                size: 20.0),
            (widthAnimation.value >= naveSizeToHideText)
                ? SizedBox(width: 10)
                : SizedBox(),
            (widthAnimation.value >= naveSizeToHideText)
                ? Text(widget.title,
                    style: (widget.isSelected)
                        ? listTileSelectedTextStyle
                        : listTileDefaultTextStyle)
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
