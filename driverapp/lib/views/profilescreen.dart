import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driverapp/constants/themecolors.dart';
import 'package:driverapp/controllers/firebase_utils.dart';
import 'package:driverapp/providers/user_sharedpref_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var _userdata;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    UserPreferences user = Provider.of<UserPreferences>(context);
    String userName = user.getUserName;
    String userPhone = user.getUserPhone;
    String userProfileUrl  = user.getProfile;
    String vehicleName = user.getVehicleName;
    String vehicleNumber = user.getVehicleNumber;
    double rating = user.getRating;

    


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Stack(
        children: <Widget>[
         Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      userName ?? "Loading...",
                      style: TextStyle(fontSize: 25,color: Colors.black ),
                    ),
                    Text("$vehicleName | $vehicleNumber")
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(
                            userProfileUrl),
                        backgroundColor: ThemeColors.primaryColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: SmoothStarRating(
                            allowHalfRating: false,
                            onRated: (v) {},
                            starCount: 5,
                            rating: rating,
                            size: 25.0,
                            isReadOnly: true,
                            color: Colors.yellow,
                            borderColor: Colors.yellow,
                            spacing: 0.0),
                      ),
                      Text(rating.toString()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Achievement  "),
                          Icon(FontAwesome.trophy)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            right: 20,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Done for Today"),
                ),
                MaterialButton(
                  minWidth: _width - 40,
                  height: 50,
                  color: Colors.red,
                  onPressed: () {},
                  child: Text(
                    "Go Offline",
                    style: TextStyle(fontSize: 25),
                  ),
                )
              ],
            ),
          )
        ],
      )),
    );
  }
}
