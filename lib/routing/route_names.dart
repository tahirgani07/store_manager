const String BillTransRoute = "/bill_transactions";
const String AddBillRoute = "/add_bill";
const String CustomersRoute = "/customers";
const String StocksRoute = "/stocks";
const String StockTransRoute = "/stock_transactions";
const String ErrorRoute = "/error";

const Map<int, String> getRouteFromIndex = {
  0: BillTransRoute,
  1: StocksRoute,
  2: CustomersRoute,
  3: ErrorRoute,
};

const Map<String, int> getIndexFromRoute = {
  BillTransRoute: 0,
  StocksRoute: 1,
  CustomersRoute: 2,
  ErrorRoute: 3,
};
