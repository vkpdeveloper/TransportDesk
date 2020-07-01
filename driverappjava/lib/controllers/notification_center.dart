import 'dart:convert';

import 'package:driverapp/constants/apikeys.dart';
import 'package:http/http.dart';

class NotificationCenter {
  Future<Map<String, dynamic>> _httpSender(
      String endPoint, String message, String title, String token) async {
    Response res = await get(
        "${APIKeys.NOTIFICATION_HOST}$endPoint?token=$token&body=$message&title=$title");
    print(jsonDecode(res.body));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> _httpSenderWithoutTitle(
      String endPoint, String message, String token, String orderID) async {
    Response res = await get(
        "${APIKeys.NOTIFICATION_HOST}$endPoint?token=$token&body=$message&orderID=$orderID");
    print(jsonDecode(res.body));
    return jsonDecode(res.body);
  }

  void sendOnOrderComplete(String message, String token, String orderID) async {
    String endPoint = "/onordercomplete";
    Map<String, dynamic> returedData =
        await _httpSenderWithoutTitle(endPoint, message, token, orderID);
    print(returedData);
  }

  void sendPins(bool isPicked, String pin, String userToken) async {
    String message = "";
    String endPoint = "/send";
    String title = "Dear User";
    if (isPicked) {
      message = "Your Pickup Pin for Driver is $pin";
    } else {
      message = "Your Drop Pin for Driver is $pin";
    }
    Map<String, dynamic> returedData =
        await _httpSender(endPoint, message, title, userToken);
    print(returedData);
  }
}
