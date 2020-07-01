import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/constants/apikeys.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:rideapp/enums/locationview.dart';
import 'package:rideapp/providers/locationViewProvider.dart';

class DropLocationMap extends StatelessWidget {
  GoogleMapController _googleMapController;
  final LatLng initLatLng;
  final TextEditingController dropController;

  DropLocationMap({Key key, @required this.dropController, this.initLatLng})
      : super(key: key);

  String address;

  @override
  Widget build(BuildContext context) {
    LatLng lastPos;

    LocationViewProvider locationViewProvider =
        Provider.of<LocationViewProvider>(context);
    return Scaffold(
        body: Stack(children: [
      Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          onCameraMove: (position) {
            lastPos = position.target;
          },
          onCameraIdle: () async {
            try {
              if (locationViewProvider.getLocationView ==
                  LocationView.DESTINATIONSELECTED) {
                locationViewProvider.setDestinationLatLng(lastPos);
                Response res = await get(
                    'https://maps.googleapis.com/maps/api/geocode/json?latlng=${lastPos.latitude},${lastPos.longitude}&key=${APIKeys.googleMapsAPI}');
                var data = jsonDecode(res.body);
                var addressGet = data['results'][0]['formatted_address'];
                locationViewProvider.setDestinationPointAddress(addressGet);
                dropController.text = addressGet;
              } else {
                locationViewProvider.setPickUpLatLng(lastPos);
                Response res = await get(
                    'https://maps.googleapis.com/maps/api/geocode/json?latlng=${lastPos.latitude},${lastPos.longitude}&key=${APIKeys.googleMapsAPI}');
                var data = jsonDecode(res.body);
                var addressGet = data['results'][0]['formatted_address'];
                locationViewProvider.setPickUpAddress(addressGet);
                dropController.text = addressGet;
              }
            } catch (e) {
              print(e.toString());
            }
          },
          initialCameraPosition: CameraPosition(
              tilt: 60.0, bearing: 180, zoom: 18, target: initLatLng),
          onMapCreated: (controller) {
            _googleMapController = controller;
          },
          mapType: MapType.normal,
        ),
      ),
      Positioned(
        top: 30,
        left: 10.0,
        child: FloatingActionButton(
            heroTag: "arrow_back_drop_map",
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: ThemeColors.primaryColor,
            foregroundColor: Colors.white,
            child: Icon(Icons.arrow_back_ios)),
      ),
      Positioned(
          bottom: 20,
          left: 30.0,
          right: 30.0,
          child: MaterialButton(
            onPressed: () {
              dropController.text = address;
              Navigator.of(context).pop();
            },
            height: 40.0,
            color: ThemeColors.primaryColor,
            textColor: Colors.white,
            child: Text("Confirm"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
          )),
      pin()
    ]));
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
}
