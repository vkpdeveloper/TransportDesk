import 'package:flutter/material.dart';

class OrderProvider with ChangeNotifier {
  bool _isPicked;
  bool _isDropped;
  String _orderPrice;

  OrderProvider() {
    _isPicked = false;
    _isDropped = false;
    _orderPrice = "";
  }

  bool get getIsPicked => _isPicked;
  bool get getIsDropped => _isDropped;
  String get getOrderPrice => _orderPrice;

  void setIsPicked(bool picked) {
    _isPicked = picked;
    notifyListeners();
  }

  void setIsDropped(bool drop) {
    _isDropped = drop;
    notifyListeners();
  }

  void setOrderPrice(String price) {
    _orderPrice = price;
    notifyListeners();
  }
}
