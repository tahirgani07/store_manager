import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_manager/locator.dart';
import 'package:store_manager/models/navigation_model.dart';
import 'package:store_manager/routing/route_names.dart';
import 'package:store_manager/services/navigation_service.dart';

class ErrorScreen extends StatefulWidget {
  @override
  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  NavigationModel navigationModel;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigationModel = Provider.of<NavigationModel>(context, listen: false);
      int index = 3;

      bool sameTab = navigationModel.currentScreenIndex == index;

      navigationModel.updateCurrentScreenIndex(index);

      if (!sameTab) navigationModel.addToStack(index);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        int lastIndex = 0;
        if (navigationModel.indexStack.length > 1) {
          lastIndex = navigationModel.popFromStack();
          navigationModel.updateCurrentScreenIndex(lastIndex);
          return true;
        } else {
          navigationModel.resetIndexStack();
          if (navigationModel.currentScreenIndex != lastIndex) {
            navigationModel.updateCurrentScreenIndex(lastIndex);
            locator<NavigationService>().navigateTo(BillTransRoute, true);
          }
          return false;
        }
      },
      child: Center(
        child: Container(
          color: Colors.white,
          child: Text("ERROR"),
        ),
      ),
    );
  }
}
