import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearbyPlace {
  String name;
  String icon;
  LatLng latLng;

  @override
  String toString() {
    return 'NearbyPlace{name: $name, icon: $icon, latLng: $latLng}';
  }
}