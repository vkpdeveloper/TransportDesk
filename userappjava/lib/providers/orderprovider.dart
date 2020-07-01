import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<String> _trucksCategory = [
    "Mini (< 1 MT)",
    "Small (< 5 MT)",
    "Medium (5 - 15 MT)",
    "Large (15 - 40 MT)"
  ];
  List<String> _trucksCategoryLocal = [
    "Mini (< 1 MT)",
    "Small (< 5 MT)",
    "Medium (5 - 15 MT)",
  ];
  String _selectedTruck;
  String _selectedTruckLocal;
  StationView _stationView;
  int _selectedLocalView = 0;
  bool _isScheduled;
  DateTime _orderDeliveryTime;
  DateTime _orderPlacedTime;
  int _userCancellationPercent;
  int _nightFareStartHour;
  int _nightFareEndHour;
  int _nightChargePercent;

  OrderProvider() {
    _selectedTruck = "";
    _selectedPaymentMethod = 0;
    _totalDistance = 0;
    _orderPrice = 0;
    _receiverName = "";
    _receiverPhone = "";
    _truckName = "";
    _stationView = StationView.LOCAL;
    _isScheduled = false;
    _orderDeliveryTime = DateTime.now();
    _userCancellationPercent = 0;
    _nightFareEndHour = 0;
    _nightFareStartHour = 0;
    _nightChargePercent = 0;
    setNightFareStart();
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

  bool get getScheduledRide => _isScheduled;

  DateTime get getTimeOfOrderDelivery => _orderDeliveryTime;

  DateTime get getTimeofOrderPlaced => _orderPlacedTime;

  int get getUserCancellationPercent => _userCancellationPercent;

  int get getNightFareStart => _nightFareStartHour;

  int get getFareStartHour => _nightFareStartHour;

  int get getNightChargePercent => _nightChargePercent;

  void reset() {
    _selectedPaymentMethod = 0;
    _totalDistance = 0;
    _orderPrice = 0;
    _receiverName = "";
    _receiverPhone = "";
    _truckName = "";
    _stationView = StationView.LOCAL;
    _isScheduled = false;
    _orderDeliveryTime = DateTime.now();
    _orderPlacedTime = DateTime.now();
  }

  void setNightFareStart() async {
    DocumentSnapshot data = await Firestore.instance
        .collection('admin')
        .document('farecalculation')
        .get();
    _userCancellationPercent = data.data['usercancellation'];
    _nightFareStartHour = data.data['nightfarestart'];
    _nightFareEndHour = data.data['nightfareend'];
    _nightChargePercent = data.data['nightfarepercent'];
    notifyListeners();
  }

  void setPaymentMethod(int id) {
    _selectedPaymentMethod = id;
    notifyListeners();
  }

  void setTimeOfOrderDelivery(DateTime val) {
    _orderDeliveryTime = val;
    notifyListeners();
  }

  void setTimeOfOrderPlaced(DateTime val) {
    _orderPlacedTime = val;
    notifyListeners();
  }

  void setScheduled(bool val) {
    _isScheduled = val;
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

  void setOrderPrice(LocationViewProvider provider, int priceFactor,
      bool isNight, int perc) async {
    if (!isNight) {
      _totalDistance = _utils.distanceInKmBetweenEarthCoordinates(
          provider.getPickUpLatLng, provider.getDestinationLatLng);
      print(_totalDistance);
      _orderPrice = ((_totalDistance) * priceFactor).round();
      notifyListeners();
    } else {
      _totalDistance = _utils.distanceInKmBetweenEarthCoordinates(
          provider.getPickUpLatLng, provider.getDestinationLatLng);

      _orderPrice = ((_totalDistance) * priceFactor).round();
      int perOfOrderPrice = ((_orderPrice / 100) * perc).round();
      _orderPrice += perOfOrderPrice;
      notifyListeners();
    }
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
