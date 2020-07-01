import 'package:adminappweb/const/themecolors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String user;
  final String userName;

  ChatScreen({Key key, this.user, this.userName}) : super(key: key);

  TextEditingController _editingController = TextEditingController();

  final ScrollController _listController = ScrollController();

  sendMessage() {
    Firestore.instance
        .collection('support')
        .document(user)
        .collection('message')
        .add({
      "message": _editingController.text,
      "by": "support",
      "timestamp": Timestamp.now()
    }).whenComplete(() {
      _editingController.clear();
      _listController.animateTo(_listController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100), curve: Curves.easeIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: ThemeColors.primaryColor),
          elevation: 0.0,
          backgroundColor: Colors.white,
          title: Text(
            userName,
            style: TextStyle(color: ThemeColors.primaryColor),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              StreamBuilder(
                stream: Firestore.instance
                    .collection('support')
                    .document(user)
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
                        child: Center(child: Text(" No Messages")),
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
                              if (message.data['by'] == user) {
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
                                          color: Colors.blueGrey),
                                      child: Text(message.data['message'],
                                          style:
                                              TextStyle(color: Colors.white))),
                                );
                              } else {
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
              _buildComposser()
            ],
          ),
        ));
  }

  Widget _buildComposser() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onEditingComplete: sendMessage,
                controller: _editingController,
                autofocus: true,
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
              onPressed: sendMessage,
              color: ThemeColors.primaryColor,
              icon: Icon(Icons.send),
            )
          ],
        ),
      ),
    );
  }
}
