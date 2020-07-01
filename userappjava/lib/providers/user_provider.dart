import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:rideapp/controllers/firebase_utils.dart';

class UserPreferences with ChangeNotifier {
  String _name;
  String _phoneNumber;
  String _token;
  String _email;
  int _walletMoney;
  String _userID;
  bool _isSuspended;
  FirebaseUtils _utils = FirebaseUtils();

  UserPreferences() {
    _name = "";
    _phoneNumber = "";
    _token = "";
    _email = "";
    _userID = "";
    _walletMoney = 0;
    _isSuspended = false;
  }

  void init(BuildContext context) async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      FirebaseUser _user = await _utils.getCurrentUser();
      _userID = _user.uid;
      DocumentSnapshot userData =
          await Firestore.instance.collection('user').document(_userID).get();
      print(userData.data);
      if (userData.exists) {
        _name = userData.data['name'];
        _email = userData.data['email'];
        _phoneNumber = userData.data['phone'];
        _token = userData.data['token'];
        _isSuspended = userData.data['isSuspended'];
        DocumentSnapshot _walletDoc = await Firestore.instance
            .collection('wallet')
            .document(_userID)
            .get();
        _walletMoney = _walletDoc.data['money'] ?? "0";
        if (_isSuspended) {
          Navigator.of(context).pushReplacementNamed('/suspension');
        }
      } else {
        FirebaseAuth _auth = FirebaseAuth.instance;
        _auth.signOut();
        Navigator.of(context).pushNamed('/loginscreen');
      }
    }
    notifyListeners();
  }

  String get getUserName => _name;
  String get getUserID => _userID;
  String get getUserPhone => _phoneNumber;
  String get getUserEmail => _email;
  String get getUserToken => _token;
  int get getWalletBalance => _walletMoney;
  bool get getUserSuspension => _isSuspended;
}
