import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:rideapp/controllers/firebase_utils.dart';
import 'package:rideapp/providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseUtils _firebaseUtils = FirebaseUtils();
  bool isInternetFound = true;

  @override
  void initState() {
    super.initState();
    getStartHomeScreen();
  }

  void getStartHomeScreen() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      Timer(Duration(seconds: 3), () async {
        if (await _firebaseUtils.getLoggedIn()) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/homescreen');
        } else {
          if (!mounted) return;

          Navigator.pushReplacementNamed(context, '/loginscreen');
        }
      });
    } else {
      setState(() {
        isInternetFound = false;
      });
    }
  }

  FirebaseUtils _utils = FirebaseUtils();

  @override
  Widget build(BuildContext context) {
    void runFunc() async {
      if (await _utils.getLoggedIn()) {
        UserPreferences userPreferences =
            Provider.of<UserPreferences>(context, listen: false);
        userPreferences.init(context);
      }
    }

    runFunc();

    return Scaffold(
      backgroundColor: ThemeColors.primaryColor,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: ThemeColors.primaryColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: 200,
                height: 200,
                child: Image.asset("asset/images/newlogo.png")),
            SizedBox(height: 50),
            isInternetFound
                ? CircularProgressIndicator()
                : Text("No Internet !",
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}
