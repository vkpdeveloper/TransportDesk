import 'package:driverapp/services/firebase_auth_service.dart';
import 'package:driverapp/views/signup/driver_details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Verification extends StatefulWidget {
  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    final _auth = Provider.of<FirebaseAuthService>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.yellow[300],
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: _width / 2,
                      width: _width / 2,
                      child: Image.asset("assets/images/logonew.png"),
                    ),
                    Container(
                      height: _height / 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Partner Signup",
                            style: GoogleFonts.josefinSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 30.0,
                                color: Colors.blue),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Welcome dear Partner\nPlease get your Documents ready\n-Aadhar Card \n-Driving Licence\n-Registration Certificate of Vehicle(RC)",
                        style: GoogleFonts.josefinSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.blue),
                      ),
                    ),
                    MaterialButton(
                      minWidth: 120,
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    DriverDetails()));
                      },
                      child: Text(
                        "SignUp",
                        style: GoogleFonts.josefinSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black),
                      ),
                    ),
                    MaterialButton(
                      minWidth: 120,
                      color: Colors.red[400],
                      child: Text(
                        "LogOut",
                        style: GoogleFonts.josefinSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black),
                      ),
                      onPressed: () {
                        _auth.signOut();
                        Navigator.pushReplacementNamed(context, '/loginscreen');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
