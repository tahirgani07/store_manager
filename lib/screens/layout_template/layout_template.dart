import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:store_manager/locator.dart';
import 'package:store_manager/models/navigation_model.dart';
import 'package:store_manager/screens/utils/navdrawer/collapsing_nav_drawer.dart';
import 'package:store_manager/screens/utils/navdrawer/toggle_nav_bar.dart';
import 'package:store_manager/services/navigation_service.dart';

class LayoutTemplate extends StatelessWidget {
  final Widget child;
  const LayoutTemplate({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => NavigationModel(),
              ),
              ChangeNotifierProvider(
                create: (context) => ToggleNavBar(),
              ),
            ],
            builder: (context, _) {
              final ToggleNavBar toggleNavBar = context.watch<ToggleNavBar>();
              return Scaffold(
                ///////////////////////// APP BAR
                appBar: (!sizingInfo.isDesktop)
                    ? AppBar(
                        title: Text("Stock Manager"),
                        leading: Builder(
                          builder: (BuildContext context) {
                            return IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () {
                                  Scaffold.of(context).openDrawer();
                                });
                          },
                        ),
                      )
                    : null,
                ////////////////////// DRAWER
                drawer: (!sizingInfo.isDesktop)
                    ? Builder(builder: (context) {
                        return CollapsingNavigationDrawer(
                          onSelectTab: (routeName) {
                            if (!sizingInfo.isDesktop)
                              Scaffold.of(context).openEndDrawer();
                            locator<NavigationService>().navigateTo(routeName);
                          },
                        );
                      })
                    : SizedBox(),
                ////////////////// BODY
                body: Row(
                  children: [
                    (toggleNavBar.getShow() && sizingInfo.isDesktop)
                        ? CollapsingNavigationDrawer(
                            onSelectTab: (routeName) {
                              locator<NavigationService>()
                                  .navigateTo(routeName);
                            },
                          )
                        : SizedBox(),
                    Expanded(
                      child: child,
                    ),
                  ],
                ),
              );
            });
      },
    );
  }
}
