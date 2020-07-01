import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riderappweb/controllers/firebase_utils.dart';

class UserPreferences with ChangeNotifier {
  String _name;
  String _phoneNumber;
  String _token;
  String _email;
  int _walletMoney;
  String _userID;
  FirebaseUtils _utils = FirebaseUtils();

  UserPreferences() {
    _name = "";
    _phoneNumber = "";
    _token = "";
    _email = "";
    _userID = "";
    _walletMoney = 0;
  }

  void init(BuildContext context) async {
    DocumentSnapshot userData = await Firestore.instance
        .collection('user')
        .document("oTclRaQApRcx864rWIuMSE4xoMO2")
        .get();
    print(userData.data);
    if (userData.exists) {
      _name = userData.data['name'];
      _email = userData.data['email'];
      _phoneNumber = userData.data['phone'];
      _token = userData.data['token'];
      DocumentSnapshot _walletDoc =
          await Firestore.instance.collection('wallet').document(_userID).get();
      _walletMoney = _walletDoc.data['money'];
    } else {
      FirebaseAuth _auth = FirebaseAuth.instance;
      _auth.signOut();
      Navigator.of(context).pushNamed('/loginscreen');
    }
    notifyListeners();
  }

  String get getUserName => _name;
  String get getUserID => _userID;
  String get getUserPhone => _phoneNumber;
  String get getUserEmail => _email;
  String get getUserToken => _token;
  int get getWalletBalance => _walletMoney;
}
