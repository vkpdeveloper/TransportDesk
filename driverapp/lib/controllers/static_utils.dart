import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:driverapp/constants/apikeys.dart';

class StaticUtils {
  Future<Map<String, dynamic>> getDistenceAndDuration(
      String originAddress, String destinationAddress) async {
    originAddress = originAddress.replaceAll(" ", "+");
    destinationAddress = destinationAddress.replaceAll(" ", "+");
    Map<String, dynamic> returningData = {};
    Response res = await get(
        "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$originAddress&destinations=$destinationAddress&key=${APIKeys.googleMapsAPI}");
    Map<String, dynamic> parsedData = jsonDecode(res.body);
    String distance = parsedData['rows'][0]['elements'][0]['distance']['text'];
    String duration = parsedData['rows'][0]['elements'][0]['duration']['text'];
    print(duration);
    returningData['distance'] = distance;
    returningData['duration'] = duration;
    return returningData;
  }

  Future<String> getAddressByLatLng(LatLng latLng) async {
    Response res = await get(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=${APIKeys.googleMapsAPI}');
    var data = jsonDecode(res.body);
    return data['results'][0]['formatted_address'];
  }
}
