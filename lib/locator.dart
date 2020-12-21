import 'package:get_it/get_it.dart';
import 'package:store_manager/screens/billing_screen/bill_main_screen.dart';
import 'package:store_manager/services/navigation_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerFactory(() => BillMainScreen());
}
