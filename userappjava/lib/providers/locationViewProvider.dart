import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rideapp/enums/bottom_sheet_status.dart';
import 'package:rideapp/enums/locationview.dart';

class LocationViewProvider with ChangeNotifier {
  LocationView _locationView;
  String _pickUpPointAddress;
  String _destinationPointAddress;
  BottomSheetStatus _bottomSheetStatus;
  LatLng _pickUpLatLng;
  LatLng _destinationLatLng;
  bool _isDraggedUp = false;
  LatLng _lastMapLocation;

  LocationViewProvider() {
    _locationView = LocationView.PICKUPSELECTED;
    _pickUpPointAddress = "";
    _destinationPointAddress = "";
    _bottomSheetStatus = BottomSheetStatus.DOWN;
    _pickUpLatLng = LatLng(0.1234, 0123);
    _lastMapLocation = LatLng(0.1234, 0123);
    _destinationLatLng = LatLng(0.1234, 0123);
  }

  LocationView get getLocationView => _locationView;

  BottomSheetStatus get getBottomSheetStatus => _bottomSheetStatus;

  String get getPickUpPointAddress => _pickUpPointAddress;

  String get getDestinationPointAddress => _destinationPointAddress;

  LatLng get getPickUpLatLng => _pickUpLatLng;

  LatLng get getMapLastPos => _lastMapLocation;

  LatLng get getDestinationLatLng => _destinationLatLng;

  bool get getIsDraggedUp => _isDraggedUp;

  void reset(){
    _locationView = LocationView.PICKUPSELECTED;
    _pickUpPointAddress = "";
    _destinationPointAddress = "";
    _bottomSheetStatus = BottomSheetStatus.DOWN;
    _pickUpLatLng = LatLng(0.1234, 0123);
    _lastMapLocation = LatLng(0.1234, 0123);
    _destinationLatLng = LatLng(0.1234, 0123);

  }

  void setLocationView(LocationView view) {
    _locationView = view;
    notifyListeners();
  }

  void setBottomSheetStatus(BottomSheetStatus status) {
    _bottomSheetStatus = status;
    notifyListeners();
  }

  void setIsDraggedUp(bool isDragged) {
    _isDraggedUp = isDragged;
    notifyListeners();
  }

  void setPickUpAddress(String address) {
    _pickUpPointAddress = address;
  }

  void setDestinationPointAddress(String address) {
    _destinationPointAddress = address;
  }

  void setAddress(String address) {
    if (_locationView == LocationView.PICKUPSELECTED) {
      _pickUpPointAddress = address;
      notifyListeners();
    } else {
      _destinationPointAddress = address;
      notifyListeners();
    }
  }

  void setPickUpLatLng(LatLng latLng) {
    _pickUpLatLng = latLng;
    notifyListeners();
  }

  void setDestinationLatLng(LatLng latLng) {
    _destinationLatLng = latLng;
    notifyListeners();
  }

  void setMapLastPos(LatLng latLng) {
    _lastMapLocation = latLng;
    notifyListeners();
  }
}
