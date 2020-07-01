import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/AppLocalizations.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:rideapp/controllers/firebase_utils.dart';
import 'package:rideapp/enums/station_view.dart';
import 'package:rideapp/providers/locationViewProvider.dart';
import 'package:rideapp/providers/orderprovider.dart';
import 'package:rideapp/providers/user_provider.dart';
import 'package:intl/intl.dart' as dateformat;

class OrderDetailsScreen extends StatefulWidget {
  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final GlobalKey<FormState> capacityFormKey = GlobalKey<FormState>();

  final FirebaseUtils _utils = FirebaseUtils();

  bool nightTimeOrder = false;

  getNightBool() async {
    bool night = await _utils.getisFareHighHours();
    setState(() {
      nightTimeOrder = night;
    });
  }

  @override
  void initState() {
    super.initState();
    getNightBool();
  }

  @override
  Widget build(BuildContext context) {
    UserPreferences userPreferences = Provider.of<UserPreferences>(context);
    OrderProvider orderProvider = Provider.of<OrderProvider>(context);
    LocationViewProvider locationViewProvider = Provider.of<LocationViewProvider>(context);
    int orderPrice = orderProvider.getOrderPrice;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
              color: Colors.white,
            ),
            backgroundColor: ThemeColors.primaryColor,
            title: Text(AppLocalizations.of(context).translate("Confirm Order"))),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: <Widget>[
                Card(
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.grey.shade400,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Icon(Octicons.primitive_dot, color: Colors.green),
                                        Text(
                                          AppLocalizations.of(context).translate("Pickup Address"),
                                          textDirection: TextDirection.ltr,
                                          style: new TextStyle(fontSize: 20.0, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 10.0),
                                    Text(
                                      locationViewProvider.getPickUpPointAddress,
                                      textDirection: TextDirection.ltr,
                                      style: new TextStyle(fontSize: 15.0, color: Colors.black),
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Icon(Octicons.primitive_dot, color: Colors.red),
                                        Text(
                                          AppLocalizations.of(context).translate("DROP Address"),
                                          style: new TextStyle(fontSize: 20.0, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 10.0),
                                    Text(
                                      locationViewProvider.getDestinationPointAddress,
                                      style: new TextStyle(fontSize: 15.0, color: Colors.black),
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        AppLocalizations.of(context)
                                            .translate("Approx Distance -  "),
                                        textDirection: TextDirection.ltr,
                                        style: new TextStyle(fontSize: 20.0, color: Colors.black),
                                      ),
                                      Text(
                                        "${orderProvider.getTotalDistance.toString().split(".").first} KM",
                                        textDirection: TextDirection.ltr,
                                        style: new TextStyle(fontSize: 20.0, color: Colors.black),
                                        maxLines: 3,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        AppLocalizations.of(context)
                                            .translate("Truck Selected -   "),
                                        textDirection: TextDirection.ltr,
                                        style: new TextStyle(fontSize: 20.0, color: Colors.black),
                                      ),
                                      Text(
                                        orderProvider.getTruckName,
                                        textDirection: TextDirection.ltr,
                                        style: new TextStyle(fontSize: 20.0, color: Colors.black),
                                        maxLines: 3,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        AppLocalizations.of(context).translate("Order Type -   "),
                                        textDirection: TextDirection.ltr,
                                        style: new TextStyle(fontSize: 20.0, color: Colors.black),
                                      ),
                                      if (orderProvider.getStationView == StationView.LOCAL) ...[
                                        Text(
                                          "Local Ride",
                                          textDirection: TextDirection.ltr,
                                          style: new TextStyle(fontSize: 20.0, color: Colors.black),
                                          maxLines: 3,
                                        ),
                                      ] else
                                        Text(
                                          AppLocalizations.of(context).translate("OutStation Ride"),
                                          textDirection: TextDirection.ltr,
                                          style: new TextStyle(fontSize: 20.0, color: Colors.black),
                                          maxLines: 3,
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      if (orderProvider.getScheduledRide) ...[
                                        Text(
                                          AppLocalizations.of(context)
                                              .translate("Scheduled Time -   "),
                                          textDirection: TextDirection.ltr,
                                          style: new TextStyle(fontSize: 20.0, color: Colors.black),
                                        ),
                                        Text(
                                          "${dateformat.DateFormat.yMMMd().format(orderProvider.getTimeOfOrderDelivery)} at ${dateformat.DateFormat.jms().format(orderProvider.getTimeOfOrderDelivery)}",
                                          textDirection: TextDirection.ltr,
                                          style: new TextStyle(fontSize: 15.0, color: Colors.black),
                                          maxLines: 3,
                                        ),
                                      ] else
                                        Container(),
                                    ],
                                  ),
                                ),
                                if (nightTimeOrder) ...[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          "Due to Night Time Fares are High *",
                                          textDirection: TextDirection.ltr,
                                          style: new TextStyle(fontSize: 15.0, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else
                                  Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 5.0,
              right: 4.0,
              left: 4.0,
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            FontAwesome.rupee,
                            color: ThemeColors.primaryColor,
                            size: 25.0,
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            orderProvider.getOrderPrice.toString(),
                            style: GoogleFonts.openSans(
                                letterSpacing: 1.5,
                                fontSize: 20.0,
                                color: ThemeColors.primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            ThemeColors.primaryColor,
                            Color(0xff8E2DE2),
                            ThemeColors.primaryColor,
                          ]),
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeColors.primaryColor.withOpacity(0.2),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            )
                          ]),
                      child: MaterialButton(
                        height: 50.0,
                        minWidth: MediaQuery.of(context).size.width / 2 + 20,
                        onPressed: () async {
                          orderProvider.setTimeOfOrderPlaced(DateTime.now());
                          if (orderProvider.getScheduledRide) {
                            ProgressDialog dialog = ProgressDialog(context,
                                isDismissible: false, type: ProgressDialogType.Normal);
                            dialog.style(
                              elevation: 8.0,
                              borderRadius: 15,
                              message: "Searching for truck...",
                              backgroundColor: Colors.white,
                              insetAnimCurve: Curves.bounceIn,
                            );
                            dialog.show();
                            _utils.addScheduledOrder(locationViewProvider, orderProvider, dialog,
                                userPreferences, context);
                          } else {
                            _utils.startOrder(
                                locationViewProvider, orderProvider, userPreferences, context);
                          }
                        },
                        child: Text(
                          AppLocalizations.of(context).translate("Place"),
                          style: TextStyle(
                              color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
