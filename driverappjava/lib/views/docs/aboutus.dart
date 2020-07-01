import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Scrollbar(
            child: ListView(children: <Widget>[
              Center(
                child: Text(
                  "About Us",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RichText(
                  text: TextSpan(
                      text: "Welcome to Transport Desk",
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: [
                    TextSpan(
                      text:
                          "\nTransport Desk is an Information Technology based online platform for booking trucks as per your/customer’s requirements. We provide booking of trucks for local as well as outstation routes.",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: "\n\nwhy choose us?",
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),),

                     TextSpan(
                      text:
                          "\n-Get more than thousand trucks on a single platform \n -Book Local Rides \n -Book Outstation Rides \n -Go cashless\n -Reliable trucks  \n -Pricing Transparency \n -Pricing Control \n -Real time booking \n -Real time tracking \n -Journey start and end validation.",
                          style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black),
                    ),
                  ])),
            ]),
          ),
        ),
      ),
    );
  }
}
