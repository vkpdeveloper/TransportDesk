import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:rideapp/providers/user_provider.dart';
import 'package:rideapp/views/trackorder_screen.dart';

class AllBookings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserPreferences userPreferences = Provider.of<UserPreferences>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColors.primaryColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text("Your Orders"),
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('allOrders')
            .where("userID", isEqualTo: userPreferences.getUserID)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print("error in snapshot ${snapshot.error}");
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColors.primaryColor)));
            default:
              if (snapshot.data.documents.length == 0)
                return Center(child: Text("No Previous Orders"));
              else {
                return ListView(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Container(
                        child: Card(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0)),
                          child: Container(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          "Order ID : ${document["orderID"]}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          "Price : ₹ ${document.data['price']}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Your Agent : ${document["riderPhone"] ?? "Asigning Driver..."}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Payment Type : ${document["paymentMethod"]}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  getDropDetails(document, context)
                                ],
                              )),
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

  Widget getDropDetails(DocumentSnapshot document, BuildContext context) {
    if (document.data['isStart'] && !document.data['isDelivered']) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            onPressed: () {
              String riderPhone = document.data['riderPhone'];
              LatLng pickUp = LatLng(document.data['pickUpLatLng'][0],
                  document.data['pickUpLatLng'][1]);
              LatLng driverPoint = LatLng(document.data['riderPoint'][0],
                  document.data['riderPoint'][1]);
              LatLng deskPoint = LatLng(document.data['destLatLng'][0],
                  document.data['destLatLng'][1]);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TrackOrderScreen(
                          orderID: document.data['orderID'],
                          dataMap: document.data,
                          pickUp: pickUp,
                          driverPhone: riderPhone,
                          driverPoint: driverPoint,
                          destPoint: deskPoint)));
            },
            color: ThemeColors.primaryColor,
            child: Text(
              "TRACK SHIPMENT",
              style: TextStyle(color: Colors.white),
            ),
            minWidth: (MediaQuery.of(context).size.width - 70),
          )
        ],
      );
    } else if (!document.data['isStart']) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Searching For Truck...",
            style: TextStyle(
                color: ThemeColors.primaryColor,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          )
        ],
      );
    } else if (document.data['isStart'] && document.data['isDelivered']) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "ORDER DELIVERED SUCCESSFULLY",
            style: TextStyle(
                color: ThemeColors.primaryColor,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          )
        ],
      );
    }
  }
}
