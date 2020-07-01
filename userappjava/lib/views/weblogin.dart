import 'package:flutter/material.dart';

class WebLogin extends StatefulWidget {
  @override
  _WebLoginState createState() => _WebLoginState();
}

class _WebLoginState extends State<WebLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Web Login"),
        ),
        body: Column(
          children: <Widget>[Text("Show Code for web")],
        ));
  }
}
