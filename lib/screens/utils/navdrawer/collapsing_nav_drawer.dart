import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:store_manager/models/auth_service.dart';
import 'package:store_manager/models/navigation_model.dart';
import 'package:store_manager/screens/utils/navdrawer/collapsing_list_tile.dart';
import 'package:store_manager/screens/utils/theme.dart';

class CollapsingNavigationDrawer extends StatefulWidget {
  final Function(String, bool) onSelectTab;

  const CollapsingNavigationDrawer({Key key, @required this.onSelectTab})
      : super(key: key);

  @override
  _CollapsingNavigationDrawerState createState() =>
      _CollapsingNavigationDrawerState();
}

class _CollapsingNavigationDrawerState extends State<CollapsingNavigationDrawer>
    with SingleTickerProviderStateMixin {
  bool isCollapsed = false;
  AnimationController _animationController;
  Animation<double> widthAnimation;
  String name;
  Color drawerBgColor = Color(0xFF051E34);

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
    name = Provider.of<User>(context).displayName;

    Function(String, bool) onSelectTab = widget.onSelectTab;

    return SafeArea(
      child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, widget) {
            return Container(
              width: widthAnimation.value,
              color: drawerBgColor,
              child: Column(
                children: [
                  CollapsingListTile(
                    isUsernameTile: true,
                    title: "$name",
                    icon: Icons.person,
                    animationController: _animationController,
                  ),
                  Divider(height: 50, color: Colors.white70, thickness: 0.3),
                  Expanded(
                    child: Consumer<NavigationModel>(
                        builder: (context, navigationModel, _) {
                      return ListView.separated(
                        separatorBuilder: (context, counter) {
                          return Divider(height: 12.0);
                        },
                        itemBuilder: (context, counter) {
                          return CollapsingListTile(
                            onTap: () {
                              bool sameTabPressed = false;
                              if (navigationModel.currentScreenIndex == counter)
                                sameTabPressed = true;
                              onSelectTab(navigationItems[counter].routeName,
                                  sameTabPressed);
                            },
                            isSelected:
                                navigationModel.currentScreenIndex == counter,
                            title: navigationItems[counter].title,
                            icon: navigationItems[counter].icon,
                            animationController: _animationController,
                          );
                        },
                        itemCount: navigationItems.length,
                      );
                    }),
                  ),
                  Divider(height: 20, color: Colors.white70, thickness: 0.3),
                  CollapsingListTile(
                    isLogoutTile: true,
                    title: "Sign Out",
                    icon: Icons.logout,
                    onTap: () => AuthService().signOut(),
                    animationController: _animationController,
                  ),
                  Divider(height: 20, color: Colors.white70, thickness: 0.3),
                  ResponsiveBuilder(
                    builder: (context, sizeInfo) {
                      if (sizeInfo.isDesktop) {
                        return Container(
                          padding: EdgeInsets.only(right: 25),
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                isCollapsed = !isCollapsed;
                                isCollapsed
                                    ? _animationController.forward()
                                    : _animationController.reverse();
                              });
                            },
                            child: AnimatedIcon(
                              icon: AnimatedIcons.arrow_menu,
                              progress: _animationController,
                              color: Colors.white,
                              size: 20.0,
                            ),
                          ),
                        );
                      } else
                        return SizedBox();
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          }),
    );
  }
}
