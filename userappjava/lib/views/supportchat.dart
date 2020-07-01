import 'dart:async';
import 'package:provider/provider.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rideapp/providers/user_provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _editingController = TextEditingController();

  final ScrollController _listController = ScrollController();

  double currentPixel;

  sendMessage(UserPreferences userPreferences) {
    
    Firestore.instance
        .collection('support')
        .document(userPreferences.getUserID)
        .collection('message')
        .add({
      "message": _editingController.text,
      "by": userPreferences.getUserID,
      "timestamp": Timestamp.now()
    }).whenComplete(() {
      _editingController.clear();
      _listController.animateTo(_listController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100), curve: Curves.easeIn);
    });
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      currentPixel = _listController.position.maxScrollExtent;
      _listController.animateTo(_listController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100), curve: Curves.easeIn);
    });
    // _listController.addListener(() {
    //   _listController.animateTo(_listController.position.maxScrollExtent,
    //         duration: Duration(milliseconds: 100), curve: Curves.easeIn);
    // });
  }

  @override
  Widget build(BuildContext context) {
    UserPreferences userPreferences = Provider.of<UserPreferences>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
    
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context)),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0.0,
          backgroundColor: ThemeColors.primaryColor,
          title: Text(
            userPreferences.getUserName,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              StreamBuilder(
                stream: Firestore.instance
                    .collection('support')
                    .document(userPreferences.getUserID)
                    .collection('message')
                    .orderBy("timestamp", descending: false)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ThemeColors.primaryColor),
                        ),
                      ),
                    );
                  } else {
                    if (snapshot.data.documents.length == 0) {
                      return Expanded(
                        child: Center(child: Text("No Messages")),
                      );
                    } else {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ListView(
                            controller: _listController,
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            children: snapshot.data.documents
                                .map((DocumentSnapshot message) {
                              if (message.data['by'] ==
                                  userPreferences.getUserID) {
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                      margin: EdgeInsets.all(10),
                                      padding: EdgeInsets.all(15.0),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 10.0,
                                                spreadRadius: 5.0,
                                                color: Colors.grey.shade100)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.blueGrey),
                                      child: Text(message.data['message'],
                                          style:
                                              TextStyle(color: Colors.white))),
                                );
                              } else {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                      margin: EdgeInsets.all(10),
                                      padding: EdgeInsets.all(15.0),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 10.0,
                                                spreadRadius: 5.0,
                                                color: Colors.grey.shade100)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: ThemeColors.primaryColor),
                                      child: Text(message.data['message'],
                                          style:
                                              TextStyle(color: Colors.white))),
                                );
                              }
                            }).toList(),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
              _buildComposser(userPreferences)
            ],
          ),
        ));
  }

  Widget _buildComposser(UserPreferences userPreferences) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onEditingComplete: () => sendMessage(userPreferences),
                controller: _editingController,
                decoration: InputDecoration(
                    hintText: "Type message...",
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: -10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    )),
              ),
            ),
            IconButton(
              onPressed: (){
                if(_editingController.text.trim()!=""){
                  sendMessage(userPreferences);}
                  },
                 
              color: ThemeColors.primaryColor,
              icon: Icon(Icons.send),
            )
          ],
        ),
      ),
    );
  }
}
