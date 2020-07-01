import 'package:driverapp/enums/locationview.dart';
import 'package:flutter/material.dart';

class LocationViewProvider with ChangeNotifier {
  LocationView _locationView;
  String _pickUpPointAddress;
  String _destinationPointAddress;

  LocationViewProvider() {
    _locationView = LocationView.PICKUPSELECTED;
    _pickUpPointAddress = "";
    _destinationPointAddress = "";
  }

  LocationView get getLocationView => _locationView;

  String get getPickUpPointAddress => _pickUpPointAddress;

  String get getDestinationPointAddress => _destinationPointAddress;

  void reset(){
    _locationView = LocationView.PICKUPSELECTED;
    _pickUpPointAddress = "";
    _destinationPointAddress = "";

  }

  void setLocationView(LocationView view) {
    _locationView = view;
    notifyListeners();
  }

  void setPickUpAddress(String address) {
    _pickUpPointAddress = address;
  }

  void setDestinationPointAddress(String address) {
    _destinationPointAddress = address;
  }
}
