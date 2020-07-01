import 'package:flutter/material.dart';

class OrderProvider with ChangeNotifier {
  int _selectedPaymentMethod;
  


  OrderProvider() {
    _selectedPaymentMethod = 0;
    
  }

  int get getSelectedPaymentMethod => _selectedPaymentMethod;


  void setPaymentMethod(int id) {
    _selectedPaymentMethod = id;
    notifyListeners();
  }

}