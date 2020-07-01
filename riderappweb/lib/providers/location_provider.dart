import 'package:flutter/material.dart';
import 'package:flutter_google_maps/flutter_google_maps.dart';
import 'package:riderappweb/enums/location_view.dart';

class LocationViewProvider with ChangeNotifier {
  LocationView _locationView;
  String _pickUpPointAddress;
  String _destinationPointAddress;
  GeoCoord _pickUpLatLng;
  GeoCoord _destinationLatLng;
  bool _isDraggedUp = false;
  GeoCoord _lastMapLocation;
  GeoCoord _northestBound;
  GeoCoord _southestBound;

  LocationViewProvider() {
    _locationView = LocationView.PICKUP;
    _pickUpPointAddress = "";
    _destinationPointAddress = "";
    _pickUpLatLng = GeoCoord(0.1234, 0123);
    _lastMapLocation = GeoCoord(0.1234, 0123);
    _destinationLatLng = GeoCoord(0.1234, 0123);
  }

  LocationView get getLocationView => _locationView;

  GeoCoord get getNorthestBound => _northestBound;
  GeoCoord get getSouthestBound => _southestBound;

  String get getPickUpPointAddress => _pickUpPointAddress;

  String get getDestinationPointAddress => _destinationPointAddress;

  GeoCoord get getPickUpLatLng => _pickUpLatLng;

  GeoCoord get getMapLastPos => _lastMapLocation;

  GeoCoord get getDestinationLatLng => _destinationLatLng;

  bool get getIsDraggedUp => _isDraggedUp;

  void setLocationView(LocationView view) {
    _locationView = view;
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
    if (_locationView == LocationView.PICKUP) {
      _pickUpPointAddress = address;
      notifyListeners();
    } else {
      _destinationPointAddress = address;
      notifyListeners();
    }
  }

  void setPickUpLatLng(GeoCoord latLng) {
    _pickUpLatLng = latLng;
    notifyListeners();
  }

  void setDestinationLatLng(GeoCoord latLng) {
    _destinationLatLng = latLng;
    notifyListeners();
  }

  void setMapLastPos(GeoCoord latLng) {
    _lastMapLocation = latLng;
    notifyListeners();
  }

  void setNorthestBound(GeoCoord geoCoord) {
    _northestBound = geoCoord;
    notifyListeners();
  }

  void setSouthestBound(GeoCoord geoCoord) {
    _southestBound = geoCoord;
    notifyListeners();
  }
}
