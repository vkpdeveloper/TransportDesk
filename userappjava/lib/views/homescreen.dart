import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/AppLocalizations.dart';
import 'package:rideapp/constants/apikeys.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:rideapp/controllers/firebase_utils.dart';
import 'package:rideapp/controllers/static_utils.dart';
import 'package:rideapp/enums/locationview.dart';
import 'package:rideapp/enums/station_view.dart';
import 'package:rideapp/enums/view_state.dart';
import 'package:rideapp/model/location_details.dart';
import 'package:rideapp/model/location_result.dart';
import 'package:rideapp/providers/locationViewProvider.dart';
import 'package:rideapp/providers/orderprovider.dart';
import 'package:rideapp/providers/user_provider.dart';
import 'package:rideapp/services/firebase_auth_service.dart';
import 'package:rideapp/utils/uuid.dart';
import 'package:rideapp/views/drop_location_screen.dart';
import 'package:rideapp/views/orderdetailsscreen.dart';
import 'package:rideapp/views/saveaddress_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController _googleMapController;
  PanelController _controller;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLocalSelected = true;
  bool isNowOpen = true;
  bool isOutSideSelected = false;
  LatLng initLatLng;
  double zoomView = 18;
  TextEditingController _pickUpController;
  TextEditingController _destinationController;
  bool isPanelOpenComplete = false;
  FocusNode _pickFocusNode = FocusNode();
  FocusNode _mainFocusNode = FocusNode();
  String mainAddress;
  Timer _debounce;
  bool hasSearchTerm = false;
  bool isSearchingCurrently = false;
  String searchVal = "";
  StaticUtils _utils = StaticUtils();
  String googleMapsAPIKeys = APIKeys.googleMapsAPI;
  LocationResult locationResult;
  String sessionToken = Uuid().generateV4();
  List<LocationDetails> allLocations = [];
  Set<Polyline> _polyLines = {};
  ViewState _viewState = ViewState.DEFAULT;
  FocusNode _dropFocusNode = FocusNode();
  BitmapDescriptor pinLocationIcon;
  final String SEARCHING_LOCATIONS = "Searching locations...";
  final String NOT_FOUND = "No result found";
  GlobalKey<FormState> _locationForm = GlobalKey<FormState>();
  GoogleMapPolyline _googleMapPolyline = GoogleMapPolyline(apiKey: APIKeys.googleMapsAPI);
  int price;
  bool isShowMarker = true;
  Set<Marker> _markers = {};
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FirebaseUtils _firebaseUtils = FirebaseUtils();

  getCurrentLocation() async {
    _pickUpController.text = "Fetching...";
    bool status = Geolocator().forceAndroidLocationManager;
    print(status);
    Geolocator().checkGeolocationPermissionStatus().then((GeolocationStatus status) {
      print(status);
    });
    try {
      Position pos = await Geolocator().getCurrentPosition();
      http.Response res = await http.get(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${pos.latitude},${pos.longitude}&key=${APIKeys.googleMapsAPI}');
      var data = jsonDecode(res.body);
      var addressGet = data['results'][0]['formatted_address'];
      if (mounted)
        setState(() {
          initLatLng = LatLng(pos.latitude, pos.longitude);
          mainAddress = addressGet;
          _pickUpController.text = mainAddress;
        });
      print(addressGet);
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: appLocalizations.translate("Error in getting address"));
    }
  }

  chooseCurentLocation() async {
    if (locationViewProvider.getLocationView == LocationView.PICKUPSELECTED) {
      _pickUpController.text = "Fetching...";
    } else {
      _destinationController.text = "Fetching...";
    }
    bool status = Geolocator().forceAndroidLocationManager;
    print(status);
    Geolocator().checkGeolocationPermissionStatus().then((GeolocationStatus status) {
      print(status);
    });
    try {
      Position pos = await Geolocator().getCurrentPosition();
      http.Response res = await http.get(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${pos.latitude},${pos.longitude}&key=${APIKeys.googleMapsAPI}');
      var data = jsonDecode(res.body);
      var addressGet = data['results'][0]['formatted_address'];
      if (mounted)
        setState(() {
          initLatLng = LatLng(pos.latitude, pos.longitude);
          mainAddress = addressGet;
          if (locationViewProvider.getLocationView == LocationView.PICKUPSELECTED) {
            _pickUpController.text = mainAddress;
          } else {
            _destinationController.text = mainAddress;
          }
        });
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: appLocalizations.translate("Error in getting address"));
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = PanelController();
    _pickUpController = TextEditingController();
    _destinationController = TextEditingController();
    _pickUpController.addListener(_onSearchChangedPickUp);
    _destinationController.addListener(_onSearchChangedDrop);
    getCurrentLocation();
    _utils.getBytesFromAsset('asset/images/marker.png', 124).then((value) {
      pinLocationIcon = BitmapDescriptor.fromBytes(value);
      _firebaseUtils.getisFareHighHours();
    });
  }

  _onSearchChangedPickUp() {
    if (appLocalizations != null) {
      allLocations.clear();
      if (_pickUpController.text.isEmpty) {
        setState(() {
          isSearchingCurrently = false;
          allLocations.clear();
          searchVal = appLocalizations.translate("Searchdone");
        });
      }
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        searchPlace(_pickUpController.text);
      });
    }
  }

  moveCamera(LatLng latLng) {
    _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(zoom: 18.0, tilt: 70.0, bearing: 180, target: latLng)));
  }

  _onSearchChangedDrop() {
    if (appLocalizations != null) {
      allLocations.clear();
      if (_destinationController.text.isEmpty) {
        setState(() {
          isSearchingCurrently = false;
          allLocations.clear();

          searchVal = appLocalizations.translate("Searchdone");
        });
      }
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        searchPlace(_destinationController.text);
      });
    }
  }

  void searchPlace(String place) {
    if (appLocalizations != null) {
      if (_scaffoldKey.currentContext == null) return;

      setState(() => hasSearchTerm = place.length > 0);

      if (place.length < 1) return;

      setState(() {
        isSearchingCurrently = true;
        searchVal = appLocalizations.translate("Searching locations...");
      });

      if (appLocalizations != null) autoCompleteSearch(place);
    }
  }

  void autoCompleteSearch(String place) {
    place = place.replaceAll(" ", "+");
    var endpoint;
    if (orderProvider.getStationView == StationView.LOCAL) {
      endpoint = "https://maps.googleapis.com/maps/api/place/autocomplete/json?" +
          "key=${googleMapsAPIKeys}&" +
          "input={$place}&sessiontoken=$sessionToken&location=28.6143478,77.197236&radius=50000&strictbounds";
    } else {
      endpoint = "https://maps.googleapis.com/maps/api/place/autocomplete/json?" +
          "key=${googleMapsAPIKeys}&" +
          "input={$place}&sessiontoken=$sessionToken&location=22.9506095,75.7693752&radius=1500000&strictbounds";
    }
    http.get(endpoint).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> predictions = data['predictions'];
        allLocations.clear();
        if (predictions.isEmpty) {
          setState(() => searchVal = appLocalizations.translate("No result found"));
        } else {
          for (dynamic single in predictions) {
            LocationDetails detail = LocationDetails(
                locationAddress: single['description'], locationID: single['place_id']);
            allLocations.add(detail);
          }
          print(allLocations.length);
          setState(() {
            isSearchingCurrently = false;
            searchVal = appLocalizations.translate("Searchdone");
          });
        }
      }
    });
  }

  Future<LatLng> decodeAndSelectPlace(String placeId) async {
    String endpoint =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeId}&key=$googleMapsAPIKeys";

    http.Response response = await http.get(endpoint);
    print(jsonDecode(response.body));
    Map<String, dynamic> location = jsonDecode(response.body)['result']['geometry']['location'];
    LatLng latLng = LatLng(location['lat'], location['lng']);
    return latLng;
  }

  Future<List<LatLng>> getPolylinePoints(LocationViewProvider provider) async {
    return await _googleMapPolyline.getCoordinatesWithLocation(
        origin: provider.getPickUpLatLng,
        destination: provider.getDestinationLatLng,
        mode: RouteMode.driving);
  }

  void resetPanel() {
    _viewState = ViewState.DEFAULT;
    //TODO reset order provider
  }

  UserPreferences userPreferences;
  LocationViewProvider locationViewProvider;
  OrderProvider orderProvider;
  AppLocalizations appLocalizations;
  @override
  Widget build(BuildContext context) {
    userPreferences = Provider.of<UserPreferences>(context);
    locationViewProvider = Provider.of<LocationViewProvider>(context);
    orderProvider = Provider.of<OrderProvider>(context);
    FirebaseAuthService _auth = Provider.of<FirebaseAuthService>(context, listen: false);
    appLocalizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (userPreferences.getUserName == "") {
      userPreferences.init(context);
    }
    return WillPopScope(
      onWillPop: () async {
        if (isPanelOpenComplete) {
          _controller.close();
        } else {
          return true;
        }
      },
      child: Scaffold(
          drawer: Drawer(
            elevation: 8.0,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(userPreferences.getUserName),
                    accountEmail: Text(userPreferences.getUserPhone != ""
                        ? userPreferences.getUserPhone
                        : userPreferences.getUserEmail),
                  ),
                  ListTile(
                    onTap: () => Navigator.pushNamed(context, '/profile', arguments: {
                      "pref": userPreferences,
                    }),
                    leading: Icon(Icons.person_outline, color: ThemeColors.primaryColor),
                    title: Text(
                      appLocalizations.translate("My Profile"),
                      style: TextStyle(color: ThemeColors.primaryColor),
                    ),
                  ),
                  ListTile(
                    onTap: () => Navigator.pushNamed(context, '/allordersscreen'),
                    leading: Icon(Icons.event_note, color: ThemeColors.primaryColor),
                    title: Text(
                      appLocalizations.translate("All Bookings"),
                      style: TextStyle(color: ThemeColors.primaryColor),
                    ),
                  ),
                  ListTile(
                    onTap: () => Navigator.pushNamed(context, '/walletscreen'),
                    leading: Icon(Icons.account_balance_wallet, color: ThemeColors.primaryColor),
                    title: Text(
                      appLocalizations.translate("Wallet"),
                      style: TextStyle(color: ThemeColors.primaryColor),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    onTap: () => Navigator.pushNamed(context, '/savedaddressscreen'),
                    leading: Icon(Icons.location_city, color: ThemeColors.primaryColor),
                    title: Text(
                      appLocalizations.translate("Saved Address"),
                      style: TextStyle(color: ThemeColors.primaryColor),
                    ),
                  ),
                  ListTile(
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
                    leading: Icon(Icons.notifications, color: ThemeColors.primaryColor),
                    title: Text(
                      appLocalizations.translate("Notifications"),
                      style: TextStyle(color: ThemeColors.primaryColor),
                    ),
                  ),
                  ListTile(
                    leading: Icon(AntDesign.customerservice, color: ThemeColors.primaryColor),
                    title: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/support'),
                      child: Text(
                        appLocalizations.translate("Support"),
                        style: TextStyle(color: ThemeColors.primaryColor),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    leading: Icon(Icons.web, color: ThemeColors.primaryColor),
                    title: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/weblogin');
                      },
                      child: Text(
                        "Web Login",
                        style: TextStyle(color: ThemeColors.primaryColor),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Feather.info, color: ThemeColors.primaryColor),
                    title: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/aboutus');
                      },
                      child: Text(
                        appLocalizations.translate("About"),
                        style: TextStyle(color: ThemeColors.primaryColor),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.exit_to_app, color: ThemeColors.primaryColor),
                    title: GestureDetector(
                      onTap: () {
                        _auth.signOut();
                        Navigator.pushReplacementNamed(context, '/loginscreen');
                      },
                      child: Text(
                        appLocalizations.translate("Logout"),
                        style: TextStyle(color: ThemeColors.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          key: _scaffoldKey,
          body: SlidingUpPanel(
            color: Colors.white,
            controller: _controller,
            parallaxEnabled: true,
            isDraggable: true,
            collapsed: _renderCollapsed(orderProvider, locationViewProvider),
            onPanelClosed: () {
              allLocations.clear();
              _pickFocusNode.unfocus();
              setState(() {
                isPanelOpenComplete = false;
              });
            },
            onPanelOpened: () {
              allLocations.clear();
              setState(() {
                isPanelOpenComplete = true;
                _pickUpController.text = locationViewProvider.getPickUpPointAddress;
              });
            },
            defaultPanelState: PanelState.CLOSED,
            boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.grey.shade100)],
            maxHeight: MediaQuery.of(context).size.height,
            minHeight: (MediaQuery.of(context).size.height / 2) - 40,
            panel: !isPanelOpenComplete
                ? Container()
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                    child: Stack(
                      children: [
                        Column(
                          children: <Widget>[
                            Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: <Widget>[
                                    Icon(Octicons.primitive_dot, color: ThemeColors.primaryColor),
                                    Text(
                                        _pickFocusNode.hasFocus == true
                                            ? appLocalizations.translate("Pick Up Location")
                                            : appLocalizations.translate("Drop Location"),
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: ThemeColors.primaryColor,
                                            fontWeight: FontWeight.bold))
                                  ],
                                )),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Form(
                                        key: _locationForm,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              validator: (val) {
                                                if (val.length <= 5) {
                                                  return appLocalizations
                                                      .translate("Enter a valid address");
                                                }
                                              },
                                              onChanged: (val) {
                                                if (val.isEmpty) {
                                                  setState(() {
                                                    searchVal =
                                                        appLocalizations.translate("Searchdone");

                                                    isSearchingCurrently = false;
                                                  });

                                                  locationViewProvider.setPickUpAddress(val);
                                                } else {
                                                  locationViewProvider.setPickUpAddress(val);
                                                }
                                              },
                                              onTap: () {
                                                locationViewProvider
                                                    .setLocationView(LocationView.PICKUPSELECTED);
                                                _pickFocusNode.requestFocus();
                                              },
                                              controller: _pickUpController,
                                              focusNode: _pickFocusNode,
                                              style: TextStyle(
                                                  color: ThemeColors.primaryColor, fontSize: 16.0),
                                              decoration: InputDecoration(
                                                  icon: Icon(Octicons.primitive_dot,
                                                      color: Colors.green),
                                                  hintText: appLocalizations
                                                      .translate("Your Pickup Location"),
                                                  border: OutlineInputBorder(
                                                    borderSide:
                                                        BorderSide(color: ThemeColors.primaryColor),
                                                    borderRadius: BorderRadius.circular(10),
                                                  )),
                                            ),
                                            SizedBox(height: 10.0),
                                            TextFormField(
                                              validator: (val) {
                                                if (val.length <= 5) {
                                                  return appLocalizations
                                                      .translate("Enter a valid address");
                                                }
                                              },
                                              focusNode: _dropFocusNode,
                                              onChanged: (val) {
                                                if (val.isEmpty) {
                                                  setState(() {
                                                    searchVal =
                                                        appLocalizations.translate("Searchdone");

                                                    isSearchingCurrently = false;
                                                  });

                                                  locationViewProvider
                                                      .setDestinationPointAddress(val);
                                                } else {
                                                  locationViewProvider
                                                      .setDestinationPointAddress(val);
                                                }
                                              },
                                              onTap: () {
                                                locationViewProvider.setLocationView(
                                                    LocationView.DESTINATIONSELECTED);
                                                _dropFocusNode.requestFocus();
                                              },
                                              controller: _destinationController,
                                              style: TextStyle(
                                                  color: ThemeColors.primaryColor, fontSize: 16.0),
                                              decoration: InputDecoration(
                                                  icon: Icon(Octicons.primitive_dot,
                                                      color: Colors.red),
                                                  hintText: appLocalizations
                                                      .translate("Your Drop Location"),
                                                  border: OutlineInputBorder(
                                                    borderSide:
                                                        BorderSide(color: ThemeColors.primaryColor),
                                                    borderRadius: BorderRadius.circular(10),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            if (allLocations.length > 0)
                              Expanded(
                                child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  children: <Widget>[
                                    if (isSearchingCurrently && allLocations.length == 0)
                                      _isSearchingOrNotFound(searchVal),
                                    if (!isSearchingCurrently && allLocations.length > 2)
                                      for (LocationDetails detail in allLocations) ...[
                                        Container(
                                          decoration:
                                              BoxDecoration(color: Colors.white, boxShadow: [
                                            BoxShadow(color: Colors.grey.shade100, blurRadius: 14.0)
                                          ]),
                                          child: ListTile(
                                            onTap: () async {
                                              _controller.close();

                                              LatLng getLatLng =
                                                  await decodeAndSelectPlace(detail.locationID);

                                              if (getLatLng != null) {
                                                mainAddress = detail.locationAddress;

                                                moveCamera(getLatLng);

                                                locationViewProvider
                                                    .setAddress(detail.locationAddress);

                                                if (locationViewProvider.getLocationView ==
                                                    LocationView.PICKUPSELECTED) {
                                                  _pickUpController.text = detail.locationAddress;

                                                  locationViewProvider.setPickUpLatLng(getLatLng);

                                                  locationViewProvider
                                                      .setPickUpAddress(mainAddress);
                                                } else {
                                                  _destinationController.text =
                                                      detail.locationAddress;

                                                  locationViewProvider
                                                      .setDestinationLatLng(getLatLng);

                                                  locationViewProvider.setDestinationPointAddress(
                                                      detail.locationAddress);
                                                }
                                              } else {
                                                print(getLatLng);
                                              }
                                            },
                                            title: Text(detail.locationAddress),
                                          ),
                                        ),
                                        Divider()
                                      ]
                                  ],
                                ),
                              ),
                            if (allLocations.length == 0)
                              Column(
                                children: <Widget>[
                                  // ListTile(
                                  //   contentPadding: const EdgeInsets.all(0),
                                  //   leading: CircleAvatar(
                                  //     backgroundColor: ThemeColors.primaryColor,
                                  //     child: Icon(
                                  //       Icons.home,
                                  //       color: Colors.white,
                                  //     ),
                                  //   ),
                                  //   title: Text(appLocalizations
                                  //       .translate("Add Home Address")),
                                  // ),
                                  ListTile(
                                    onTap: () {
                                      if (locationViewProvider.getLocationView ==
                                          LocationView.PICKUPSELECTED) {
                                        _firebaseUtils.addAddress(
                                            locationViewProvider.getPickUpPointAddress,
                                            locationViewProvider.getPickUpLatLng);
                                        Fluttertoast.showToast(msg: "Address Added");
                                      } else {
                                        _firebaseUtils.addAddress(
                                            locationViewProvider.getDestinationPointAddress,
                                            locationViewProvider.getDestinationLatLng);
                                        Fluttertoast.showToast(msg: "Address Added");
                                      }
                                    },
                                    contentPadding: const EdgeInsets.all(0),
                                    leading: CircleAvatar(
                                      backgroundColor: ThemeColors.primaryColor,
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(appLocalizations.translate("Add Address")),
                                  ),
                                  ListTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    leading: CircleAvatar(
                                      backgroundColor: ThemeColors.primaryColor,
                                      child: Icon(
                                        Icons.star,
                                        color: Colors.white,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        if (locationViewProvider.getLocationView ==
                                            LocationView.PICKUPSELECTED) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => SavedAddress(
                                                        isFromHome: true,
                                                        mainController: _pickUpController,
                                                      )));
                                        } else {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => SavedAddress(
                                                        isFromHome: true,
                                                        mainController: _destinationController,
                                                      )));
                                        }
                                      },
                                      icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                                    ),
                                    title: Text(appLocalizations.translate("Saved Places")),
                                  ),
                                  ListTile(
                                    onTap: () {
                                      if (locationViewProvider.getLocationView ==
                                          LocationView.PICKUPSELECTED) {
                                        Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) => DropLocationMap(
                                                  dropController: _pickUpController,
                                                  initLatLng: initLatLng,
                                                )));
                                      } else {
                                        Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) => DropLocationMap(
                                                  dropController: _destinationController,
                                                  initLatLng: initLatLng,
                                                )));
                                      }
                                    },
                                    contentPadding: const EdgeInsets.all(0),
                                    leading: CircleAvatar(
                                      backgroundColor: ThemeColors.primaryColor,
                                      child: Icon(
                                        Icons.map,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(appLocalizations.translate("Pick From Map")),
                                  ),
                                  ListTile(
                                    onTap: () => chooseCurentLocation(),
                                    contentPadding: const EdgeInsets.all(0),
                                    leading: CircleAvatar(
                                      backgroundColor: ThemeColors.primaryColor,
                                      child: Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title:
                                        Text(appLocalizations.translate("Choose Current Location")),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        Positioned(
                          bottom: 0.0,
                          right: 0.0,
                          child: FloatingActionButton(
                            child: Icon(Icons.arrow_forward_ios),
                            onPressed: () {
                              if (_locationForm.currentState.validate()) {
                                if (orderProvider.getStationView == StationView.LOCAL) {
                                  setState(() {
                                    _viewState = ViewState.LOCALSTATION;
                                  });
                                  _controller.close();
                                } else {
                                  setState(() {
                                    _viewState = ViewState.OUTSIDESTATION;
                                  });
                                  _controller.close();
                                }
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
            body: initLatLng == null
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor),
                    ),
                  )
                : Stack(
                    children: <Widget>[
                      GoogleMap(
                        buildingsEnabled: true,
                        polylines: _polyLines,
                        mapType: MapType.normal,
                        markers: _markers,
                        initialCameraPosition: CameraPosition(
                          zoom: zoomView,
                          target: initLatLng,
                        ),
                        onMapCreated: (controller) async {
                          _googleMapController = controller;
                          locationViewProvider.setPickUpLatLng(initLatLng);
                          locationViewProvider.setPickUpAddress(mainAddress);
                        },
                      ),
                      _buildMenu(),
                      _buildMyLocation(),
                      if (isShowMarker) pin(),
                      _buildNotification(),
                    ],
                  ),
          )),
    );
  }

  Widget _buildMyLocation() {
    return Positioned(
      bottom: (MediaQuery.of(context).size.height / 2 - 30),
      right: 10.0,
      child: FloatingActionButton(
        heroTag: "my_location_btn_home",
        onPressed: () => _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: initLatLng, zoom: 18, bearing: 180, tilt: 60))),
        child: Icon(Icons.my_location),
        backgroundColor: ThemeColors.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildMenu() {
    return Positioned(
      top: 35.0,
      left: 10.0,
      child: FloatingActionButton(
        heroTag: "home_menu",
        onPressed: () => _scaffoldKey.currentState.openDrawer(),
        child: Icon(Icons.menu),
        backgroundColor: ThemeColors.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget pin() {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'asset/images/marker-0.png',
              height: 45,
              width: 45,
            ),
            Container(
              decoration: ShapeDecoration(
                shadows: [
                  BoxShadow(
                    blurRadius: 4,
                    color: ThemeColors.primaryColor,
                  ),
                ],
                shape: CircleBorder(
                  side: BorderSide(
                    width: 4,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            SizedBox(height: 56),
          ],
        ),
      ),
    );
  }

  Future<bool> _showMyDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(appLocalizations.translate('Scheduled Ride')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(appLocalizations.translate('Schedule Ride For Future?')),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                orderProvider.setScheduled(false);
                Fluttertoast.showToast(msg: appLocalizations.translate("Current Order"));
                Navigator.of(context).pop();
                orderProvider.setScheduled(false);
                return false;
              },
            ),
            FlatButton(
              child: Text('yes'),
              onPressed: () async {
                orderProvider.setScheduled(true);
                Fluttertoast.showToast(msg: appLocalizations.translate("Scheduled Order"));

                Navigator.of(context).pop();
                DateTime selectedDate = await _showDateTimePicker();
                if (selectedDate != null) {
                  TimeOfDay selectedtime = await _showTimePicker();
                  if (selectedtime != null) {
                    orderProvider.setTimeOfOrderDelivery((selectedDate
                        .add(Duration(hours: selectedtime.hour, minutes: selectedtime.minute))));
                  } else {
                    orderProvider.setScheduled(false);
                    Fluttertoast.showToast(
                        msg: appLocalizations.translate("Invalid date, Current Order Selected "));
                  }
                }

                return true;
              },
            ),
          ],
        );
      },
    );
  }

  Future<DateTime> _showDateTimePicker() async {
    DateTime selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 30)));
    return selectedDate;
  }

  Future<TimeOfDay> _showTimePicker() async {
    TimeOfDay selectedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    return selectedTime;
  }

  Widget _buildNotification() {
    if (_viewState == ViewState.DEFAULT)
      return Positioned(
        top: 35,
        right: 10.0,
        child: Column(
          children: [
            FloatingActionButton(
              heroTag: "notification_home",
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              child: Icon(MaterialIcons.notifications),
              backgroundColor: ThemeColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            SizedBox(
              height: 10.0,
            ),
            FloatingActionButton(
              heroTag: "home_sch",
              onPressed: () async {
                await _showMyDialog();
              },
              child: Icon(Icons.watch_later),
              backgroundColor: ThemeColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ],
        ),
      );
    else {
      return Container();
    }
  }

  Widget _isSearchingOrNotFound(String result) {
    return ListTile(
      title: Text(result),
    );
  }

  Widget _renderCollapsed(OrderProvider orderProvider, LocationViewProvider locationViewProvider) {
    if (_viewState == ViewState.DEFAULT) {
      return SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 2 - 100,
              width: MediaQuery.of(context).size.width,
            ),
            Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isLocalSelected = true;

                            isOutSideSelected = false;

                            zoomView = 18;
                          });

                          orderProvider.setStationView(StationView.LOCAL);

                          _googleMapController
                              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                            target: initLatLng,
                            zoom: zoomView,
                          )));
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.all(5.0),
                          width: (MediaQuery.of(context).size.width / 2) - 20,
                          margin: const EdgeInsets.all(0.0),
                          decoration: BoxDecoration(
                              border: isLocalSelected
                                  ? Border.all(color: ThemeColors.primaryColor, width: 4.0)
                                  : null,
                              color: isLocalSelected ? Colors.blue[300] : Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10)]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                appLocalizations.translate("Local"),
                                style: TextStyle(fontSize: 15.0),
                              )
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isLocalSelected = false;

                            isOutSideSelected = true;

                            zoomView = 14;
                          });

                          orderProvider.setStationView(StationView.OUTSIDE);

                          _googleMapController
                              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                            target: initLatLng,
                            zoom: zoomView,
                          )));
                        },
                        child: Container(
                          height: 40,
                          width: (MediaQuery.of(context).size.width / 2) - 20,
                          margin: const EdgeInsets.all(8.0),
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              border: isOutSideSelected
                                  ? Border.all(color: ThemeColors.primaryColor, width: 4.0)
                                  : null,
                              color: isOutSideSelected ? Colors.blue[300] : Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10)]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                appLocalizations.translate("OutStation"),
                                style: TextStyle(fontSize: 14.0),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(children: <Widget>[
                    TextField(
                      onChanged: (val) {
                        locationViewProvider.setPickUpAddress(val);
                      },
                      onTap: () {
                        locationViewProvider.setLocationView(LocationView.PICKUPSELECTED);

                        _controller.open();
                      },
                      controller: _pickUpController,
                      focusNode: _pickFocusNode,
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                      readOnly: true,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                          prefixIcon: IconButton(
                            icon: Icon(
                              Icons.my_location,
                              color: Colors.green,
                            ),
                            onPressed: () {},
                            color: ThemeColors.primaryColor,
                          ),
                          hintText: appLocalizations.translate("Your Pickup Location"),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: ThemeColors.primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    TextField(
                      onChanged: (val) {
                        locationViewProvider.setDestinationPointAddress(val);
                      },
                      onTap: () {
                        locationViewProvider.setLocationView(LocationView.DESTINATIONSELECTED);

                        _controller.open();
                      },
                      controller: _destinationController,
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                      readOnly: true,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                          prefixIcon: IconButton(
                            icon: Icon(
                              Icons.my_location,
                              color: Colors.red,
                            ),
                            onPressed: () => {},
                            color: ThemeColors.primaryColor,
                          ),
                          hintText: appLocalizations.translate("Your Drop Location"),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: ThemeColors.primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                  ]),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 8.0,
              child: FlatButton(
                onPressed: () async {
                  if (_pickUpController.text.length > 5 && _destinationController.text.length > 5) {
                    List<LatLng> allLats = await getPolylinePoints(locationViewProvider);
                    setState(() {
                      isShowMarker = false;
                      _markers.add(Marker(
                        markerId: MarkerId('pickmarker'),
                        visible: true,
                        draggable: false,
                        position: locationViewProvider.getPickUpLatLng,
                        icon: pinLocationIcon,
                      ));
                      _markers.add(Marker(
                          markerId: MarkerId('dropmarker'),
                          visible: true,
                          draggable: false,
                          position: locationViewProvider.getDestinationLatLng,
                          icon: pinLocationIcon));
                      _polyLines.add(Polyline(
                          polylineId: PolylineId('main'),
                          color: ThemeColors.primaryColor,
                          width: 10,
                          endCap: Cap.buttCap,
                          startCap: Cap.roundCap,
                          jointType: JointType.round,
                          points: allLats,
                          visible: true));
                    });
                    _googleMapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
                      target: locationViewProvider.getPickUpLatLng,
                      zoom: 10,
                    )));

                    if (orderProvider.getStationView == StationView.LOCAL)
                      setState(() => _viewState = ViewState.LOCALSTATION);
                    else
                      setState(() => _viewState = ViewState.OUTSIDESTATION);
                  } else {
                    _controller.open();
                  }
                },
                child: Row(
                  children: <Widget>[
                    Text(
                      appLocalizations.translate("Next"),
                      style: TextStyle(fontSize: 15),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: ThemeColors.primaryColor,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    } else if (_viewState == ViewState.LOCALSTATION) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        primary: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Stack(
            overflow: Overflow.visible,
            children: [
              Container(
                height: (MediaQuery.of(context).size.height / 2) - 50,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                      child: Column(children: <Widget>[
                        Container(
                          height: 70,
                          padding: EdgeInsets.only(top: 10.0, right: 10, left: 5),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Octicons.primitive_dot, color: Colors.green),
                                  SizedBox(width: 10.0),
                                  Flexible(
                                    child: Text(
                                      _pickUpController.text,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Octicons.primitive_dot, color: Colors.red),
                                  SizedBox(width: 10.0),
                                  Flexible(
                                    child: Text(
                                      _destinationController.text,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 30,
                          child: DropdownButton<String>(
                            hint: Text(appLocalizations.translate("Select Truck Category")),
                            isExpanded: true,
                            onChanged: (String value) {
                              print(value);
                              orderProvider.setTruckCategoryLocal(value);
                            },
                            elevation: 5,
                            value: orderProvider.getSelectedTruckLocal,
                            items: orderProvider.getTruckCatLocal.map((String truck) {
                              return DropdownMenuItem(
                                value: truck,
                                child: Text(truck),
                              );
                            }).toList(),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0.0,
                left: -15.0,
                child: FlatButton(
                  // heroTag: "go_back_default",
                  onPressed: () => setState(() {
                    _markers.removeWhere((element) => element.markerId == MarkerId('pickmarker'));
                    _markers.removeWhere((element) => element.markerId == MarkerId('dropmarker'));
                    _polyLines.removeWhere((element) => element.polylineId == PolylineId('main'));
                    _viewState = ViewState.DEFAULT;
                    isShowMarker = true;
                  }),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.arrow_back_ios),
                      Text(
                        appLocalizations.translate("Back"),
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0.0,
                right: -15.0,
                child: FlatButton(
                  onPressed: () {
                    if (orderProvider.getSelectedTruckLocal != null) {
                      setState(() => _viewState = ViewState.TRUCKVIEW);
                    } else {
                      Fluttertoast.showToast(msg: "Select a truck category");
                    }
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        appLocalizations.translate("Next"),
                        style: TextStyle(fontSize: 15),
                      ),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } else if (_viewState == ViewState.OUTSIDESTATION) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        primary: true,
        child: Stack(
          children: [
            Container(
              height: (MediaQuery.of(context).size.height / 2) - 40,
              child: Column(children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                    child: Column(children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          height: 70,
                          padding: EdgeInsets.only(top: 10.0, right: 10, left: 10),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Octicons.primitive_dot, color: Colors.green),
                                  SizedBox(width: 10.0),
                                  Flexible(
                                    child: Text(
                                      _pickUpController.text,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Octicons.primitive_dot, color: Colors.red),
                                  SizedBox(width: 10.0),
                                  Flexible(
                                    child: Text(
                                      _destinationController.text,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 30,
                        child: DropdownButton<String>(
                          hint: Text(appLocalizations.translate("Select Truck Category")),
                          isExpanded: true,
                          onChanged: (String value) {
                            setState(() {
                              orderProvider.setTruckCategory(value);
                            });
                          },
                          elevation: 5,
                          value: orderProvider.getSelectedTruck,
                          items: orderProvider.getTruckCategory.map((String truck) {
                            return DropdownMenuItem(
                              value: truck,
                              child: Text(truck),
                            );
                          }).toList(),
                        ),
                      ),
                    ])),
                SizedBox(
                  height: 10,
                ),
              ]),
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              child: FlatButton(
                // heroTag: "go_back_default",
                onPressed: () => setState(() {
                  _markers.removeWhere((element) => element.markerId == MarkerId('pickmarker'));
                  _markers.removeWhere((element) => element.markerId == MarkerId('dropmarker'));
                  _polyLines.removeWhere((element) => element.polylineId == PolylineId('main'));
                  _viewState = ViewState.DEFAULT;
                  isShowMarker = true;
                }),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.arrow_back_ios),
                    Text(
                      appLocalizations.translate("Back"),
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              child: FlatButton(
                onPressed: () {
                  if (orderProvider.getSelectedTruck != null) {
                    setState(() => _viewState = ViewState.TRUCKVIEW);
                  } else {
                    Fluttertoast.showToast(msg: "Select a truck category");
                  }
                },
                child: Row(
                  children: <Widget>[
                    Text(
                      appLocalizations.translate("Next"),
                      style: TextStyle(fontSize: 15),
                    ),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_viewState == ViewState.TRUCKVIEW) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        primary: true,
        child: Stack(children: [
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height / 2 - 50,
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('trucks')
                    .where("category",
                        isEqualTo: orderProvider.getStationView == StationView.LOCAL
                            ? orderProvider.getSelectedTruckLocal
                            : orderProvider.getSelectedTruck)
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor),
                    ));
                  } else {
                    if (snapshot.data.documents.length == 0) {
                      return Center(
                          child: Text(appLocalizations.translate("No Trucks of this category !")));
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height / 3 - 40,
                          child: Scrollbar(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                primary: true,
                                physics: AlwaysScrollableScrollPhysics(),
                                children: snapshot.data.documents.map((DocumentSnapshot truck) {
                                  return InkWell(
                                    onTap: () {
                                      print(truck.data['priceFactor']);
                                      setState(() => price = truck.data['priceFactor']);
                                      orderProvider.setTruckName(truck.data['name']);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          width: 170,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: orderProvider.getTruckName ==
                                                          truck.data['name']
                                                      ? ThemeColors.primaryColor
                                                      : Colors.white,
                                                  style: BorderStyle.solid,
                                                  width: 3),
                                              boxShadow: [
                                                BoxShadow(
                                                    blurRadius: 10,
                                                    color: Colors.grey.shade100,
                                                    spreadRadius: 4.0)
                                              ]),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 0.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                ' ${truck.data['name']} (${truck.data['capacity']})',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 14.0),
                                              ),
                                              CachedNetworkImage(
                                                imageBuilder: (context, provider) {
                                                  return Container(
                                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                                      child: Image(
                                                          image: provider,
                                                          height: 100,
                                                          width: 100));
                                                },
                                                imageUrl: truck.data['image'],
                                                placeholder: (context, str) {
                                                  return Container(
                                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                                    height: 100,
                                                    width: 100,
                                                    child: Image.asset('asset/images/newlogo.png'),
                                                  );
                                                },
                                              ),
                                              Text(
                                                "20 ${appLocalizations.translate("min away")}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 14.0),
                                              ),
                                              Text(
                                                " ${appLocalizations.translate("Size")} : ${truck.data['dimension']}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 14.0),
                                              ),
                                            ],
                                          )),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            child: FlatButton(
              onPressed: () {
                if (orderProvider.getStationView == StationView.LOCAL)
                  setState(() => _viewState = ViewState.LOCALSTATION);
                else {
                  setState(() => _viewState = ViewState.OUTSIDESTATION);
                }
              },
              child: Row(
                children: <Widget>[
                  Icon(Icons.arrow_back_ios),
                  Text(
                    appLocalizations.translate("Back"),
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            child: FlatButton(
              onPressed: () {
                if (price != null) {
                  setState(() => _viewState = ViewState.ORDERVIEW);
                } else {
                  Fluttertoast.showToast(msg: "Please select a truck !");
                }
              },
              child: Row(
                children: <Widget>[
                  Text(
                    appLocalizations.translate("Next"),
                    style: TextStyle(fontSize: 15),
                  ),
                  Icon(Icons.arrow_forward_ios),
                ],
              ),
            ),
          )
        ]),
      );
    } else if (_viewState == ViewState.ORDERVIEW) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        primary: true,
        child: Stack(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height / 2 - 50,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0.0),
                              child: TextFormField(
                                validator: (val) {
                                  if (val.length < 3) {
                                    return appLocalizations.translate("Invalid Name");
                                  }
                                },
                                onSaved: (val) {
                                  orderProvider.setReceiverName(val);
                                },
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                    hintText: "Receiver Name",
                                    prefixIcon: Icon(Icons.person_outline),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0))),
                              ),
                            ),
                            SizedBox(height: 15),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0.0),
                              child: TextFormField(
                                validator: (val) {
                                  if (val.length != 10) {
                                    return appLocalizations.translate("Invalid Phone Number");
                                  }
                                },
                                onSaved: (val) {
                                  orderProvider.setReceiverPhone(val);
                                },
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                decoration: InputDecoration(
                                    hintText: appLocalizations.translate("Receiver Phone"),
                                    prefixIcon: Icon(Icons.dialpad),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          setState(() => _viewState = ViewState.LOCALSTATION);
                        },
                        child: Row(children: <Widget>[
                          Icon(Icons.arrow_back_ios),
                          Text(
                            appLocalizations.translate("Back"),
                            style: TextStyle(fontSize: 15),
                          ),
                        ]),
                      ),
                      GestureDetector(
                          onTap: () async {
                            if (formKey.currentState.validate()) {
                              formKey.currentState.save();
                              FocusScope.of(context).unfocus();
                              bool isNight = await _firebaseUtils.getisFareHighHours();
                              orderProvider.setOrderPrice(locationViewProvider, price, isNight,
                                  orderProvider.getNightChargePercent);

                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => OrderDetailsScreen()));
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 45,
                            width: 180,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  ThemeColors.primaryColor,
                                  Color(0xff8E2DE2),
                                  ThemeColors.primaryColor,
                                ]),
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: ThemeColors.primaryColor.withOpacity(0.2),
                                    blurRadius: 10.0,
                                    spreadRadius: 2.0,
                                  )
                                ]),
                            child: Text(
                              appLocalizations.translate("Confirm"),
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
