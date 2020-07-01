import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission/permission.dart';
import 'package:rideapp/constants/apikeys.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:rideapp/controllers/static_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackOrderScreen extends StatefulWidget {
  final String orderID;

  final Map<String, dynamic> dataMap;
  final LatLng pickUp;
  final LatLng destPoint;
  final LatLng driverPoint;
  final String driverPhone;

  const TrackOrderScreen(
      {Key key,
      this.orderID,
      this.dataMap,
      this.pickUp,
      this.destPoint,
      this.driverPoint, this.driverPhone})
      : super(key: key);
  @override
  _TrackOrderScreenState createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  GoogleMapController _googleMapController;
  Set<Polyline> _polylines = {};
  List<LatLng> pickUpToDrop;
  List<LatLng> driverToPickUp;
  LatLng riderPosition;
  StaticUtils _utils = StaticUtils();
  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor dropLocationIcon;
  String driverImage;
  final Set<Marker> _markers = {};
  GoogleMapPolyline _googleMapPolyline =
      GoogleMapPolyline(apiKey: APIKeys.googleMapsAPI);

  void getPolyLinePoints() async {
    var permissions =
        await Permission.getPermissionsStatus([PermissionName.Location]);
    if (permissions[0].permissionStatus == PermissionStatus.notAgain) {
      var askpermissions =
          await Permission.requestPermissions([PermissionName.Location]);
    } else {
      List<LatLng> newLats =
          await _googleMapPolyline.getCoordinatesWithLocation(
              origin: widget.pickUp,
              destination: widget.destPoint,
              mode: RouteMode.driving);
      setState(() {
        pickUpToDrop = newLats;
      });
    }
  }

  void getDriverProfile() async {
    DocumentSnapshot driverData = await Firestore.instance.collection('vendor').document(widget.driverPhone).get();
    if(driverData.exists) {
      setState(() {
        driverImage = driverData['profile'];
      });
    }
  }

  void getDriverPolyLinePoints() async {
    var permissions =
        await Permission.getPermissionsStatus([PermissionName.Location]);
    if (permissions[0].permissionStatus == PermissionStatus.notAgain) {
      var askpermissions =
          await Permission.requestPermissions([PermissionName.Location]);
    } else {
      List<LatLng> newLats =
          await _googleMapPolyline.getCoordinatesWithLocation(
              origin: widget.driverPoint,
              destination: widget.pickUp,
              mode: RouteMode.driving);
      setState(() {
        driverToPickUp = newLats;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _utils.getBytesFromAsset('asset/images/markerCar.png', 124).then((value) {
      pinLocationIcon = BitmapDescriptor.fromBytes(value);
    });
    _utils.getBytesFromAsset('asset/images/marker.png', 124).then((value) {
      dropLocationIcon = BitmapDescriptor.fromBytes(value);
    });
    getPolyLinePoints();
    getDriverPolyLinePoints();
    getDriverProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context)),
          title: Text("Track Order"),
        ),
        body: SlidingUpPanel(
            maxHeight: MediaQuery.of(context).size.height / 4,
            minHeight: MediaQuery.of(context).size.height / 4,
            panel: Container(
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 4,
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Driver: ${widget.dataMap['riderName']}",
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            "Phone: ${widget.dataMap['riderPhone']}",
                            style: TextStyle(fontSize: 20),
                          ),
                          MaterialButton(
                            color: ThemeColors.primaryColor,
                            textColor: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text("Call Driver")
                              ],
                            ),
                            onPressed: () =>
                                launch("tel:${widget.dataMap['riderPhone']}"),
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: (MediaQuery.of(context).size.height / 4) / 4,
                    right: 10.0,
                    child: Container(
                      alignment: Alignment.center,
                      height: 120,
                      width: 120,
                      child: driverImage != null ? CachedNetworkImage(
                        imageUrl: driverImage,
                        imageBuilder: (context, provider) {
                          return Container(
                            height: 120,
                            padding: EdgeInsets.all(3),
                            width:120,
                            decoration: BoxDecoration(color: Colors.white, boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 14,
                                spreadRadius: 3
                              )
                            ]),
                            child: Image(image: provider, fit: BoxFit.cover),
                          );
                        },
                        placeholder: (context, url) {
                          return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor),);
                        },
                      ) : CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor),)
                  )
                  )
                ],
              ),
            ),
            body: pickUpToDrop != null && driverToPickUp != null
                ? Stack(
                    children: <Widget>[
                      GoogleMap(
                        polylines: _polylines,
                        markers: _markers,
                        myLocationEnabled: true,
                        buildingsEnabled: true,
                        scrollGesturesEnabled: true,
                        mapType: MapType.normal,
                        trafficEnabled: true,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: true,
                        initialCameraPosition: CameraPosition(
                            target: widget.pickUp,
                            zoom: 8,
                            bearing: 360.0,
                            tilt: 90.0),
                        onMapCreated: (GoogleMapController controller) async {
                          Timer.periodic(Duration(seconds: 10), (timer) {
                            Firestore.instance
                                .collection('allOrders')
                                .document(widget.orderID)
                                .get()
                                .then((value) {
                              if (mounted) {
                                if (value.data['riderPoint'][0] !=
                                    riderPosition) {
                                  setState(() {
                                    riderPosition = LatLng(
                                        value.data['riderPoint'][0],
                                        value.data['riderPoint'][1]);
                                    _markers.removeWhere(
                                        (m) => m.markerId.value == "riderPos");
                                    CameraPosition riderCamera = CameraPosition(
                                        target: riderPosition,
                                        bearing: 360.0,
                                        zoom: 6.0,
                                        tilt: 90.0);
                                    _googleMapController.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                            riderCamera));
                                    _markers.add(Marker(
                                        markerId: MarkerId('riderPos'),
                                        draggable: false,
                                        icon: pinLocationIcon,
                                        position: riderPosition,
                                        visible: true));
                                  });
                                }
                              }
                            });
                          });
                          setState(() {
                            _googleMapController = controller;
                            riderPosition = widget.driverPoint;
                            _polylines.add(Polyline(
                                polylineId: PolylineId('pickToDropPoly'),
                                color: ThemeColors.primaryColor,
                                width: 12,
                                startCap: Cap.buttCap,
                                endCap: Cap.roundCap,
                                visible: true,
                                points: pickUpToDrop));
                            _polylines.add(Polyline(
                                polylineId: PolylineId('driverToPickPoly'),
                                color: ThemeColors.primaryColor,
                                width: 12,
                                startCap: Cap.buttCap,
                                endCap: Cap.roundCap,
                                visible: true,
                                points: driverToPickUp));
                            _markers.add(Marker(
                              markerId: MarkerId("pickup"),
                              visible: true,
                              draggable: false,
                              icon: dropLocationIcon,
                              position: widget.pickUp,
                            ));
                            _markers.add(Marker(
                              markerId: MarkerId("droppos"),
                              visible: true,
                              draggable: false,
                              icon: dropLocationIcon,
                              position: widget.destPoint,
                            ));
                          });
                        },
                      ),
                    ],
                  )
                : Expanded(
                    child: Center(
                        child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor),
                  )))));
  }
}
