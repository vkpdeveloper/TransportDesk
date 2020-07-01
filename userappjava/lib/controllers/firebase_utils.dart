import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rideapp/enums/station_view.dart';
import 'package:rideapp/providers/locationViewProvider.dart';
import 'package:rideapp/providers/orderprovider.dart';
import 'package:rideapp/providers/user_provider.dart';
import 'package:rideapp/controllers/static_utils.dart';

class FirebaseUtils {
  FirebaseAuth _auth = FirebaseAuth.instance;
  StaticUtils _utils = StaticUtils();

  CollectionReference _firestoreUser = Firestore.instance.collection('user');
  CollectionReference _firestoreWallet = Firestore.instance.collection('wallet');
  CollectionReference _firestoreVendor = Firestore.instance.collection('vendor');

  CollectionReference _firestoreOrder = Firestore.instance.collection('allOrders');

  CollectionReference _firestoreOutstationOrder = Firestore.instance.collection('outstationOrders');

  CollectionReference _firestoreScheduledOrder = Firestore.instance.collection('scheduledOrders');

  FirebaseMessaging _messaging = FirebaseMessaging();

  Future<bool> getuserexistence(String phone) async {
    final snapShot = await Firestore.instance.collection('users').document(phone).get();
    if (snapShot == null || !snapShot.exists) {
      return false;
    }
    return true;
  }

  void updateToken(FirebaseUser user) async {
    String token = await _messaging.getToken();
    Firestore.instance.collection('user').document(user.uid).setData({
      "token": token,
    }, merge: true);
  }

  Future<bool> isUserExist() async {
    FirebaseUser user = await getCurrentUser();
    final snapShot = await Firestore.instance.collection('user').document(user.uid).get();

    if (snapShot.exists) updateToken(user);
    return snapShot.exists;
  }

  Future<void> addAddress(String address, LatLng latLng) async {
    FirebaseUser user = await getCurrentUser();
    await Firestore.instance.collection('user').document(user.uid).collection('address').add({
      "address": address,
      "latlng": [latLng.latitude, latLng.longitude]
    });
  }

  Future<bool> isAgreementDone() async {
    FirebaseUser user = await getCurrentUser();
    DocumentSnapshot data = await Firestore.instance.collection('user').document(user.uid).get();
    if (data.exists) {
      return data.data['isAgree'];
    }
  }

  Future<bool> getisFareHighHours() async {
    DocumentSnapshot data =
        await Firestore.instance.collection('admin').document('farecalculation').get();
    if (data.exists) {
      int nightTimeStart = data.data['nightfarestart'];
      int nightTimeEnd = data.data['nightfareend'];
      DateTime now = DateTime.now();
      TimeOfDay timenow = TimeOfDay.fromDateTime(now);
      if (timenow.hour.toInt() < nightTimeStart && timenow.hour.toInt() > nightTimeEnd) {
        return false;
      }
      return true;
    }
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

  Future<String> getCurrentUserToken() async {
    return _messaging.getToken();
  }

  Future<void> saveGivenData(String firstName, String lastName) async {
    FirebaseUser user = await _auth.currentUser();
    String token = await getCurrentUserToken();
    Map<String, dynamic> data = {
      "name": "$firstName $lastName",
      "phone": user.phoneNumber ?? "",
      "token": token,
      "email": user.email ?? "",
      "isAgree": false
    };
    await _firestoreUser.document(user.uid).setData(data, merge: true);
    DocumentSnapshot walletData = await _firestoreWallet.document(user.uid).get();
    if (!walletData.exists) {
      _firestoreWallet.document(user.uid).setData({"money": 0, "phone": user.phoneNumber});
    }
  }

  Future<void> saveGoogleLoginData() async {
    FirebaseUser user = await _auth.currentUser();
    String token = await getCurrentUserToken();
    Map<String, dynamic> data = {
      "name": user.displayName,
      "token": token,
      "email": user.email,
      "isAgree": false
    };
    await _firestoreUser.document(user.uid).setData(data, merge: true);
    DocumentSnapshot walletData = await _firestoreWallet.document(user.uid).get();
    if (!walletData.exists) {
      _firestoreWallet.document(user.uid).setData({"money": 0, "email": user.email});
    }
  }

  Future<void> addScheduledOrder(
      LocationViewProvider locationViewProvider,
      OrderProvider orderProvider,
      ProgressDialog dialog,
      UserPreferences userPreferences,
      BuildContext context) {
    DateTime currentDate = new DateTime.now();
    String pin = currentDate.millisecondsSinceEpoch.toString().substring(4, 10);
    print(pin);

    String orderID =
        "ORDER${currentDate.day}${currentDate.month}${DateTime.now().millisecondsSinceEpoch.toString().substring(6, 12)}";
    Map<String, dynamic> orderData = {
      "orderID": orderID,
      "userID": userPreferences.getUserID,
      "userToken": userPreferences.getUserToken,
      "userName": userPreferences.getUserName,
      "userPhone": userPreferences.getUserPhone,
      "receiverName": orderProvider.getReceiverName,
      "receiverPhone": orderProvider.getReceiverPhone,
      "pickUpPin": pin,
      "isPaymentRequested": false,
      "pickUpLatLng": [
        locationViewProvider.getPickUpLatLng.latitude,
        locationViewProvider.getPickUpLatLng.longitude
      ],
      "destLatLng": [
        locationViewProvider.getDestinationLatLng.latitude,
        locationViewProvider.getDestinationLatLng.longitude
      ],
      "addresses": [
        locationViewProvider.getPickUpPointAddress,
        locationViewProvider.getDestinationPointAddress
      ],
      "timeOfOrderPlaced": orderProvider.getTimeofOrderPlaced,
      "timeForDelivery": orderProvider.getTimeOfOrderDelivery,
      "isScheduled": orderProvider.getScheduledRide,
      "isPending": true,
      "isStart": false,
      "isDelivered": false,
      "distance": orderProvider.getTotalDistance,
      "price": orderProvider.getOrderPrice,
      "truckName": orderProvider.getTruckName
    };
    _firestoreScheduledOrder.document(orderID).setData(orderData).then((value) {
      dialog.hide();
      Fluttertoast.showToast(backgroundColor: Colors.blue, msg: "Order Placed");
      Navigator.pushReplacementNamed(context, "/allordersscreen");
    });
  }

  Future<void> startOrder(LocationViewProvider locationViewProvider, OrderProvider orderProvider,
      UserPreferences userPreferences, BuildContext context) async {
    bool isVendorDetected = false;
    ProgressDialog dialog =
        ProgressDialog(context, isDismissible: false, type: ProgressDialogType.Normal);
    dialog.style(
      elevation: 8.0,
      borderRadius: 15,
      message: "Searching for truck...",
      backgroundColor: Colors.white,
      insetAnimCurve: Curves.bounceIn,
    );
    dialog.show();
    if (orderProvider.getStationView == StationView.LOCAL) {
      List<double> allDistances = [];
      QuerySnapshot allVendors =
          await _firestoreVendor.where("isFree", isEqualTo: true).getDocuments();
      Map<double, Map<String, dynamic>> vendorsData = {};
      for (DocumentSnapshot vendor in allVendors.documents) {
        LatLng destLat =
            LatLng(vendor.data['currentLocation'][0], vendor.data['currentLocation'][1]);
        double distance = _utils.distanceInKmBetweenEarthCoordinates(
            locationViewProvider.getPickUpLatLng, destLat);
        allDistances.add(distance);
        vendorsData[distance] = {
          "vendorID": vendor.data['userID'],
          "vendorPhone": vendor.data['phone'],
          "riderName": vendor.data['name']
        };
      }
      allDistances.sort();
      if (allDistances[0] <= 3) {
        Map<String, dynamic> selectedVendor = vendorsData[allDistances[0]];
        addBooking(
            selectedVendor, locationViewProvider, orderProvider, dialog, userPreferences, context);
      } else {
        if (allDistances[0] <= 6) {
          Map<String, dynamic> selectedVendor = vendorsData[allDistances[0]];
          addBooking(selectedVendor, locationViewProvider, orderProvider, dialog, userPreferences,
              context);
        } else {
          addBookingWithoutVendor(
              locationViewProvider, orderProvider, dialog, userPreferences, context);
        }
      }
    } else {
      addForOutside(locationViewProvider, orderProvider, dialog, userPreferences, context);
    }
  }

  void addBookingWithoutVendor(
      LocationViewProvider locationViewProvider,
      OrderProvider orderProvider,
      ProgressDialog dialog,
      UserPreferences userPreferences,
      BuildContext context) {
    DateTime currentDate = new DateTime.now();
    String pin = currentDate.millisecondsSinceEpoch.toString().substring(4, 10);
    print(pin);
    String paymentMethod = "";
    if (orderProvider.getSelectedPaymentMethod == 0) paymentMethod = "Paytm";
    if (orderProvider.getSelectedPaymentMethod == 1) paymentMethod = "CC or DC Card";
    if (orderProvider.getSelectedPaymentMethod == 2) paymentMethod = "Cash";
    String orderID =
        "ORDER${currentDate.day}${currentDate.month}${DateTime.now().millisecondsSinceEpoch.toString().substring(6, 12)}";
    Map<String, dynamic> orderData = {
      "orderID": orderID,
      "userID": userPreferences.getUserID,
      "userToken": userPreferences.getUserToken,
      "userName": userPreferences.getUserName,
      "userPhone": userPreferences.getUserPhone,
      "receiverName": orderProvider.getReceiverName,
      "receiverPhone": orderProvider.getReceiverPhone,
      "pickUpPin": pin,
      "paymentMethod": paymentMethod,
      "pickUpLatLng": [
        locationViewProvider.getPickUpLatLng.latitude,
        locationViewProvider.getPickUpLatLng.longitude
      ],
      "destLatLng": [
        locationViewProvider.getDestinationLatLng.latitude,
        locationViewProvider.getDestinationLatLng.longitude
      ],
      "addresses": [
        locationViewProvider.getPickUpPointAddress,
        locationViewProvider.getDestinationPointAddress
      ],
      "timeOfOrderPlaced": orderProvider.getTimeofOrderPlaced,
      "timeForDelivery": orderProvider.getTimeOfOrderDelivery,
      "isScheduled": orderProvider.getScheduledRide,
      "isPending": true,
      "isStart": false,
      "isDelivered": false,
      "distance": orderProvider.getTotalDistance,
      "price": orderProvider.getOrderPrice,
      "truckName": orderProvider.getTruckName
    };
    _firestoreOrder.document(orderID).setData(orderData).then((value) {
      dialog.hide();
      Fluttertoast.showToast(backgroundColor: Colors.blue, msg: "Order Placed");
      Navigator.pushReplacementNamed(context, "/allordersscreen");
    });
  }

  void addForOutside(LocationViewProvider locationViewProvider, OrderProvider orderProvider,
      ProgressDialog dialog, UserPreferences userPreferences, BuildContext context) {
    String paymentMethod = "";
    if (orderProvider.getSelectedPaymentMethod == 0) paymentMethod = "Paytm";
    if (orderProvider.getSelectedPaymentMethod == 1) paymentMethod = "CC or DC Card";
    if (orderProvider.getSelectedPaymentMethod == 2) paymentMethod = "Cash";
    DateTime currentDate = new DateTime.now();
    String pickupPin = randomPin();
    String dropPin = randomPin();

    String orderID =
        "ORDER${currentDate.day}${currentDate.month}${DateTime.now().millisecondsSinceEpoch.toString().substring(6, 12)}";
    Map<String, dynamic> orderData = {
      "orderID": orderID,
      "userID": userPreferences.getUserID,
      "userToken": userPreferences.getUserToken,
      "userName": userPreferences.getUserName,
      "pickUpPin": pickupPin,
      "dropPin": dropPin,
      "userPhone": userPreferences.getUserPhone,
      "receiverName": orderProvider.getReceiverName,
      "receiverPhone": orderProvider.getReceiverPhone,
      "paymentMethod": paymentMethod,
      "timeOfOrderPlaced": orderProvider.getTimeofOrderPlaced,
      "timeForDelivery": orderProvider.getTimeOfOrderDelivery,
      "isScheduled": orderProvider.getScheduledRide,
      "pickUpLatLng": [
        locationViewProvider.getPickUpLatLng.latitude,
        locationViewProvider.getPickUpLatLng.longitude
      ],
      "destLatLng": [
        locationViewProvider.getDestinationLatLng.latitude,
        locationViewProvider.getDestinationLatLng.longitude
      ],
      "orderType": "OUTSTATION",
      "addresses": [
        locationViewProvider.getPickUpPointAddress,
        locationViewProvider.getDestinationPointAddress
      ],
      "isPending": true,
      "isStart": false,
      "isDelivered": false,
      "distance": orderProvider.getTotalDistance,
      "truckName": orderProvider.getTruckName
    };
    _firestoreOutstationOrder.document(orderID).setData(orderData).whenComplete(() {
      dialog.hide();
      OrderProvider().reset();
      Fluttertoast.showToast(msg: "Order Received We will Contact you soon");
    });
  }

  randomPin() {
    var rn = new Random();
    return (1000 + rn.nextInt(9999 - 1000)).toString();
  }

  void addBooking(
      Map<String, dynamic> snapshot,
      LocationViewProvider locationViewProvider,
      OrderProvider orderProvider,
      ProgressDialog dialog,
      UserPreferences userPreferences,
      BuildContext context) {
    String paymentMethod = "";
    if (orderProvider.getSelectedPaymentMethod == 0) paymentMethod = "Paytm";
    if (orderProvider.getSelectedPaymentMethod == 1) paymentMethod = "CC or DC Card";
    if (orderProvider.getSelectedPaymentMethod == 2) paymentMethod = "Cash";
    DateTime currentDate = new DateTime.now();

    String pickPin = randomPin();
    String dropPin = randomPin();
    String orderID =
        "ORDER${currentDate.day}${currentDate.month}${DateTime.now().millisecondsSinceEpoch.toString().substring(6, 12)}";
    print(orderID);
    Map<String, dynamic> orderData = {
      "orderID": orderID,
      "userID": userPreferences.getUserID,
      "userToken": userPreferences.getUserToken,
      "userName": userPreferences.getUserName,
      "pickUpPin": pickPin,
      "dropPin": dropPin,
      "userPhone": userPreferences.getUserPhone,
      "receiverName": orderProvider.getReceiverName,
      "receiverPhone": orderProvider.getReceiverPhone,
      "paymentMethod": paymentMethod,
      "riderUserID": snapshot['vendorID'],
      "riderPhone": snapshot['vendorPhone'],
      "riderName": snapshot["riderName"],
      "isPaymentRequested": false,
      "timeOfOrderPlaced": orderProvider.getTimeofOrderPlaced,
      "timeForDelivery": orderProvider.getTimeOfOrderDelivery,
      "isScheduled": orderProvider.getScheduledRide,
      "pickUpLatLng": [
        locationViewProvider.getPickUpLatLng.latitude,
        locationViewProvider.getPickUpLatLng.longitude
      ],
      "destLatLng": [
        locationViewProvider.getDestinationLatLng.latitude,
        locationViewProvider.getDestinationLatLng.longitude
      ],
      "addresses": [
        locationViewProvider.getPickUpPointAddress,
        locationViewProvider.getDestinationPointAddress
      ],
      "isPending": false,
      "isPicked": false,
      "isStart": false,
      "isDelivered": false,
      "distance": orderProvider.getTotalDistance,
      "price": orderProvider.getOrderPrice,
      "truckName": orderProvider.getTruckName
    };
    _firestoreOrder.document(orderID).setData(orderData);
    _firestoreVendor.document(snapshot['vendorPhone']).updateData({"isFree": false}).then((value) {
      Fluttertoast.showToast(msg: "Order Placed");
      dialog.hide();
    });
    OrderProvider().reset();
  }

  void updateProfile(
      String name, String phone, String email, UserPreferences preferences, BuildContext context) {
    _firestoreUser.document(preferences.getUserID).updateData({
      "name": name,
      "email": email,
      "phone": "+91$phone",
    }).whenComplete(() => preferences.init(context));
  }

  void doneAgreement() async {
    FirebaseUser user = await getCurrentUser();
    Firestore.instance.collection('user').document(user.uid).updateData({"isAgree": true});
  }
}
