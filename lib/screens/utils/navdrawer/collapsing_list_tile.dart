import 'package:flutter/material.dart';
import 'package:store_manager/screens/utils/marquee_widget.dart';
import 'package:store_manager/screens/utils/theme.dart';

class CollapsingListTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final AnimationController animationController;
  final bool isSelected;
  final Function onTap;
  final bool isUsernameTile;
  final bool isLogoutTile;

  CollapsingListTile({
    @required this.title,
    @required this.icon,
    @required this.animationController,
    this.isSelected = false,
    this.onTap,
    this.isUsernameTile: false,
    this.isLogoutTile: false,
  });

  @override
  _CollapsingListTileState createState() => _CollapsingListTileState();
}

class _CollapsingListTileState extends State<CollapsingListTile> {
  Color selectedColor = Color(0xFF669DF6);
  Color defaultColor = Color(0xFFBCC3CA);

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
              ? Colors.white.withOpacity(0.1)
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
            Icon(widget.icon, color: _getColor(), size: 20.0),
            (widthAnimation.value >= naveSizeToHideText)
                ? SizedBox(width: 10)
                : SizedBox(),
            (widthAnimation.value >= naveSizeToHideText)
                ? MarqueeWidget(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: _getColor(),
                        fontSize: 15.0,
                        // fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    if (widget.isUsernameTile) return Colors.white;
    if (widget.isLogoutTile) return Colors.red;
    if (widget.isSelected) return selectedColor;
    return defaultColor;
  }
}
