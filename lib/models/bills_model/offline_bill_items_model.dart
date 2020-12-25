import 'package:flutter/material.dart';
import 'package:store_manager/models/bills_model/bill_model.dart';

enum ContainerToTextFieldType {
  qty,
  pricePerUnit,
  discount,
  tax,
  amt,
}

class OfflineBillItemsModel extends ChangeNotifier {
  List<BillItem> _offlineBillItemsList = [];

  BillItem getOfflineBillItem(int index) => _offlineBillItemsList[index];
  int getLengthOfOfflineBillItemsList() => _offlineBillItemsList.length;

  void clearOfflineBillItemsList() {
    _offlineBillItemsList.clear();
    notifyListeners();
  }

  List<BillItem> getCompleteList() => _offlineBillItemsList;

  void addToOfflineBillItemsList(BillItem offlineBillItem) {
    _offlineBillItemsList.add(offlineBillItem);
    notifyListeners();
  }

  void removeFromOfflineBillItemsList(int index) {
    _offlineBillItemsList.removeAt(index);
    notifyListeners();
  }

  void updateOfflineBillItem(
    int index, {
    String name,
    double qty,
    String unit,
    double pricePerUnit,
    double discount,
    double tax,
    double amt,
  }) {
    if (name != null) _offlineBillItemsList[index].name = name;
    if (qty != null) _offlineBillItemsList[index].qty = qty;
    if (unit != null) _offlineBillItemsList[index].unit = unit;
    if (pricePerUnit != null)
      _offlineBillItemsList[index].pricePerUnit = pricePerUnit;
    if (discount != null) _offlineBillItemsList[index].discount = discount;
    if (tax != null) _offlineBillItemsList[index].tax = tax;

    if (qty != null ||
        pricePerUnit != null ||
        discount != null ||
        tax != null) {
      amtUpdate(index);
    }

    notifyListeners();
  }

  void amtUpdate(int index) {
    double qty = _offlineBillItemsList[index].qty;
    double pricePerUnit = _offlineBillItemsList[index].pricePerUnit;
    double discount = _offlineBillItemsList[index].discount;
    double tax = _offlineBillItemsList[index].tax;

    double amt = (qty * pricePerUnit) - discount + tax;

    _offlineBillItemsList[index].amt = amt;
    notifyListeners();
  }
}
