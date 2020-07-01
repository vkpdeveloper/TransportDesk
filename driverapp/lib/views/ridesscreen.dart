import 'package:flutter/material.dart';

class RidesScreen extends StatefulWidget {
  @override
  _RidesScreenState createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Container(
            child: Text("Show rides with cards using list view"),
          )
        ],
      )),
    );
  }
}
