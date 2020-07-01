import 'package:adminappweb/const/themecolors.dart';
import 'package:adminappweb/controllers/static_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetails extends StatelessWidget {
  final Map<String, dynamic> data;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  UserDetails({Key key, this.data}) : super(key: key);

  StaticUtils _utils = StaticUtils();

  showPopupDialog(DocumentSnapshot doc) {
    return showDialog(
        context: _scaffoldKey.currentContext,
        builder: (context) {
          return AlertDialog(
            title: Text("Order Details"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Order ID : ${doc.documentID}",
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Agent Name : ${doc.data['riderUserID']}",
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "PickUp Address : ${doc.data['addresses'][0]}",
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Drop Address : ${doc.data['addresses'][1]}",
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  width: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      textColor: Colors.white,
                      color: ThemeColors.primaryColor,
                      onPressed: () => launch(
                          "https://www.google.com/maps/place/${doc.data['addresses'][0].toString().replaceAll(" ", "+")}/@${doc.data['pickUpLatLng'][0]},${doc.data['pickUpLatLng'][1]},12z/"),
                      child: Text("PICKUP"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    MaterialButton(
                      textColor: Colors.white,
                      color: ThemeColors.primaryColor,
                      onPressed: () => launch(
                          "https://www.google.com/maps/place/${doc.data['addresses'][1].toString().replaceAll(" ", "+")}/@${doc.data['destLatLng'][0]},${doc.data['destLatLng'][1]},12z/"),
                      child: Text("DROP"),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      textColor: Colors.white,
                      color: ThemeColors.primaryColor,
                      onPressed: () => launch(
                          "https://www.google.com/maps/place/@${doc.data['riderPoint'][0]},${doc.data['riderPoint'][1]},12z/"),
                      child: Text("DRIVER"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    MaterialButton(
                      textColor: Colors.white,
                      color: ThemeColors.primaryColor,
                      onPressed: () => launch(
                          "https://www.google.com/maps/dir/${doc.data['addresses'][0].toString().replaceAll(" ", "+")}/${doc.data['addresses'][1].toString().replaceAll(" ", "+")}/@${doc.data['destLatLng'][0]},${doc.data['destLatLng'][1]},8z"),
                      child: Text("DIRECTION"),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: ThemeColors.primaryColor),
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(
          data['name'],
          style: TextStyle(color: ThemeColors.primaryColor),
        ),
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('allOrders')
            .where("userPhone", isEqualTo: data['phone'])
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print("error in snapshot ${snapshot.error}");
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeColors.primaryColor)));
            default:
              if (snapshot.data.documents.length == 0)
                return Center(child: Text("No Previous Orders"));
              else {
                return ListView(
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: GestureDetector(
                        onTap: () {
                          if (document.data['isStart']) {
                            showPopupDialog(document);
                          } else {
                            _utils.showSnackBar(
                                "Order not yet started", _scaffoldKey);
                          }
                        },
                        child: Container(
                          child: Card(
                            elevation: 8.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0)),
                            child: Container(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Octicons.primitive_dot,
                                                color: document
                                                            .data['isStart'] &&
                                                        !document
                                                            .data['isDelivered']
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              Text(
                                                "Order ID : ${document["orderID"]}",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Text(
                                            "Price : ₹ ${document.data['price']}",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Agent ID : ${document["riderUserID"]}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Receiver Name : ${document["receiverName"]}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Payment Type : ${document["paymentMethod"]}",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8.0,
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }
          }
        },
      ),
    );
  }
}
