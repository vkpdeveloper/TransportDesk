import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driverapp/providers/auth_provider.dart';
import 'package:driverapp/providers/order_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class FirebaseUtils {
  FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference _firestoreUser =
      Firestore.instance.collection('driverSignup');

  FirebaseMessaging _messaging = FirebaseMessaging();

  Future<String> getuserphoneno() async {
    FirebaseUser user = await getCurrentUser();
    return user.phoneNumber;
  }

  Future<bool> getLoggedIn() async {
    try {
      final FirebaseUser user = await _auth.currentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  Future<FirebaseUser> getCurrentUser() async {
    return _auth.currentUser();
  }

  Future getverificationStatus() async {
    FirebaseUser user = await _auth.currentUser();

    DocumentSnapshot snapshot = await _firestoreUser.document(user.uid).get();
    return snapshot.data;
  }

  Future<String> getCurrentUserToken() async {
    return _messaging.getToken();
  }

  //to get new signups in collection according to time and to get verification status
  Future<void> saveFirsttimeData() async {
    FirebaseUser user = await _auth.currentUser();
    Map<String, dynamic> data = {
      "time": Timestamp.now(),
      "verified": false,
    };
    await _firestoreUser.document(user.uid).setData(data, merge: true);
  }

  Future<void> saveUserDetails(String name, String phoneno, String gstin,
      String vehiclemodel, String vehiclenumber, String city) async {
    FirebaseUser user = await _auth.currentUser();
    Map<String, dynamic> data = {
      "name": name,
      "phoneno": phoneno,
      "gstin": gstin,
      "vehiclemodel": vehiclemodel,
      "vehiclenumber": vehiclenumber,
      "city": city,
      "timeuploaded": Timestamp.now(),
    };
    await _firestoreUser
        .document(user.uid)
        .collection("details")
        .document("$phoneno")
        .setData(data, merge: true);
  }

  Future<List<String>> getAllListOfTrucks() async {
    List<String> allTrucks = [];
    QuerySnapshot snapshot =
        await Firestore.instance.collection('trucks').getDocuments();
    snapshot.documents.forEach((DocumentSnapshot truck) {
      allTrucks.add(truck.data['name']);
    });
    return allTrucks;
  }

  Future isVendorExists() async {
    String phone = await getuserphoneno();
    try {
      DocumentSnapshot snapshot =
          await Firestore.instance.collection('vendor').document(phone).get();
      return snapshot.exists;
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> signInWithPhone(AuthProvider provider) async {
    PhoneVerificationCompleted verificationComplete =
        (AuthCredential creds) async {
      AuthResult result = await _auth.signInWithCredential(creds);
      assert(result.user.uid != null);
      provider.setUser(result.user);
      print(result.user.uid);
    };
    PhoneVerificationFailed verificationFailed = (AuthException exception) {
      provider.setError(exception);
    };

    PhoneCodeSent onCodeSent = (String verificationCode, [int forceCodeSent]) {
      provider.setVerificationID(verificationCode);
      provider.setIsCodeSent(true);
    };

    PhoneCodeAutoRetrievalTimeout codeRetrievalTimeout =
        (String verificationID) {
      provider.setVerificationID(verificationID);
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: "+91${provider.phoneNumber}",
        timeout: Duration(seconds: 10),
        verificationCompleted: verificationComplete,
        verificationFailed: verificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: codeRetrievalTimeout);
  }

  Future<FirebaseUser> loginWithOTP(AuthProvider provider) async {
    try {
      AuthCredential credential = PhoneAuthProvider.getCredential(
          verificationId: provider.verificationID, smsCode: provider.smsCode);
      AuthResult result = await _auth.signInWithCredential(credential);
      if (result.additionalUserInfo.isNewUser) {
        saveFirsttimeData();
      }
      if (result.user.uid != null) return result.user;
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "Wrong OTP");
    }
  }

  void declineOrder(String orderid, BuildContext context) {
    Firestore.instance.collection('allOrders').document(orderid).delete();
    Navigator.of(context).pushReplacementNamed('/homescreen');
  }

  void acceptOrder(String orderid, PanelController controller, LatLng latLng,
      Timer updateTimer, OrderProvider provider) {
    Firestore.instance.collection('allOrders').document(orderid).updateData({
      "isStart": true,
      "isPicked": false,
      "riderPoint": [latLng.latitude, latLng.longitude]
    });
    controller.open();
    updateTimer = Timer.periodic(
        Duration(minutes: 2), (timer) => updateDriverLocation(orderid));
  }

  updateDriverLocation(String orderid) async {
    Position latLng = await Geolocator().getCurrentPosition();
    print(latLng.latitude);
    Firestore.instance.collection('allOrders').document(orderid).updateData({
      "riderPoint": [latLng.latitude, latLng.longitude]
    });
  }

  void pickUpDone(String orderid, OrderProvider provider,
      TextEditingController pinController, String pin) {
    if (pinController.text == pin) {
      Firestore.instance.collection('allOrders').document(orderid).updateData({
        "isPicked": true,
      });
      provider.setIsPicked(true);
    } else {
      Fluttertoast.showToast(msg: "Enter a valid PIN");
    }
  }

  void deliveryDone(String orderid, OrderProvider provider, TextEditingController dropPinController, String dropPin) async {
    if(dropPinController.text == dropPin) {
      Firestore.instance.collection('allOrders').document(orderid).updateData({
      "isPicked": true,
      "isDelivered": true,
      "isStart": true,
      "isPending": false
    });
    String phoneNumber = await getuserphoneno();
    Firestore.instance.collection('vendor').document(phoneNumber).updateData({
      "isFree": true,
    });
    provider.setIsDropped(true);
    } else {
      Fluttertoast.showToast(msg: "Invalid Drop Pin");
    }
  }
}
