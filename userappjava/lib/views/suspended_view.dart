import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:rideapp/constants/themecolors.dart';

class SuspendedScreen extends StatefulWidget {
  @override
  _SuspendedScreenState createState() => _SuspendedScreenState();
}

class _SuspendedScreenState extends State<SuspendedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You Are Suspended from using the app\nPlease Contact Costumer support \nfor resolving issues..',
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
              SizedBox(
                height: 30,
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/support');
                },
                icon: Icon(
                  AntDesign.customerservice,
                  color: ThemeColors.primaryColor,
                  size: 40,
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
