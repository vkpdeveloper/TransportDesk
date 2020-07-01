import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rideapp/providers/locationViewProvider.dart';
import 'package:rideapp/providers/orderprovider.dart';
import 'package:rideapp/providers/user_provider.dart';

class FirebaseUtils {
  FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference _firestoreUser = Firestore.instance.collection('user');
  CollectionReference _firestoreWallet =
      Firestore.instance.collection('wallet');
  CollectionReference _firestoreVendor =
      Firestore.instance.collection('vendor');

  CollectionReference _firestoreOrder =
      Firestore.instance.collection('allOrders');

  FirebaseMessaging _messaging = FirebaseMessaging();

  Future<bool> getuserexistence(String phone) async {
    final snapShot =
        await Firestore.instance.collection('users').document(phone).get();
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
    final snapShot =
        await Firestore.instance.collection('user').document(user.uid).get();
    if (snapShot.exists) updateToken(user);
    return snapShot.exists;
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
      "name": "${firstName} ${lastName}",
      "phone": user.phoneNumber ?? "",
      "token": token,
      "email": user.email ?? ""
    };
    await _firestoreUser.document(user.uid).setData(data, merge: true);
    DocumentSnapshot walletData =
        await _firestoreWallet.document(user.uid).get();
    if (!walletData.exists) {
      _firestoreWallet
          .document(user.uid)
          .setData({"money": 0, "phone": user.phoneNumber});
    }
  }

  Future<void> saveGoogleLoginData() async {
    FirebaseUser user = await _auth.currentUser();
    String token = await getCurrentUserToken();
    Map<String, dynamic> data = {
      "name": user.displayName,
      "token": token,
      "email": user.email,
    };
    await _firestoreUser.document(user.uid).setData(data, merge: true);
    DocumentSnapshot walletData =
        await _firestoreWallet.document(user.uid).get();
    if (!walletData.exists) {
      _firestoreWallet
          .document(user.uid)
          .setData({"money": 0, "email": user.email});
    }
  }

  // Future<Map<String, dynamic>> startPayment() async {
  //   FlutterPaytm flutterPaytm = FlutterPaytm();
  //   flutterPaytm.configPaytm(
  //       mid: "ynWixv62790112641774",
  //       verificationURL: "https://securegw.paytm.in/theia/processTransaction",
  //       checksumURL: "https://phptestings--vkp1978.repl.co/pgRedirect.php",
  //       industryType: "Retail",
  //       website: "WEBSTAGING",
  //       isTesting: true);
  //   return await flutterPaytm.startPayment(
  //       orderId: "ORDER34324", customerId: "USERIUOIDE", amount: "100");
  // }

  Future<void> startOrder(
      LocationViewProvider locationViewProvider,
      OrderProvider orderProvider,
      UserPreferences userPreferences,
      BuildContext context) async {
    bool isVendorDetected = false;
    ProgressDialog dialog = ProgressDialog(context,
        isDismissible: false, type: ProgressDialogType.Normal);
    dialog.style(
      elevation: 8.0,
      borderRadius: 15,
      message: "Searching for truck...",
      backgroundColor: Colors.white,
      insetAnimCurve: Curves.bounceIn,
    );
    dialog.show();
    DocumentSnapshot selectedVendor;
    QuerySnapshot allVendors = await _firestoreVendor.getDocuments();
    for (DocumentSnapshot vendor in allVendors.documents) {
      if (vendor.data['isFree']) {
        print(vendor.data['userID']);
        selectedVendor = vendor;
        isVendorDetected = true;
        break;
      }
    }
    if (isVendorDetected) {
      dialog.update(message: "Almost done...");
      addBooking(selectedVendor, locationViewProvider, orderProvider, dialog,
          userPreferences, context);
    }
    if (!isVendorDetected) {
      addBookingWithoutVendor(locationViewProvider, orderProvider, dialog,
          userPreferences, context);
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
    if (orderProvider.getSelectedPaymentMethod == 1)
      paymentMethod = "CC or DC Card";
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

  void addForOutside(
      LocationViewProvider locationViewProvider,
      OrderProvider orderProvider,
      ProgressDialog dialog,
      UserPreferences userPreferences,
      BuildContext context) {
    String paymentMethod = "";
    if (orderProvider.getSelectedPaymentMethod == 0) paymentMethod = "Paytm";
    if (orderProvider.getSelectedPaymentMethod == 1)
      paymentMethod = "CC or DC Card";
    if (orderProvider.getSelectedPaymentMethod == 2) paymentMethod = "Cash";
    DateTime currentDate = new DateTime.now();
    String pin = currentDate.millisecond.toString().substring(4, 10);

    String orderID =
        "ORDER${currentDate.day}${currentDate.month}${DateTime.now().millisecondsSinceEpoch.toString().substring(6, 12)}";
    Map<String, dynamic> orderData = {
      "orderID": orderID,
      "userID": userPreferences.getUserID,
      "userToken": userPreferences.getUserToken,
      "userName": userPreferences.getUserName,
      "pickUpPin": pin,
      "userPhone": userPreferences.getUserPhone,
      "receiverName": orderProvider.getReceiverName,
      "receiverPhone": orderProvider.getReceiverPhone,
      "paymentMethod": paymentMethod,
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
      "price": orderProvider.getOrderPrice,
      "truckName": orderProvider.getTruckName
    };
    _firestoreOrder
        .document(orderID)
        .setData(orderData)
        .whenComplete(() => Fluttertoast.showToast(msg: "Order Placed"));
  }

  void addBooking(
      DocumentSnapshot snapshot,
      LocationViewProvider locationViewProvider,
      OrderProvider orderProvider,
      ProgressDialog dialog,
      UserPreferences userPreferences,
      BuildContext context) {
    String paymentMethod = "";
    if (orderProvider.getSelectedPaymentMethod == 0) paymentMethod = "Paytm";
    if (orderProvider.getSelectedPaymentMethod == 1)
      paymentMethod = "CC or DC Card";
    if (orderProvider.getSelectedPaymentMethod == 2) paymentMethod = "Cash";
    DateTime currentDate = new DateTime.now();
    String pin = currentDate.millisecond.toString().substring(4, 10);
    String orderID =
        "ORDER${currentDate.day}${currentDate.month}${DateTime.now().millisecondsSinceEpoch.toString().substring(6, 12)}";
    print(orderID);
    Map<String, dynamic> orderData = {
      "orderID": orderID,
      "userID": userPreferences.getUserID,
      "userToken": userPreferences.getUserToken,
      "userName": userPreferences.getUserName,
      "pickUpPin": pin,
      "userPhone": userPreferences.getUserPhone,
      "receiverName": orderProvider.getReceiverName,
      "receiverPhone": orderProvider.getReceiverPhone,
      "paymentMethod": paymentMethod,
      "riderUserID": snapshot.data['userID'],
      "riderPhone": snapshot.documentID,
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
    _firestoreVendor
        .document(snapshot.documentID)
        .updateData({"isFree": false}).then((value) {
      Fluttertoast.showToast(msg: "Order Placed");
      dialog.hide();
    });
  }

  void updateProfile(String name, String phone, String email,
      UserPreferences preferences, BuildContext context) {
    _firestoreUser.document(preferences.getUserID).updateData({
      "name": name,
      "email": email,
      "phone": "+91$phone",
    }).whenComplete(() => preferences.init(context));
  }
}
