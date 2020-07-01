import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps/flutter_google_maps.dart';
import 'package:flutter_google_maps/flutter_google_maps.dart' as map;
import 'package:flutter_icons/flutter_icons.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:riderappweb/constants/apikeys.dart';
import 'package:riderappweb/constants/themecolors.dart';
import 'package:riderappweb/controllers/firebase_utils.dart';
import 'package:riderappweb/enums/devices_view.dart';
import 'package:riderappweb/enums/location_view.dart';
import 'package:riderappweb/enums/station_view.dart';
import 'package:riderappweb/enums/viewstate.dart';
import 'package:riderappweb/model/location_details.dart';
import 'package:riderappweb/model/location_result.dart';
import 'package:riderappweb/providers/location_provider.dart';
import 'package:riderappweb/providers/order_provider.dart';
import 'package:riderappweb/providers/user_provider.dart';
import 'package:riderappweb/utils/uuid.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GeoCoord initPos;
  String _pickUpText = "";
  String _dropText = "";
  final double ZOOM_VIEW = 18;
  String currentAddress;
  TextEditingController _locationController = TextEditingController();
  TextEditingController _pickUpController = TextEditingController();
  TextEditingController _dropController = TextEditingController();
  bool isArrowClicked = false;
  DeviceView deviceView;
  GlobalKey<FormState> _receiverFormKey = GlobalKey<FormState>();
  Timer _debounce;
  int price;
  bool hasSearchTerm = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String sessionToken = Uuid().generateV4();
  List<LocationDetails> allLocations = [];
  LocationResult locationResult;
  String searchVal;
  bool isSearchingCurrently = false;
  GlobalKey<FormState> _locationFormKey = GlobalKey<FormState>();
  GlobalKey<GoogleMapStateBase> _googleMapKey = GlobalKey<GoogleMapStateBase>();
  ViewState _viewState = ViewState.DEFAULT;
  TextEditingController _receiverName = TextEditingController();
  TextEditingController _receiverPhone = TextEditingController();
  FirebaseUtils _firebaseUtils = FirebaseUtils();

  getCurrentLocation() async {
    LocationData locData = await Location.instance.getLocation();
    setState(() {
      initPos = GeoCoord(locData.latitude, locData.longitude);
    });
    getLocationAddress();
  }

  getLocationAddress() async {
    Response res = await get(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${initPos.latitude},${initPos.longitude}&key=${APIKeys.googleMapsAPI}');
    var data = jsonDecode(res.body);
    currentAddress = data['results'][0]['formatted_address'];
    _locationController.text = currentAddress;
    _pickUpController.text = currentAddress;
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _pickUpController.addListener(_onSearchPickUp);
    _dropController.addListener(_onSearchDrop);
  }

  _onSearchPickUp() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchPlace(_pickUpController.text);
    });
  }

  _onSearchDrop() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchPlace(_dropController.text);
    });
  }

  void searchPlace(String place) {
    setState(() => hasSearchTerm = place.length > 0);
    setState(() {
      searchVal = "Searching...";
    });

    if (place.length < 1) return;

    setState(() {
      isSearchingCurrently = true;
    });

    autoCompleteSearch(place);
  }

  void autoCompleteSearch(String place) async {
    place = place.replaceAll(" ", "+");
    var endpoint = "http://localhost:4000/autocomplete?place=$place";

    // if (locationResult != null) {
    //   endpoint += "&location=${locationResult.latLng.latitude}," +
    //       "${locationResult.latLng.longitude}";
    // }
    get(endpoint, headers: {"Accept": "application/json"}).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var predictions = data['predictions'];
        allLocations.clear();
        if (predictions.isEmpty) {
          setState(() {
            searchVal = "No result found";
            isSearchingCurrently = false;
          });
        } else {
          for (dynamic single in predictions) {
            LocationDetails detail = LocationDetails(
                locationAddress: single['description'],
                locationID: single['place_id']);
            allLocations.add(detail);
          }
          setState(() => isSearchingCurrently = false);
        }
      }
    }).catchError((e) => [print(e)]);
  }

  addDirection(GeoCoord latLng, GeoCoord dest) {
    _googleMapKey.currentState.addDirection(latLng, dest);
  }

  Future<GeoCoord> decodeAndSelectPlace(
      String placeId, LocationViewProvider locationViewProvider) async {
    String endpoint = "http://localhost:4000/decode?placeID=$placeId";

    Response response = await get(endpoint);
    Map<String, dynamic> location =
        jsonDecode(response.body)['result']['geometry']['location'];
    GeoCoord latLng = GeoCoord(location['lat'], location['lng']);
    Map<String, dynamic> northBound = jsonDecode(response.body)['result']
        ['geometry']['viewport']['northeast'];
    Map<String, dynamic> southBound = jsonDecode(response.body)['result']
        ['geometry']['viewport']['southwest'];
    locationViewProvider
        .setNorthestBound(GeoCoord(northBound['lat'], northBound['lng']));
    locationViewProvider
        .setSouthestBound(GeoCoord(southBound['lat'], southBound['lng']));
    return latLng;
  }

  @override
  Widget build(BuildContext context) {
    checkDevice() {
      if (MediaQuery.of(context).size.width <= 700) {
        setState(() {
          deviceView = DeviceView.MOBILE;
        });
      } else {
        isArrowClicked = true;
        deviceView = DeviceView.WEB;
      }
    }

    LocationViewProvider locationViewProvider =
        Provider.of<LocationViewProvider>(context);
    OrderProvider orderProvider = Provider.of<OrderProvider>(context);
    UserPreferences userPreferences = Provider.of<UserPreferences>(context);

    checkDevice();

    return Scaffold(
      body: initPos == null
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(ThemeColors.darkblueColor),
              ),
            )
          : Stack(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width),
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width <= 600
                      ? MediaQuery.of(context).size.width
                      : (MediaQuery.of(context).size.width -
                          (MediaQuery.of(context).size.width / 3 - 130)),
                  child: GoogleMap(
                    webPreferences: WebMapPreferences(
                      dragGestures: true,
                      mapTypeControl: true,
                    ),
                    key: _googleMapKey,
                    initialPosition: initPos,
                    initialZoom: ZOOM_VIEW,
                    interactive: true,
                    mapType: map.MapType.terrain,
                    mobilePreferences: MobileMapPreferences(
                        buildingsEnabled: true,
                        trafficEnabled: true,
                        myLocationEnabled: true,
                        scrollGesturesEnabled: true,
                        tiltGesturesEnabled: true),
                  ),
                ),
                if (isArrowClicked)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: AnimatedContainer(
                      curve: Curves.easeIn,
                      duration: Duration(milliseconds: 500),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width <= 600
                          ? MediaQuery.of(context).size.width
                          : MediaQuery.of(context).size.width / 3 - 130,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade100,
                                blurRadius: 30.0,
                                spreadRadius: 1)
                          ]),
                      child: _buildPanel(
                          locationViewProvider, orderProvider, userPreferences),
                    ),
                  ),
                if (deviceView == DeviceView.MOBILE)
                  Positioned(
                    bottom: 20.0,
                    right: 20.0,
                    child: FloatingActionButton(
                      foregroundColor: Colors.white,
                      backgroundColor: ThemeColors.primaryColor,
                      child: Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        if (isArrowClicked) {
                          setState(() {
                            isArrowClicked = false;
                          });
                        } else {
                          setState(() {
                            isArrowClicked = true;
                          });
                        }
                      },
                    ),
                  ),
                if (!isArrowClicked)
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 500),
                    top: 60,
                    left: 10,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade100,
                                blurRadius: 10.0,
                                spreadRadius: 8.0)
                          ]),
                      width: MediaQuery.of(context).size.width <= 600
                          ? MediaQuery.of(context).size.width - 40
                          : MediaQuery.of(context).size.width / 3,
                      child: TextField(
                        readOnly: true,
                        controller: _locationController,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.my_location),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Your Current Location",
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10.0))),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildPanel(LocationViewProvider locationViewProvider,
      OrderProvider orderProvider, UserPreferences userPreferences) {
    if (_viewState == ViewState.DEFAULT) {
      return _buildViewDefault(locationViewProvider, orderProvider);
    } else if (_viewState == ViewState.LOCALSTATION) {
      return _buildViewLocal(
          locationViewProvider, orderProvider, userPreferences);
    } else if (_viewState == ViewState.OUTSIDESTATION) {
      return _buildViewOutside(
          locationViewProvider, orderProvider, userPreferences);
    }
  }

  Widget _buildViewDefault(
      LocationViewProvider locationViewProvider, OrderProvider orderProvider) {
    return AnimatedPadding(
      duration: Duration(milliseconds: 500),
      padding:
          EdgeInsets.only(top: MediaQuery.of(context).size.height / 6 - 80),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      if (_locationFormKey.currentState.validate()) {
                        setState(() {
                          if (orderProvider.getStationView == StationView.LOCAL)
                            setState(() => _viewState = ViewState.LOCALSTATION);
                          if (orderProvider.getStationView ==
                              StationView.OUTSIDESTATION)
                            setState(
                                () => _viewState = ViewState.OUTSIDESTATION);
                        });
                      }
                    },
                    child: Row(
                      children: [Text("NEXT"), Icon(Icons.arrow_forward_ios)],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      orderProvider.setStationView(StationView.LOCAL);
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.all(5.0),
                      width: deviceView == DeviceView.WEB
                          ? (MediaQuery.of(context).size.width / 9) - 20
                          : MediaQuery.of(context).size.width / 2 - 40,
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border:
                              orderProvider.getStationView == StationView.LOCAL
                                  ? Border.all(
                                      color: ThemeColors.primaryColor,
                                      width: 4.0)
                                  : null,
                          color:
                              orderProvider.getStationView == StationView.LOCAL
                                  ? Colors.blue[300]
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade100, blurRadius: 10)
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Local",
                            style: TextStyle(fontSize: 15.0),
                          )
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      orderProvider.setStationView(StationView.OUTSIDESTATION);
                    },
                    child: Container(
                      height: 50,
                      width: deviceView == DeviceView.WEB
                          ? (MediaQuery.of(context).size.width / 9) - 20
                          : MediaQuery.of(context).size.width / 2 - 40,
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                          border: orderProvider.getStationView ==
                                  StationView.OUTSIDESTATION
                              ? Border.all(
                                  color: ThemeColors.primaryColor, width: 4.0)
                              : null,
                          color: orderProvider.getStationView ==
                                  StationView.OUTSIDESTATION
                              ? Colors.blue[300]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade100, blurRadius: 10)
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "OutStation",
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: <Widget>[
                      Icon(Octicons.primitive_dot,
                          color: ThemeColors.primaryColor),
                      Text(
                          locationViewProvider.getLocationView ==
                                  LocationView.PICKUP
                              ? "Pick Up Location"
                              : "Drop Location",
                          style: TextStyle(
                              fontSize: 16.0,
                              color: ThemeColors.primaryColor,
                              fontWeight: FontWeight.bold))
                    ],
                  )),
            ),
            Form(
              key: _locationFormKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    TextFormField(
                      validator: (val) {
                        if (val.length <= 5) {
                          return "Enter a valid location !";
                        }
                      },
                      onTap: () {
                        locationViewProvider
                            .setLocationView(LocationView.PICKUP);
                      },
                      controller: _pickUpController,
                      autofocus: true,
                      onChanged: (val) {
                        setState(() {
                          _pickUpText = val;
                        });
                      },
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10.0),
                          hintText: "Your Current Location",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                    SizedBox(height: 10.0),
                    TextFormField(
                      validator: (val) {
                        if (val.length <= 5) {
                          return "Enter a valid location !";
                        }
                      },
                      onTap: () {
                        locationViewProvider.setLocationView(LocationView.DROP);
                      },
                      onChanged: (val) {
                        setState(() {
                          _dropText = val;
                        });
                      },
                      controller: _dropController,
                      autofocus: true,
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          hintText: "Enter Drop Location",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _buildAutoCompleteList(locationViewProvider),
                    _buildOtherItems(locationViewProvider),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildViewLocal(LocationViewProvider locationViewProvider,
      OrderProvider orderProvider, UserPreferences userPreferences) {
    return AnimatedPadding(
      duration: Duration(milliseconds: 500),
      padding:
          EdgeInsets.only(top: MediaQuery.of(context).size.height / 6 - 100),
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              setState(() => _viewState = ViewState.DEFAULT);
                            });
                          },
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back_ios),
                              Text("BACK"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 0.0),
                      child: Column(children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            height: 70,
                            padding:
                                EdgeInsets.only(top: 10.0, right: 10, left: 10),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Octicons.primitive_dot,
                                        color: Colors.green),
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
                                    Icon(Octicons.primitive_dot,
                                        color: Colors.red),
                                    SizedBox(width: 10.0),
                                    Flexible(
                                      child: Text(
                                        _dropController.text,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ])),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropdownButton<String>(
                        hint: Text("Select Truck Category"),
                        onChanged: (String value) {
                          print(value);
                          orderProvider.setTruckCategoryLocal(value);
                        },
                        elevation: 5,
                        value: orderProvider.getSelectedTruckLocal,
                        items:
                            orderProvider.getTruckCatLocal.map((String truck) {
                          return DropdownMenuItem(
                            value: truck,
                            child: Text(truck),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  orderProvider.getSelectedTruckLocal != null
                      ? Container(
                          height: MediaQuery.of(context).size.height / 2 - 60,
                          child: StreamBuilder(
                              stream: Firestore.instance
                                  .collection('trucks')
                                  .where("category",
                                      isEqualTo:
                                          orderProvider.getSelectedTruckLocal)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        ThemeColors.primaryColor),
                                  ));
                                } else {
                                  if (snapshot.data.documents.length == 0) {
                                    return Center(
                                        child: Text(
                                            "No Trucks of this category !"));
                                  }
                                  return Column(children: <Widget>[
                                    Container(
                                      height: 210,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        primary: true,
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        children: snapshot.data.documents
                                            .map((DocumentSnapshot truck) {
                                          return InkWell(
                                            onTap: () {
                                              setState(() => price =
                                                  truck.data['priceFactor']);
                                              orderProvider.setTruckName(
                                                  truck.data['name']);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Container(
                                                  width: 200,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      border: Border.all(
                                                          color: orderProvider
                                                                      .getTruckName ==
                                                                  truck.data['name']
                                                              ? ThemeColors.primaryColor
                                                              : Colors.white,
                                                          style: BorderStyle.solid,
                                                          width: 3),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            blurRadius: 10,
                                                            color: Colors
                                                                .grey.shade100,
                                                            spreadRadius: 4.0)
                                                      ]),
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 0.0),
                                                  child: Container(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text(
                                                          ' ${truck.data['name']} ${truck.data['capacity']}',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14.0),
                                                        ),
                                                        CachedNetworkImage(
                                                          imageBuilder:
                                                              (context,
                                                                  provider) {
                                                            return Container(
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            10),
                                                                height: 80,
                                                                width: 80,
                                                                child: Image(
                                                                    image:
                                                                        provider,
                                                                    height: 100,
                                                                    width:
                                                                        100));
                                                          },
                                                          imageUrl: truck
                                                              .data['image'],
                                                          placeholder:
                                                              (context, str) {
                                                            return Container(
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10),
                                                              height: 100,
                                                              width: 100,
                                                              child: Image.asset(
                                                                  'images/newlogo.png'),
                                                            );
                                                          },
                                                        ),
                                                        Text(
                                                          "20 min away",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14.0),
                                                        ),
                                                        Text(
                                                          "  Size : ${truck.data['dimension']}",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14.0),
                                                        ),
                                                        Text(
                                                          "Estimated Fare :  ₹ ${110.toString()}",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18.0),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  ]);
                                }
                              }))
                      : Container(),
                  Form(
                    key: _receiverFormKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          TextFormField(
                            validator: (val) {
                              if (val.length <= 3) {
                                return "Enter Valid Name !";
                              }
                            },
                            onSaved: (val) {
                              orderProvider.setReceiverName(val);
                            },
                            controller: _receiverName,
                            autofocus: true,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 10.0),
                                hintText: "Receiver Name",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                          ),
                          SizedBox(height: 5.0),
                          TextFormField(
                            validator: (val) {
                              if (val.length != 10) {
                                return "Enter Valid Phone";
                              }
                            },
                            onSaved: (val) {
                              orderProvider.setReceiverPhone(val);
                            },
                            controller: _receiverPhone,
                            autofocus: true,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                hintText: "Enter Receiver Phone",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    onChanged: (val) {
                      orderProvider.setPaymentMethod(val);
                    },
                    hint: Text("Payment"),
                    value: orderProvider.getSelectedPaymentMethod,
                    items: ["Paytm", "Cash"]
                        .map((e) => DropdownMenuItem(
                              child: Text(e),
                              value: e,
                            ))
                        .toList(),
                  ),
                  InkWell(
                    onTap: () {
                      if (_receiverFormKey.currentState.validate()) {
                        _receiverFormKey.currentState.save();
                        _firebaseUtils.startOrder(locationViewProvider,
                            orderProvider, userPreferences, context);
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 35,
                      width: 140,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            ThemeColors.primaryColor,
                            Color(0xff8E2DE2)
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
                        "Checkout",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildViewOutside(LocationViewProvider locationViewProvider,
      OrderProvider orderProvider, UserPreferences userPreferences) {
    return AnimatedPadding(
      duration: Duration(milliseconds: 500),
      padding:
          EdgeInsets.only(top: MediaQuery.of(context).size.height / 6 - 80),
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              setState(() => _viewState = ViewState.DEFAULT);
                            });
                          },
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back_ios),
                              Text("BACK"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 0.0),
                      child: Column(children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            height: 70,
                            padding:
                                EdgeInsets.only(top: 10.0, right: 10, left: 10),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Octicons.primitive_dot,
                                        color: Colors.green),
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
                                    Icon(Octicons.primitive_dot,
                                        color: Colors.red),
                                    SizedBox(width: 10.0),
                                    Flexible(
                                      child: Text(
                                        _dropController.text,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ])),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropdownButton<String>(
                        hint: Text("Select Truck Category"),
                        onChanged: (String value) {
                          print(value);
                          orderProvider.setTruckCategory(value);
                        },
                        elevation: 5,
                        value: orderProvider.getSelectedTruck,
                        items:
                            orderProvider.getTruckCategory.map((String truck) {
                          return DropdownMenuItem(
                            value: truck,
                            child: Text(truck),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  orderProvider.getSelectedTruckLocal != null
                      ? Container(
                          height: MediaQuery.of(context).size.height / 2 - 50,
                          child: StreamBuilder(
                              stream: Firestore.instance
                                  .collection('trucks')
                                  .where("category",
                                      isEqualTo:
                                          orderProvider.getSelectedTruck)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        ThemeColors.primaryColor),
                                  ));
                                } else {
                                  if (snapshot.data.documents.length == 0) {
                                    return Center(
                                        child: Text(
                                            "No Trucks of this category !"));
                                  }
                                  return Column(children: <Widget>[
                                    Container(
                                      height: 220,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        primary: true,
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        children: snapshot.data.documents
                                            .map((DocumentSnapshot truck) {
                                          return InkWell(
                                            onTap: () {
                                              setState(() => price =
                                                  truck.data['priceFactor']);
                                              orderProvider.setTruckName(
                                                  truck.data['name']);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                  width: 200,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      border: Border.all(
                                                          color: orderProvider
                                                                      .getTruckName ==
                                                                  truck.data['name']
                                                              ? ThemeColors.primaryColor
                                                              : Colors.white,
                                                          style: BorderStyle.solid,
                                                          width: 3),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            blurRadius: 10,
                                                            color: Colors
                                                                .grey.shade100,
                                                            spreadRadius: 4.0)
                                                      ]),
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 0.0),
                                                  child: Container(
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text(
                                                          ' ${truck.data['name']} ${truck.data['capacity']}',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14.0),
                                                        ),
                                                        CachedNetworkImage(
                                                          imageBuilder:
                                                              (context,
                                                                  provider) {
                                                            return Container(
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            10),
                                                                height: 80,
                                                                width: 80,
                                                                child: Image(
                                                                    image:
                                                                        provider,
                                                                    height: 100,
                                                                    width:
                                                                        100));
                                                          },
                                                          imageUrl: truck
                                                              .data['image'],
                                                          placeholder:
                                                              (context, str) {
                                                            return Container(
                                                              margin: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10),
                                                              height: 100,
                                                              width: 100,
                                                              child: Image.asset(
                                                                  'images/newlogo.png'),
                                                            );
                                                          },
                                                        ),
                                                        Text(
                                                          "20 min away",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14.0),
                                                        ),
                                                        Text(
                                                          "  Size : ${truck.data['dimension']}",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14.0),
                                                        ),
                                                        Text(
                                                          "Estimated Fare :  ₹ ${110.toString()}",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18.0),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  ]);
                                }
                              }))
                      : Container(),
                  Form(
                    key: _receiverFormKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          TextFormField(
                            validator: (val) {
                              if (val.length <= 3) {
                                return "Enter Valid Name !";
                              }
                            },
                            onSaved: (val) {
                              orderProvider.setReceiverName(val);
                            },
                            controller: _receiverName,
                            autofocus: true,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 10.0),
                                hintText: "Receiver Name",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                          ),
                          SizedBox(height: 10.0),
                          TextFormField(
                            validator: (val) {
                              if (val.length != 10) {
                                return "Enter Valid Phone";
                              }
                            },
                            onSaved: (val) {
                              orderProvider.setReceiverPhone(val);
                            },
                            controller: _receiverPhone,
                            autofocus: true,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                hintText: "Enter Receiver Phone",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 25,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    onChanged: (val) {
                      orderProvider.setPaymentMethod(val);
                    },
                    value: orderProvider.getSelectedPaymentMethod,
                    hint: Text("Payment Method"),
                    items: ["Paytm", "Cash"]
                        .map((e) => DropdownMenuItem(
                              child: Text(e),
                              value: e,
                            ))
                        .toList(),
                  ),
                  InkWell(
                    onTap: () {
                      if (_receiverFormKey.currentState.validate()) {
                        _receiverFormKey.currentState.save();
                        _firebaseUtils.startOrder(locationViewProvider,
                            orderProvider, userPreferences, context);
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 35,
                      width: 140,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            ThemeColors.primaryColor,
                            Color(0xff8E2DE2)
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
                        "Checkout",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildAutoCompleteList(LocationViewProvider locationViewProvider) {
    if (_dropText.isNotEmpty || _pickUpText.isNotEmpty) {
      if (isSearchingCurrently) {
        return ListTile(
          title: Text("Searching..."),
        );
      } else {
        if (searchVal == "No result found") {
          return ListTile(
            title: Text(searchVal),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              LocationDetails detail = allLocations[index];
              return ListTile(
                onTap: () async {
                  GeoCoord geoCoord = await decodeAndSelectPlace(
                      detail.locationID, locationViewProvider);
                  _googleMapKey.currentState.addMarker(Marker(geoCoord));
                  _googleMapKey.currentState.moveCamera(
                      GeoCoordBounds(
                          northeast: locationViewProvider.getNorthestBound,
                          southwest: locationViewProvider.getSouthestBound),
                      animated: true);
                  if (locationViewProvider.getLocationView ==
                      LocationView.PICKUP) {
                    _pickUpController.text = detail.locationAddress;
                    locationViewProvider
                        .setPickUpAddress(detail.locationAddress);
                    locationViewProvider.setPickUpLatLng(geoCoord);
                  } else {
                    _dropController.text = detail.locationAddress;
                    locationViewProvider
                        .setDestinationPointAddress(detail.locationAddress);
                    locationViewProvider.setDestinationLatLng(geoCoord);
                    if (locationViewProvider.getPickUpPointAddress.isNotEmpty) {
                      _googleMapKey.currentState
                          .removeMarker(locationViewProvider.getPickUpLatLng);
                      _googleMapKey.currentState.removeMarker(
                          locationViewProvider.getDestinationLatLng);
                      addDirection(locationViewProvider.getPickUpLatLng,
                          locationViewProvider.getDestinationLatLng);
                      setState(() {
                        isArrowClicked = false;
                      });
                    }
                  }
                },
                title: Text(detail.locationAddress),
              );
            },
            itemCount: allLocations.length,
          );
        }
      }
    } else {
      return Container();
    }
  }

  Widget _buildOtherItems(LocationViewProvider locationViewProvider) {
    if (_dropText.isEmpty || _pickUpText.isEmpty) {
      return Column(
        children: <Widget>[
          ListTile(
            onTap: () {
              locationViewProvider.setPickUpLatLng(initPos);
              locationViewProvider.setAddress(_locationController.text);
              setState(() {
                isArrowClicked = false;
              });
              _googleMapKey.currentState.addMarker(Marker(initPos));
            },
            contentPadding: const EdgeInsets.all(0),
            leading: CircleAvatar(
              backgroundColor: ThemeColors.primaryColor,
              child: Icon(
                Icons.location_on,
                color: Colors.white,
              ),
            ),
            title: Text("Choose Current Location"),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
