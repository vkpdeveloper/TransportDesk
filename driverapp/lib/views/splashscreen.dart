import 'dart:async';

import 'package:driverapp/providers/user_sharedpref_provider.dart';
import 'package:driverapp/views/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driverapp/constants/themecolors.dart';
import 'package:driverapp/controllers/firebase_utils.dart';
import 'package:driverapp/services/firebase_auth_service.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key, this.userSnapshot}) : super(key: key);
  final AsyncSnapshot<User> userSnapshot;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseUtils _firebaseUtils = FirebaseUtils();
  bool vendorexists;

  // getvendorexist() async {
  //   String userphoneno = await _firebaseUtils.getuserphoneno();
  //   vendorexists = await _firebaseUtils.isVendorExists();
  // }

  @override
  void initState() {
    super.initState();
    // getvendorexist();
    getStartHomeScreen();
  }

  void getStartHomeScreen() {
    Timer(Duration(seconds: 3), () async {
      if (await _firebaseUtils.getLoggedIn()) {
        // if (vendorexists) {
        //   Navigator.pushReplacementNamed(context, '/homescreen');
        // } else {
        //   Navigator.pushReplacementNamed(context, '/verification');
        // }
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => VerificationCheck()));
      } else {
        Navigator.pushReplacementNamed(context, '/loginscreen');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    UserPreferences userPreferences = Provider.of<UserPreferences>(context);
    run() async {
      if (await _firebaseUtils.getLoggedIn()) {
        userPreferences.init();
      }
    }

    run();

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
              height: 200,
              width: 200,
              child: Image.asset('assets/images/newlogo.png')),
            Text(
              "Partner App",
              style: GoogleFonts.josefinSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  color: Colors.white),
            ),
            SizedBox(height: 50),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
