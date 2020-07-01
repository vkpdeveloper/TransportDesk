import 'package:flutter/material.dart';

class VendorOrderManagerProvider with ChangeNotifier {
  GeoCoord _pickUpCords;
  GeoCoord _dropCords;
  GeoCoord _driverCords;
  String _pickUpAddress;
  String _dropAddress;
  bool _isStart = false;

  VendorOrderManagerProvider() {
    _pickUpAddress = "";
    _dropAddress = "";
  }

  GeoCoord get getPickUpCords => _pickUpCords;
  GeoCoord get getDropCords => _dropCords;
  GeoCoord get getDriverCords => _driverCords;

  String get getPickUpAddress => _pickUpAddress;
  String get getDropAddress => _dropAddress;

  bool get getIsStart => _isStart;

  void setIsStart(bool value) {
    _isStart = value;
    notifyListeners();
  }

  void setPickAddress(String value) {
    _pickUpAddress = value;
    notifyListeners();
  }

  void setDropAddress(String value) {
    _dropAddress = value;
    notifyListeners();
  }

  void setPickUpCords(GeoCoord cords) {
    _pickUpCords = cords;
    notifyListeners();
  }

  void setDropCords(GeoCoord cords) {
    _dropCords = cords;
    notifyListeners();
  }

  void setDriverCords(GeoCoord cords) {
    _driverCords = cords;
    notifyListeners();
  }
}

class GeoCoord {
  final double latitude;
  final double longitude;

  GeoCoord(this.latitude, this.longitude);
}
