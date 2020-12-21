import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/models/auth_service.dart';
import 'package:store_manager/models/navigation_model.dart';
import 'package:store_manager/screens/utils/navdrawer/collapsing_list_tile.dart';
import 'package:store_manager/screens/utils/theme.dart';

class CollapsingNavigationDrawer extends StatefulWidget {
  final Function(String) onSelectTab;

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
    double screenWidth = MediaQuery.of(context).size.width;
    name = Provider.of<User>(context).displayName;

    Function(String) onSelectTab = widget.onSelectTab;

    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, widget) {
          return Container(
            width: widthAnimation.value,
            color: drawerBgColor,
            child: Column(
              children: [
                CollapsingListTile(
                  title: "$name",
                  icon: Icons.person,
                  animationController: _animationController,
                ),
                RaisedButton(
                  onPressed: () => AuthService().signOut(),
                  child: Text("Sign Out"),
                ),
                Divider(height: 40.0, color: Colors.grey),
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
                            if (navigationModel.currentScreenIndex == counter)
                              return;
                            navigationModel.updateCurrentScreenIndex(counter);
                            navigationModel.addToStack(counter);
                            onSelectTab(navigationItems[counter].routeName);
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
                screenWidth <= desktopWidth
                    ? SizedBox()
                    : InkWell(
                        onTap: () {
                          setState(() {
                            isCollapsed = !isCollapsed;
                            isCollapsed
                                ? _animationController.forward()
                                : _animationController.reverse();
                          });
                        },
                        child: AnimatedIcon(
                          icon: AnimatedIcons.close_menu,
                          progress: _animationController,
                          color: Colors.white,
                          size: 20.0,
                        ),
                      ),
                SizedBox(height: 50),
              ],
            ),
          );
        });
  }
}
