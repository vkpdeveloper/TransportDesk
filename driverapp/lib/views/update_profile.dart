import 'package:driverapp/constants/themecolors.dart';
import 'package:driverapp/views/signup/driver_details.dart';
import 'package:flutter/material.dart';

class UpdateProfile extends StatefulWidget {
  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.green[200],
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 70,
                              backgroundImage: NetworkImage(
                                  "https://vaibhavpathakofficial.tk/img/vaibhav.png"),
                              backgroundColor: ThemeColors.primaryColor,
                            ),
                            Column(
                              children: <Widget>[
                                Text("Name of Driver"),
                                Text("bool varified"),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        RaisedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => new AlertDialog(
                                title: new Text('Documents ready?'),
                                content: new Text(
                                    'Please get your Aadhar Card, Driving license and RC of vehicle Ready'),
                                actions: <Widget>[
                                  new FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: new Text('No'),
                                  ),
                                  new FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  DriverDetails()));
                                    },
                                    child: new Text('Ready'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text("Upload Documents"),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
