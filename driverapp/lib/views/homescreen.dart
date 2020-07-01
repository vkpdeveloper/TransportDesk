import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driverapp/constants/apikeys.dart';
import 'package:driverapp/controllers/firebase_utils.dart';
import 'package:driverapp/controllers/static_utils.dart';
import 'package:driverapp/enums/order_loading_state.dart';
import 'package:driverapp/providers/order_provider.dart';
import 'package:driverapp/providers/user_sharedpref_provider.dart';
import 'package:driverapp/services/firebase_auth_service.dart';
import 'package:driverapp/views/signup/Verification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission/permission.dart';
import 'package:provider/provider.dart';
import 'package:driverapp/constants/themecolors.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

// to check if user exists in vendor list

class VerificationCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _fireutils = FirebaseUtils();
    Future vendorexists = _fireutils.isVendorExists();
    return FutureBuilder(
      future: vendorexists,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final _exists = snapshot.data;
          if (_exists) {
            return HomeScreen();
          }
          return Verification();
        } else {
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _TrackOrderState createState() => _TrackOrderState();
}

class _TrackOrderState extends State<HomeScreen> {
  StaticUtils _staticUtils = StaticUtils();
  LatLng _pickUpLatLng;
  LatLng _destinationLatLng;
  String _userName;
  String _receiverName;
  int _price;
  double _distance;
  String _receiverMobileNumber, _userMobileNumber;
  List _addresses;
  String orderid;
  CollectionReference _collectionReference =
      Firestore.instance.collection('allOrders');
  GoogleMapController _mapsController;
  Set<Polyline> _polyLines = {};
  Set<Marker> _markers = {};
  GoogleMapPolyline _googleMapPolyline =
      GoogleMapPolyline(apiKey: APIKeys.googleMapsAPI);
  Map<String, dynamic> dataOfPickUp;
  Map<String, dynamic> dataFromDriver;
  bool isPanelOpen = false;
  List<LatLng> allLats;
  bool _isOrderStarted = false;
  FirebaseUtils _firebaseUtils = FirebaseUtils();
  PanelController _controller;
  String riderAddress;
  bool isPicked = false;
  bool isDropped = false;
  String _truckName;
  LatLng _driverLatLng;
  Timer _updateTimer;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  OrderLoadingState orderLoadingState = OrderLoadingState.LOADING;
  bool _isReachedPickUp = false;
  TextEditingController _pickUpPinController = TextEditingController();
  String pickUpPin = "";
  bool _isReachedDrop = false;
  String dropPin = "";
  FirebaseMessaging _messaging = FirebaseMessaging();
  String firebaseUserToken = "";

  @override
  void initState() {
    super.initState();
    getOrderDetails();
    _controller = PanelController();
    getTokenAndSubscribe();
  }

  getTokenAndSubscribe() async {
    firebaseUserToken = await _messaging.getToken();
    _messaging.subscribeToTopic("vendor");
    Firestore.instance.collection('vendor').document(await _firebaseUtils.getuserphoneno()).updateData({
      "token": firebaseUserToken
    });
  }

  void dispose() {
    super.dispose();
  }

  getOrderDetails() async {
    QuerySnapshot docs = await _collectionReference
        .where("isDelivered", isEqualTo: false)
        .getDocuments();
    if (docs.documents.length == 1) {
      docs.documents.forEach((DocumentSnapshot doc) {
        _pickUpLatLng =
            LatLng(doc.data['pickUpLatLng'][0], doc.data['pickUpLatLng'][1]);
        _destinationLatLng =
            LatLng(doc.data['destLatLng'][0], doc.data['destLatLng'][1]);
        _price = doc.data['price'];
        _distance = doc.data['distance'];
        _userName = doc.data['userName'];
        _receiverName = doc.data['receiverName'];
        _addresses = doc.data['addresses'];
        _isOrderStarted = doc.data['isStart'];
        _receiverMobileNumber = doc.data['receiverPhone'];
        _userMobileNumber = doc.data['userPhone'];
        isPicked = doc.data['isPicked'];
        isDropped = doc.data['isDelivered'];
        _truckName = doc.data['truckName'];
        _isOrderStarted = doc.data['isStart'];
        orderid = doc.documentID;
      });
      var permissions =
          await Permission.getPermissionsStatus([PermissionName.Location]);
      if (permissions[0].permissionStatus == PermissionStatus.notAgain) {
        var askpermissions =
            await Permission.requestPermissions([PermissionName.Location]);
      } else {
        try {
          print(_pickUpLatLng);
          print(_destinationLatLng);
          List<LatLng> newLats =
              await _googleMapPolyline.getCoordinatesWithLocation(
                  origin: _pickUpLatLng,
                  destination: _destinationLatLng,
                  mode: RouteMode.driving);
          setState(() {
            allLats = newLats;
          });
        } catch (e) {
          print("Error : ${e.toString()}");
        }
      }
      Map<String, dynamic> mapData = await _staticUtils.getDistenceAndDuration(
          _addresses[0], _addresses[1]);
      if (!mounted) return;
      setState(() {
        dataOfPickUp = mapData;
        orderLoadingState = OrderLoadingState.IDLE;
        if (isPicked == true) {
          Timer.periodic(Duration(seconds: 2), (timer) => updatelocation());
        }
      });
      getRiderLocation();
    } else {
      setState(() {
        orderLoadingState = OrderLoadingState.NOORDER;
      });
      return;
    }
  }

  updatelocation() async {
    Position pause = await Geolocator().getCurrentPosition();
    Firestore.instance.collection('allOrders').document(orderid).updateData({
      "riderPoint": [pause.latitude, pause.longitude]
    });
  }

  getRiderLocation() async {
    Position position = await Geolocator().getCurrentPosition();
    _driverLatLng = LatLng(position.latitude, position.longitude);
    String address = await _staticUtils
        .getAddressByLatLng(LatLng(position.latitude, position.longitude));
    Map<String, dynamic> mapData =
        await _staticUtils.getDistenceAndDuration(address, _addresses[1]);
    if (!mounted) return;
    setState(() {
      dataFromDriver = mapData;
      riderAddress = address;
    });
  }

  sendPinNotf(bool isPickUp) async {
    DocumentSnapshot pin = await Firestore.instance
        .collection('allOrders')
        .document(orderid)
        .get();
    if (pin.exists) {
      if (isPickUp) {
        String pickString = pin.data['pickUpPin'];
        setState(() {
          pickUpPin = pickString;
          _isReachedPickUp = true;
        });
      } else {
        String dropString = pin.data['dropPin'];
        setState(() {
          dropPin = dropString;
          _isReachedDrop = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    OrderProvider provider = Provider.of<OrderProvider>(context);
    UserPreferences userPreferences = Provider.of<UserPreferences>(context);
    FirebaseAuthService _auth = Provider.of<FirebaseAuthService>(context);
    if (userPreferences.getUserName == "") {
      userPreferences.init();
    }
    if (orderLoadingState == OrderLoadingState.LOADING) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor)),
        ),
      );
    }
    if (orderLoadingState == OrderLoadingState.IDLE) {
      return Scaffold(
          drawer: Drawer(
            elevation: 20.0,
            child: Column(
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/profilescreen');
                    },
                    child: UserAccountsDrawerHeader(
                      currentAccountPicture: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            NetworkImage(userPreferences.getProfile),
                        backgroundColor: ThemeColors.primaryColor,
                      ),
                      accountName: Text(userPreferences.getUserName),
                      accountEmail: Text(userPreferences.getUserPhone),
                    )),
                ListTile(
                  onTap: () => Navigator.pushNamed(context, '/walletscreen'),
                  leading: Icon(Icons.account_balance_wallet,
                      color: ThemeColors.primaryColor),
                  title: Text(
                    "Wallet",
                    style: TextStyle(color: ThemeColors.primaryColor),
                  ),
                ),
                ListTile(
                  onTap: () => Navigator.pushNamed(context, '/bookings'),
                  leading: Icon(Icons.history, color: ThemeColors.primaryColor),
                  title: Text(
                    "History",
                    style: TextStyle(color: ThemeColors.primaryColor),
                  ),
                ),
                ListTile(
                  onTap: () => Navigator.pushNamed(context, '/notification'),
                  leading: Icon(Icons.notifications,
                      color: ThemeColors.primaryColor),
                  title: Text(
                    "Notifications",
                    style: TextStyle(color: ThemeColors.primaryColor),
                  ),
                ),
                ListTile(
                  onTap: () => Navigator.pushNamed(context, '/referral'),
                  leading: Icon(Icons.card_giftcard,
                      color: ThemeColors.primaryColor),
                  title: Text(
                    "Invite Friends",
                    style: TextStyle(color: ThemeColors.primaryColor),
                  ),
                ),
                ListTile(
                  onTap: () => Navigator.pushNamed(context, '/chat'),
                  leading: Icon(Icons.phone, color: ThemeColors.primaryColor),
                  title: Text(
                    "Support",
                    style: TextStyle(color: ThemeColors.primaryColor),
                  ),
                ),
                ListTile(
                  leading:
                      Icon(Icons.exit_to_app, color: ThemeColors.primaryColor),
                  title: GestureDetector(
                    onTap: () {
                      _auth.signOut();
                      Navigator.pushReplacementNamed(context, '/loginscreen');
                    },
                    child: Text(
                      "Logout",
                      style: TextStyle(color: ThemeColors.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          key: _scaffoldKey,
          body: SlidingUpPanel(
            onPanelSlide: (double offset) {
              if (offset > 0.540) {
                if (!_isOrderStarted) {
                  _controller.close();
                } else {
                  setState(() {
                    isPanelOpen = true;
                  });
                }
              } else {
                setState(() {
                  isPanelOpen = false;
                });
              }
            },
            defaultPanelState: PanelState.CLOSED,
            body: Stack(
              children: [
                allLats == null
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ThemeColors.primaryColor),
                        ),
                      )
                    : GoogleMap(
                        polylines: _polyLines,
                        markers: _markers,
                        onTap: (LatLng newPosition) {},
                        myLocationButtonEnabled: false,
                        myLocationEnabled: true,
                        buildingsEnabled: true,
                        scrollGesturesEnabled: true,
                        mapType: MapType.terrain,
                        initialCameraPosition: CameraPosition(
                            target: _pickUpLatLng,
                            zoom: 11.0,
                            tilt: 20.0,
                            bearing: 40.0),
                        onMapCreated: (GoogleMapController controller) {
                          _mapsController = controller;
                          if (!mounted) return;
                          setState(() {
                            _markers.add(Marker(
                                markerId: MarkerId('pickUp'),
                                icon: BitmapDescriptor.defaultMarker,
                                visible: true,
                                draggable: false,
                                position: _pickUpLatLng,
                                infoWindow: InfoWindow(
                                    title: "PickUp Position",
                                    snippet:
                                        "You have to cover ${dataOfPickUp['distance']}")));
                            _markers.add(Marker(
                                markerId: MarkerId('destination'),
                                icon: BitmapDescriptor.defaultMarker,
                                visible: true,
                                draggable: false,
                                position: _destinationLatLng,
                                infoWindow: InfoWindow(
                                    title: "Drop Position",
                                    snippet: "This is the drop postion")));
                            _polyLines.add(Polyline(
                                jointType: JointType.round,
                                startCap: Cap.roundCap,
                                endCap: Cap.buttCap,
                                polylineId: PolylineId('location'),
                                color: Colors.lightBlue,
                                width: 8,
                                onTap: () {
                                  _mapsController
                                      .showMarkerInfoWindow(MarkerId('pickUp'));
                                },
                                geodesic: true,
                                visible: true,
                                points: allLats));
                          });
                          provider.setIsPicked(isPicked);
                          provider.setIsDropped(isDropped);
                        },
                      ),
                Positioned(
                  top: 30,
                  left: 10,
                  child: FloatingActionButton(
                    backgroundColor: ThemeColors.primaryColor,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.menu),
                    onPressed: () => _scaffoldKey.currentState.openDrawer(),
                  ),
                )
              ],
            ),
            controller: _controller,
            minHeight: MediaQuery.of(context).size.height / 3 + 10,
            maxHeight: MediaQuery.of(context).size.height,
            collapsed: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Hey, ${userPreferences.getUserName}',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          Text(dataOfPickUp != null
                              ? "Total time : ${dataOfPickUp['duration']}"
                              : "loading...")
                        ],
                      )),
                  ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: Colors.green,
                    ),
                    title: Text("Pickup Address"),
                    subtitle:
                        Text(_addresses == null ? "loading..." : _addresses[0]),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    title: Text("Drop Address"),
                    subtitle:
                        Text(_addresses == null ? "loading..." : _addresses[1]),
                  ),
                  if (!_isOrderStarted) ...[
                    SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FloatingActionButton.extended(
                            label: Text(
                              "Decline",
                              style: TextStyle(color: Colors.black),
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white,
                            onPressed: () =>
                                _firebaseUtils.declineOrder(orderid, context),
                            heroTag: "decline",
                            icon: Icon(
                              Icons.close,
                              color: Colors.black,
                            ),
                          ),
                          FloatingActionButton.extended(
                            label: Text("Accept"),
                            foregroundColor: Colors.white,
                            backgroundColor: ThemeColors.primaryColor,
                            onPressed: () {
                              _firebaseUtils.acceptOrder(orderid, _controller,
                                  _driverLatLng, _updateTimer, provider);
                              setState(() => _isOrderStarted = true);
                            },
                            heroTag: "accept",
                            icon: Icon(Icons.check),
                          ),
                        ],
                      ),
                    )
                  ]
                ],
              ),
            ),
            panel: isPanelOpen
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 40.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          // ListTile(
                          //   leading: Icon(Icons.location_on),
                          //   title: Text("Pickup Address"),
                          //   subtitle: Text(_addresses == null
                          //       ? "loading..."
                          //       : _addresses[0]),
                          // ),
                          ListTile(
                            leading: Icon(Icons.confirmation_number),
                            title: Text("OrderId"),
                            subtitle: Text(orderid ?? 'loading'),
                          ),
                          ListTile(
                              leading: Icon(Icons.watch_later),
                              title: Text(
                                  "Duration & Distance (from pickup to drop)"),
                              subtitle: Row(
                                children: <Widget>[
                                  Text(dataOfPickUp == null
                                      ? "loading..."
                                      : dataOfPickUp['duration']),
                                  SizedBox(width: 20),
                                  Text(dataOfPickUp == null
                                      ? "loading..."
                                      : dataOfPickUp['distance']),
                                ],
                              )),
                          ListTile(
                              leading: Icon(Icons.watch_later),
                              title: Text(
                                  "Duration & Distance (from your location to drop)"),
                              subtitle: Row(
                                children: <Widget>[
                                  Text(dataFromDriver == null
                                      ? "loading..."
                                      : dataFromDriver['duration']),
                                  SizedBox(width: 20),
                                  Text(dataFromDriver == null
                                      ? "loading..."
                                      : dataFromDriver['distance']),
                                ],
                              )),
                          // ListTile(
                          //   leading: Icon(Icons.person),
                          //   title: Text("User Name and Phone"),
                          //   subtitle: Text(_userName),
                          // ),
                          ListTile(
                            leading: Icon(Icons.call),
                            trailing: IconButton(
                              onPressed: () =>
                                  launch("tel: $_userMobileNumber"),
                              color: ThemeColors.primaryColor,
                              icon: Icon(Icons.call),
                            ),
                            title: Text("User Name and Phone"),
                            subtitle: Text(
                                '$_userName  ${_userMobileNumber.replaceAll("+91", "")}'),
                          ),
                          // ListTile(
                          //   leading: Icon(Icons.person),
                          //   title: Text("Receiver Name"),
                          //   subtitle: Text(_receiverName),
                          // ),
                          ListTile(
                            leading: Icon(Icons.call),
                            trailing: IconButton(
                              onPressed: () =>
                                  launch("tel: +91$_receiverMobileNumber"),
                              color: ThemeColors.primaryColor,
                              icon: Icon(Icons.call),
                            ),
                            title: Text("Receivern Name and Phone"),
                            subtitle:
                                Text('$_receiverName $_receiverMobileNumber'),
                          ),
                          ListTile(
                            leading: Icon(AntDesign.car),
                            title: Text("Required Truck"),
                            subtitle: Text(_truckName),
                          ),
                          SizedBox(height: 5),
                          if (provider.getIsPicked && !provider.getIsDropped)
                            if (_isReachedDrop)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: <Widget>[
                                    TextField(
                                      controller: _pickUpPinController,
                                      maxLength: 6,
                                      decoration: InputDecoration(
                                          hintText: "Enter Drop OTP",
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0))),
                                    ),
                                    MaterialButton(
                                      onPressed: () {
                                        if (_isReachedDrop &&
                                            !_isReachedPickUp) {
                                          print(dropPin);
                                          if (_pickUpPinController.text ==
                                              dropPin) {
                                            _firebaseUtils.deliveryDone(
                                                orderid,
                                                provider,
                                                _pickUpPinController,
                                                dropPin);
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Order deliverd successfully");
                                            setState(() => orderLoadingState =
                                                OrderLoadingState.NOORDER);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: "Invalid Drop PIN");
                                          }
                                        }

                                        _pickUpPinController.clear();
                                      },
                                      child: Text("VERIFY"),
                                      color: ThemeColors.primaryColor,
                                      textColor: Colors.white,
                                    )
                                  ],
                                ),
                              ),
                          if (provider.getIsPicked &&
                              !provider.getIsDropped &&
                              !_isReachedDrop)
                            FloatingActionButton.extended(
                              heroTag: "have_delivered",
                              backgroundColor: ThemeColors.primaryColor,
                              foregroundColor: Colors.white,
                              onPressed: () {
                                sendPinNotf(false);
                              },
                              icon: Icon(Icons.check),
                              label: Text("Delivery Done"),
                            ),
                          if (!provider.getIsPicked)
                            if (!_isReachedPickUp)
                              FloatingActionButton.extended(
                                heroTag: "have_picked",
                                backgroundColor: ThemeColors.primaryColor,
                                foregroundColor: Colors.white,
                                onPressed: () => {
                                  //
                                  sendPinNotf(true),
                                },
                                label: Text("Reached pickup ?"),
                              ),
                          if (_isReachedPickUp)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: <Widget>[
                                  TextField(
                                    controller: _pickUpPinController,
                                    maxLength: 6,
                                    decoration: InputDecoration(
                                        hintText: "Enter PickUp OTP",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0))),
                                  ),
                                  MaterialButton(
                                    onPressed: () {
                                      if (_pickUpPinController.text.length ==
                                          6) {
                                        _firebaseUtils.pickUpDone(
                                            orderid,
                                            provider,
                                            _pickUpPinController,
                                            pickUpPin);
                                        setState(() {
                                          _isReachedPickUp = false;
                                        });
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Enter a valid PIN");
                                        setState(() {
                                          _isReachedPickUp = false;
                                        });
                                      }
                                      _pickUpPinController.clear();
                                    },
                                    child: Text("VERIFY"),
                                    color: ThemeColors.primaryColor,
                                    textColor: Colors.white,
                                  )
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 4.0,
                  spreadRadius: 5.0)
            ],
            isDraggable: true,
            parallaxEnabled: true,
            color: Colors.white,
          ));
    }
    if (orderLoadingState == OrderLoadingState.NOORDER) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Home"),
            actions: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    userPreferences.getIsFree ? "Online" : "Offline",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          userPreferences.getIsFree ? Colors.green : Colors.red,
                    ),
                  ),
                  Switch(
                    activeColor: Colors.lightBlue,
                    value: userPreferences.getIsFree,
                    onChanged: (val) {
                      userPreferences.setIsFree(val);
                      if (val = true) {
                        getOrderDetails();
                      }
                    },
                  )
                ],
              ),
            ],
          ),
          drawer: Drawer(
            elevation: 20.0,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/profilescreen');
                  },
                  child: UserAccountsDrawerHeader(
                    accountName: Text(userPreferences.getUserName),
                    accountEmail: Text(userPreferences.getUserPhone),
                    currentAccountPicture: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(userPreferences.getProfile),
                      backgroundColor: ThemeColors.primaryColor,
                    ),
                  ),
                ),
                ListTile(
                  onTap: () => Navigator.pushNamed(context, '/walletscreen'),
                  leading: Icon(Icons.account_balance_wallet,
                      color: ThemeColors.primaryColor),
                  title: Text(
                    "Wallet",
                    style: TextStyle(color: ThemeColors.primaryColor),
                  ),
                ),
                ListTile(
                  onTap: () => Navigator.pushNamed(context, '/bookings'),
                  leading: Icon(Icons.history, color: ThemeColors.primaryColor),
                  title: Text(
                    "History",
                    style: TextStyle(color: ThemeColors.primaryColor),
                  ),
                ),
                ListTile(
                  onTap: () => Navigator.pushNamed(context, '/notification'),
                  leading: Icon(Icons.notifications,
                      color: ThemeColors.primaryColor),
                  title: Text(
                    "Notifications",
                    style: TextStyle(color: ThemeColors.primaryColor),
                  ),
                ),
                ListTile(
                  onTap: () => Navigator.pushNamed(context, '/referral'),
                  leading: Icon(Icons.card_giftcard,
                      color: ThemeColors.primaryColor),
                  title: Text(
                    "Invite Friends",
                    style: TextStyle(color: ThemeColors.primaryColor),
                  ),
                ),
                ListTile(
                  onTap: () => Navigator.pushNamed(context, '/chat'),
                  leading: Icon(Icons.phone, color: ThemeColors.primaryColor),
                  title: Text(
                    "Support",
                    style: TextStyle(color: ThemeColors.primaryColor),
                  ),
                ),
                ListTile(
                  leading:
                      Icon(Icons.exit_to_app, color: ThemeColors.primaryColor),
                  title: GestureDetector(
                    onTap: () {
                      _auth.signOut();
                      Navigator.pushReplacementNamed(context, '/loginscreen');
                    },
                    child: Text(
                      "Logout",
                      style: TextStyle(color: ThemeColors.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Center(
              child: Container(
            height: 100,
            width: 200,
            child: Column(
              children: <Widget>[
                Text(
                  "No live orders !",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                MaterialButton(
                  onPressed: () {
                    getOrderDetails();
                  },
                  child: Text("Refresh"),
                )
              ],
            ),
          )));
    }
  }
}
