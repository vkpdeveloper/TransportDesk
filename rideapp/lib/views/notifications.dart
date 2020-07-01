import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification"),
      
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text("Notification lines"),
          ),
          ListTile(
            title: Text("Notification lines"),
          ),ListTile(
            title: Text("Notification lines"),
          ),ListTile(
            title: Text("Notification lines"),
          ),
        ],
      ),

    );
  }
}