import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/AppLocalizations.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:rideapp/providers/user_provider.dart';
import 'package:rideapp/views/trackorder_screen.dart';
import 'package:intl/intl.dart' as dateformat;
import 'package:smooth_star_rating/smooth_star_rating.dart';

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
        title: Text(AppLocalizations.of(context).translate("Your Orders")),
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
                      valueColor: AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor)));
            default:
              if (snapshot.data.documents.length == 0)
                return Center(
                    child: Text(AppLocalizations.of(context).translate("No Previous Orders")));
              else {
                return ListView(
                  children: snapshot.data.documents.map((DocumentSnapshot document) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Container(
                        child: Card(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
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
                                          "${AppLocalizations.of(context).translate("Order ID")} : ${document["orderID"]}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          "${AppLocalizations.of(context).translate("Price")} : ₹ ${document.data['price']}",
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
                                      "${AppLocalizations.of(context).translate("Your Agent")} : ${document["riderPhone"] ?? "Asigning Driver..."}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, color: Colors.black54),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  if (document['isScheduled'])
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "${AppLocalizations.of(context).translate("Scheduled Time")} : ${dateformat.DateFormat.yMMMMd().format(document["timeForDelivery"].toDate())}: ${dateformat.DateFormat.jms().format(document["timeForDelivery"].toDate())}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, color: Colors.black54),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
            color: Colors.red,
            onPressed: () {
              showBottomSheet(
                  context: (context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  backgroundColor: Colors.white,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      child: Container(
                          height: MediaQuery.of(context).size.height / 3 + 50,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Cancel Ride",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                "30% of order payment may be charged",
                                style: TextStyle(fontSize: 15, color: Colors.red),
                              ),
                              ListTile(
                                  leading: Text("Drider didn't came for pickup"),
                                  trailing: Icon(Icons.check_box)),
                              ListTile(
                                  leading: Text("Driver Wants Cash"),
                                  trailing: Icon(Icons.check_box)),
                              ListTile(
                                  leading: Text("My Reason is not listed"),
                                  trailing: Icon(Icons.check_box)),
                              Container(
                                child: Center(
                                  child: MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25.0)),
                                    color: Colors.red,
                                    onPressed: () {},
                                    child: Text("Cancel"),
                                  ),
                                ),
                              )
                            ],
                          )),
                    );
                  });
            },
            child: Text(
              AppLocalizations.of(context).translate("Cancel Order"),
              style: TextStyle(color: Colors.white),
            ),
          ),
          MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
            onPressed: () {
              String riderPhone = document.data['riderPhone'];
              LatLng pickUp =
                  LatLng(document.data['pickUpLatLng'][0], document.data['pickUpLatLng'][1]);
              LatLng driverPoint =
                  LatLng(document.data['riderPoint'][0], document.data['riderPoint'][1]);
              LatLng deskPoint =
                  LatLng(document.data['destLatLng'][0], document.data['destLatLng'][1]);
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
              AppLocalizations.of(context).translate("TRACK SHIPMENT"),
              style: TextStyle(color: Colors.white),
            ),
            minWidth: (MediaQuery.of(context).size.width / 2),
          )
        ],
      );
    } else if (!document.data['isStart']) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          MaterialButton(
            onPressed: () {
              showBottomSheet(
                  context: (context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  backgroundColor: Colors.white,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      child: Container(
                          height: MediaQuery.of(context).size.height / 3,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Cancel Ride",
                                style: TextStyle(fontSize: 20),
                              ),
                              ListTile(
                                  leading: Text("Drider didn't came for pickup"),
                                  trailing: Icon(Icons.check_box)),
                              ListTile(
                                  leading: Text("Driver Wants Cash"),
                                  trailing: Icon(Icons.check_box)),
                              ListTile(
                                  leading: Text("My Reason is not listed"),
                                  trailing: Icon(Icons.check_box)),
                              Container(
                                child: Center(
                                  child: MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25.0)),
                                    color: Colors.red,
                                    onPressed: () {},
                                    child: Text("Cancel"),
                                  ),
                                ),
                              )
                            ],
                          )),
                    );
                  });
            },
            child: Text(
              AppLocalizations.of(context).translate("Cancel Order"),
              style: TextStyle(color: Colors.red, fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            AppLocalizations.of(context).translate("Searching For Truck..."),
            style: TextStyle(
                color: ThemeColors.primaryColor, fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ],
      );
    } else if (document.data['isStart'] && document.data['isDelivered']) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).translate("DELIVERED SUCCESSFULLY"),
            style: TextStyle(
                color: ThemeColors.primaryColor, fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          MaterialButton(
            onPressed: () {
              showBottomSheet(
                  context: (context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                  ),
                  backgroundColor: Colors.white,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                      child: Container(
                          height: MediaQuery.of(context).size.height / 3 + 50,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Feedback",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                "Please Rate your experience",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              ListTile(
                                  leading: Text("Stars for driver"),
                                  trailing: Container(
                                    child: SmoothStarRating(
                                      color: Colors.yellow,
                                      allowHalfRating: true,
                                      starCount: 5,
                                    ),
                                  )),
                              ListTile(
                                  leading: Text("overall rating"),
                                  trailing: Container(
                                    child: SmoothStarRating(
                                      color: Colors.yellow,
                                      allowHalfRating: true,
                                      starCount: 5,
                                    ),
                                  )),
                              TextField(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(), hintText: "Tell Us More..."),
                                maxLines: 2,
                                minLines: 2,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Container(
                                  child: Center(
                                    child: MaterialButton(
                                      minWidth: 150,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25.0)),
                                      color: ThemeColors.darkblueColor,
                                      onPressed: () {},
                                      child: Text(
                                        "Submit",
                                        style: TextStyle(color: Colors.yellow),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )),
                    );
                  });
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
            color: Colors.yellow,
            child: Text(
              AppLocalizations.of(context).translate("Feedback"),
              style: TextStyle(
                  color: ThemeColors.primaryColor, fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          )
        ],
      );
    }
  }
}
