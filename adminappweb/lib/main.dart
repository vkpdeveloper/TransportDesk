import 'dart:async';

import 'package:adminappweb/adminHomescreen.dart';
import 'package:adminappweb/const/themecolors.dart';
import 'package:adminappweb/controllers/firebase_utils.dart';
import 'package:adminappweb/provider/truckEditingProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TruckEditingProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: ThemeColors.primaryColor,
            accentColor: Colors.white,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: GoogleFonts.openSansTextTheme()),
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseUtils _utils = FirebaseUtils();

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  checkLogin() async {
    Timer(Duration(seconds: 2), () async {
      if (await _utils.isLoggedIn()) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => AdminHomeScreen()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => AdminPanelScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.primaryColor,
      body: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "ADMIN APP",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30.0,
            ),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  String email;
  String password;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseUtils _utils = FirebaseUtils();
  ProgressDialog progressDialog;

  bool isShow = false;

  @override
  void initState() {
    super.initState();
  }

  _showSnackBar(String content) {
    SnackBar snackBar = SnackBar(
      content: Text(
        content,
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 2),
      backgroundColor: ThemeColors.primaryColor,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black12,
        appBar: AppBar(title: Text("Admin Login")),
        body: Center(
          child: Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width / 3,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text("Enter Login Details",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ThemeColors.primaryColor)),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        fillColor: ThemeColors.primaryColor,
                        filled: true,
                        hintStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10.0)),
                        hintText: "Admin Email"),
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.white),
                    onChanged: (val) {
                      email = val;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        fillColor: ThemeColors.primaryColor,
                        filled: true,
                        hintStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10.0)),
                        hintText: "Admin Password"),
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    onChanged: (val) {
                      password = val;
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      _utils.sendPasswordResetLink();
                      _showSnackBar("Password reset mail sent");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Forgot Password",
                          style: TextStyle(color: ThemeColors.primaryColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  MaterialButton(
                    color: ThemeColors.primaryColor,
                    minWidth: MediaQuery.of(context).size.width / 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    onPressed: () async {
                      bool isAdmin =
                          await _utils.signInWithUser(email, password);
                      if (await _utils.isLoggedIn()) {
                        if (isAdmin) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminHomeScreen()));
                        } else {
                          _showSnackBar("You are not a admin");
                          _utils.signOut();
                        }
                      } else {
                        _showSnackBar("Wrong email or password");
                      }
                    },
                    textColor: Colors.white,
                    child: Text("Login",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
