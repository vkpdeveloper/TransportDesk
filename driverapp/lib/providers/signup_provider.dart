import 'package:flutter/material.dart';

class SignUpProvider with ChangeNotifier {
  String _name;
  String _phone;
  String _vehicleName;
  String _vehicleNumber;
  bool _isDriver;
  String _cityName;
  String _gstin;

  SignUpProvider() {
    _name = "";
    _phone = "";
    _vehicleName = "";
    _vehicleNumber = "";
    _isDriver = false;
    _cityName = "";
    _gstin = "";
  }

  String get getName => _name;
  String get getPhone => _phone;
  String get getVehicleName => _vehicleName;
  String get getVehicleNumber => _vehicleNumber;
  bool get getIsDriver => _isDriver;
  String get getCityName => _cityName;
  String get getGstin => _gstin;

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setPhone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  void setCity(String city) {
    _cityName = city;
    notifyListeners();
  }

  void setVehicleName(String name) {
    _vehicleName = name;
    notifyListeners();
  }

  void setVehicleNumber(String number) {
    _vehicleNumber = number;
    notifyListeners();
  }

  void setIsDriver(bool isDriver) {
    _isDriver = isDriver;
    notifyListeners();
  }

  void setIGstin(String gstin) {
    _gstin = gstin;
    notifyListeners();
  }
}
