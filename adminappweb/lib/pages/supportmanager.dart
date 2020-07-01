import 'package:adminappweb/const/themecolors.dart';
import 'package:adminappweb/pages/chatscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SupportManager extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scafffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: ThemeColors.primaryColor),
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(
          "Support Panel",
          style: TextStyle(color: ThemeColors.primaryColor),
        ),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('support').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor),
                ),
              );
            } else if (snapshot.error != null) {
              print(snapshot.error.toString());
              return Text(snapshot.error.toString());
            } else {
              if (snapshot.data.documents.length == 0) {
                return Center(
                  child: Text("No Pending Orders...!!!!"),
                );
              } else {
                return ListView(
                  children: snapshot.data.documents
                      .map((DocumentSnapshot user) => ListTile(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                        user: user.documentID,
                                        userName: user.data['name']))),
                            title: Text(user.data['name']),
                            subtitle: Text(user.data['phone']),
                          ))
                      .toList(),
                );
              }
            }
          }),
    );
  }
}
