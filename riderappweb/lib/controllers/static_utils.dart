import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as Math;
import 'package:flutter/services.dart' show PlatformException, rootBundle;
import 'package:flutter_google_maps/flutter_google_maps.dart';

class StaticUtils {
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  double distanceInKmBetweenEarthCoordinates(
      GeoCoord pickUp, GeoCoord destLatLng) {
    var p = 0.017453292519943295;
    var c = Math.cos;
    var a = 0.5 -
        c((destLatLng.latitude - pickUp.latitude) * p) / 2 +
        c(pickUp.latitude * p) *
            c(destLatLng.latitude * p) *
            (1 - c((destLatLng.longitude - pickUp.longitude) * p)) /
            2;

    return 12742 * Math.asin(Math.sqrt(a));
  }
}
