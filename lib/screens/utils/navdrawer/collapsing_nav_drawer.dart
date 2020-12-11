import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/auth_service.dart';
import 'package:store_manager/models/navigation_model.dart';
import 'package:store_manager/screens/utils/navdrawer/collapsing_list_tile.dart';
import 'package:store_manager/screens/utils/theme.dart';

class CollapsingNavigationDrawer extends StatefulWidget {
  @override
  _CollapsingNavigationDrawerState createState() =>
      _CollapsingNavigationDrawerState();
}

class _CollapsingNavigationDrawerState extends State<CollapsingNavigationDrawer>
    with SingleTickerProviderStateMixin {
  bool isCollapsed = false;
  AnimationController _animationController;
  Animation<double> widthAnimation;
  int currentSelectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    widthAnimation = Tween<double>(begin: navMaxWidth, end: navMinWidth)
        .animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, widget) => getWidget(context, widget),
    );
  }

  Widget getWidget(context, widget) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: widthAnimation.value,
      color: drawerBgColor,
      child: Column(
        children: [
          CollapsingListTile(
            title: "Tahir Gani",
            icon: Icons.person,
            animationController: _animationController,
          ),
          RaisedButton(
            onPressed: () => AuthService().signOut(),
            child: Text("Sign Out"),
          ),
          Divider(height: 40.0, color: Colors.grey),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, counter) {
                return Divider(height: 12.0);
              },
              itemBuilder: (context, counter) {
                return Consumer<NavigationModel>(
                    builder: (context, data, child) {
                  return CollapsingListTile(
                    onTap: () {
                      data.updateScreenIndex(counter);
                      if (screenWidth <= desktopWidth) Navigator.pop(context);
                    },
                    isSelected: data.getScreenIndex() == counter,
                    title: navigationItems[counter].title,
                    icon: navigationItems[counter].icon,
                    animationController: _animationController,
                  );
                });
              },
              itemCount: navigationItems.length,
            ),
          ),
          screenWidth <= desktopWidth
              ? SizedBox()
              : Consumer<NavigationModel>(builder: (context, data, child) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        isCollapsed = !isCollapsed;
                        isCollapsed
                            ? _animationController.forward()
                            : _animationController.reverse();
                        data.toggleIsCollapsed();
                      });
                    },
                    child: AnimatedIcon(
                      icon: AnimatedIcons.close_menu,
                      progress: _animationController,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  );
                }),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
