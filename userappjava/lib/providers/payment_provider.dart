import 'package:flutter/material.dart';

class PaymentProvider with ChangeNotifier {
  String _amount = "";
  String _phoneno = "";
  String _emailid = "";
  String _orderID = "";
  String _pickUpPin = "";
  String _dropPin = "";

  Future<bool> paymentinit(String amount, String phoneno, String emailid,
      String orderID, String pickUpPin, String dropPin) async {
    _amount = amount;
    _phoneno = phoneno;
    _emailid = emailid;
    _orderID = orderID;
    _pickUpPin = pickUpPin;
    _dropPin = dropPin;
    notifyListeners();
    return true;
  }

  String get getAmount => _amount;
  String get getPhoneNo => _phoneno;
  String get getEmailID => _emailid;
  String get getOrderId => _orderID;
  String get getPickUpPin => _pickUpPin;
  String get getDropUpPin => _dropPin;
}
