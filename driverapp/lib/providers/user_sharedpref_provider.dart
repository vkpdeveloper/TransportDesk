import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:driverapp/controllers/firebase_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class UserPreferences with ChangeNotifier {
  String _name;
  String _phoneNumber;
  String _token;
  String _email;
  String _userID;
  bool _isFree;
  String _profilePhoto;
  FirebaseUtils _utils = FirebaseUtils();
  String _vehicelName;
  String _vehicleNumber;
  double _rating;

  UserPreferences() {
    _name = "";
    _phoneNumber = "";
    _token = "";
    _email = "";
    _userID = "";
    _profilePhoto = "";
    _isFree = false;
    _vehicelName = "";
    _vehicleNumber = "";
    _rating = 0;
  }

  void init() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      FirebaseUser _user = await _utils.getCurrentUser();
      _userID = _user.uid;
      DocumentSnapshot userData = await Firestore.instance
          .collection('vendor')
          .document(_user.phoneNumber)
          .get();
      _name = userData.data['name'];
      _email = userData.data['email'];
      _phoneNumber = userData.data['phone'];
      _token = userData.data['token'];
      _isFree = userData.data['isFree'];
      _profilePhoto = userData.data['profile'];
      _vehicleNumber = userData.data['vehicleNumber'];
      _vehicelName = userData.data['vehicleName'];
      _rating = userData.data['rating'];
    }
    notifyListeners();
  }

  String get getUserName => _name;
  String get getUserID => _userID;
  String get getUserPhone => _phoneNumber;
  String get getUserEmail => _email;
  String get getUserToken => _token;
  bool get getIsFree => _isFree;
  String get getProfile => _profilePhoto;
  String get getVehicleName => _vehicelName;
  String get getVehicleNumber => _vehicleNumber;
  double get getRating => _rating;

  void setIsFree(bool val) async {
    FirebaseUser _user = await _utils.getCurrentUser();
    Firestore.instance
        .collection('vendor')
        .document(_user.phoneNumber)
        .updateData({
      "isFree": val,
    });
    _isFree = val;
    notifyListeners();
  }
}
