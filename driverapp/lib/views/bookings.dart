import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driverapp/constants/themecolors.dart';
import 'package:driverapp/providers/user_sharedpref_provider.dart';
import 'package:driverapp/views/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

class Bookings extends StatefulWidget {
  @override
  _BookingsState createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  @override
  Widget build(BuildContext context) {
    UserPreferences userPreferences = Provider.of<UserPreferences>(context);
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("All Orders"),
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('allOrders')
            .where("riderPhone", isEqualTo: userPreferences.getUserPhone)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        ThemeColors.primaryColor)));
          } else {
            if (snapshot.data.documents.length == 0) {
              print(snapshot.data.documents.length);
              return Center(child: Text("NO ORDERS !"));
            } else {
              return ListView(
                children: snapshot.data.documents.map((DocumentSnapshot order) {
                  double distance = order.data['distance'];
                  String newDistance =
                      double.parse(distance.toString()).toStringAsFixed(2);
                  return Padding(
                    padding: const EdgeInsets.only(
                        right: 20.0, left: 20.0, top: 15.0, bottom: 10.0),
                    child: Container(
                      width: _width - 30,
                      height: _height / 4,
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade100,
                                blurRadius: 10.0,
                                spreadRadius: 10.0)
                          ],
                          borderRadius: BorderRadius.circular(15.0)),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              if (!order.data['isStart'] &&
                                  !order.data['isDelivered'])
                                Icon(
                                  Octicons.primitive_dot,
                                  color: Colors.green,
                                  size: 25.0,
                                ),
                              if (order.data['isStart'] &&
                                  !order.data['isDelivered'])
                                Icon(
                                  Octicons.primitive_dot,
                                  color: Colors.green,
                                  size: 25.0,
                                ),
                              if (order.data['isStart'] &&
                                  order.data['isDelivered'])
                                Icon(
                                  Octicons.primitive_dot,
                                  color: Colors.red,
                                  size: 25.0,
                                ),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "ORDER ID : ${order.documentID}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0),
                                  )),
                            ],
                          ),
                          SizedBox(height: 5),
                          Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${order.data['userName'].toString().toUpperCase()}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0),
                                  ),
                                  Text(
                                    "$newDistance KM",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0),
                                  ),
                                  Text(
                                    "Price : ${order.data['price']}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0),
                                  ),
                                ],
                              )),
                          SizedBox(height: 5),
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Pickup address: ${order.data['addresses'][0]}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0),
                              )),
                          SizedBox(height: 5),
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Drop address: ${order.data['addresses'][1]}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0),
                              )),
                          SizedBox(height: 7.0),
                          if (!order.data['isStart'] &&
                              !order.data['isDelivered'])
                            Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen())),
                                  icon: Icon(Icons.arrow_forward_ios),
                                  color: ThemeColors.primaryColor,
                                )),
                          if (order.data['isStart'] &&
                              !order.data['isDelivered'])
                            Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen())),
                                  icon: Icon(Icons.arrow_forward_ios),
                                  color: ThemeColors.primaryColor,
                                )),
                          if (order.data['isStart'] &&
                              order.data['isDelivered']) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "User: ${order.data['userName'].toString().toUpperCase()}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.0),
                                    )),
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Receiver: ${order.data['receiverName'].toString().toUpperCase()}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.0),
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Truck: ${order.data['truckName']}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.0),
                                    )),
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Payment: ${order.data['paymentMethod']}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.0),
                                    )),
                              ],
                            )
                          ]
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }
          }
        },
      ),
    );
  }
}
