import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:rideapp/controllers/firebase_utils.dart';
import 'package:rideapp/enums/station_view.dart';
import 'package:rideapp/providers/locationViewProvider.dart';
import 'package:rideapp/providers/orderprovider.dart';
import 'package:rideapp/providers/user_provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> capacityFormKey = GlobalKey<FormState>();
  final FirebaseUtils _utils = FirebaseUtils();

  @override
  Widget build(BuildContext context) {
    UserPreferences userPreferences = Provider.of<UserPreferences>(context);
    OrderProvider orderProvider = Provider.of<OrderProvider>(context);
    LocationViewProvider locationViewProvider =
        Provider.of<LocationViewProvider>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
              color: Colors.white,
            ),
            backgroundColor: ThemeColors.primaryColor,
            title: Text("Payment")),
        body: Stack(
          fit: StackFit.expand,
          children: [

          Center(child: Text("Make payment Confirmation")),
           
                  
            Positioned(
              bottom: -5.0,
              right: -4.0,
              left: -4.0,
              child: Card(
                  elevation: 8.0,
                  child: Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10.0),
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
                        MaterialButton(
                          color: ThemeColors.primaryColor,
                          height: 60.0,
                          minWidth: 180,
                          onPressed: () async {
                            _utils.startOrder(locationViewProvider,
                                  orderProvider, userPreferences, context);
                          },
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  )),
            )
          ],
        ));
  }
}
