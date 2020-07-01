import 'package:flutter/material.dart';
import 'package:rideapp/controllers/static_utils.dart';
import 'package:rideapp/enums/station_view.dart';
import 'package:rideapp/providers/locationViewProvider.dart';

class OrderProvider with ChangeNotifier {
  int _selectedPaymentMethod;
  String _receiverName;
  String _receiverPhone;
  String _truckName;
  int _orderPrice;
  int _groupOfRideType = 0;
  double _totalDistance;
  StaticUtils _utils = StaticUtils();
  List<String> _trucksCategory = ["Mini (< 1 MT)", "Small (< 5 MT)", "Medium (5 - 15 MT)", "Large (15 - 40 MT)"];
  List<String> _trucksCategoryLocal = ["Mini (< 1 MT)", "Small (< 5 MT)", "Medium (5 - 15 MT)",];
  String _selectedTruck;
  String _selectedTruckLocal;
  StationView _stationView;
  int _selectedLocalView = 0;

  OrderProvider() {
    _selectedPaymentMethod = 0;
    _totalDistance = 0;
    _orderPrice = 0;
    _receiverName = "";
    _receiverPhone = "";
    _truckName = "";
    _stationView = StationView.LOCAL;
  }

  int get getSelectedPaymentMethod => _selectedPaymentMethod;

  int get getRideType => _groupOfRideType;

  String get getReceiverName => _receiverName;

  String get getReceiverPhone => _receiverPhone;

  String get getTruckName => _truckName;

  int get getOrderPrice => _orderPrice;

  double get getTotalDistance => _totalDistance;

  String get getSelectedTruck => _selectedTruck;

  String get getSelectedTruckLocal => _selectedTruckLocal;

  List<String> get getTruckCategory => _trucksCategory;

  List<String> get getTruckCatLocal => _trucksCategoryLocal;

  StationView get getStationView => _stationView;

  int get getSelectedLocalView => _selectedLocalView;

  void setPaymentMethod(int id) {
    _selectedPaymentMethod = id;
    notifyListeners();
  }

  void setLocalView(int val) {
    _selectedLocalView = val;
    notifyListeners();
  }

  void setStationView(StationView view) {
    _stationView = view;
    notifyListeners();
  }

  void setGroupRideType(int type) {
    _groupOfRideType = type;
    notifyListeners();
  }

  void setTruckCategory(String cat) {
    _selectedTruck = cat;
    notifyListeners();
  }

  void setTruckCategoryLocal(String cat) {
    _selectedTruckLocal = cat;
    notifyListeners();
  }

  void setOrderPrice(LocationViewProvider provider, int priceFactor) async {
    _totalDistance = _utils.distanceInKmBetweenEarthCoordinates(
        provider.getPickUpLatLng, provider.getDestinationLatLng);
    print(_totalDistance);
    _orderPrice = ((_totalDistance) * priceFactor).round();
    print(_orderPrice);
    notifyListeners();
  }

  void setReceiverPhone(String phone) {
    _receiverPhone = phone;
    notifyListeners();
  }

  void setReceiverName(String name) {
    _receiverName = name;
    notifyListeners();
  }

  void setTruckName(String truck) {
    _truckName = truck;
    notifyListeners();
  }
}
