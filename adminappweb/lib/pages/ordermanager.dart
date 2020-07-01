import 'package:adminappweb/const/themecolors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderManager extends StatefulWidget {
  @override
  _OrderManagerState createState() => _OrderManagerState();
}

class _OrderManagerState extends State<OrderManager> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    QuerySnapshot snapshot =
        await Firestore.instance.collection('allOrders').getDocuments();
    snapshot.documents.forEach((element) {
      print(element.documentID);
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
          "Order Manager",
          style: TextStyle(color: ThemeColors.primaryColor),
        ),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('allOrders').snapshots(),
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
                  child: Text("No Orders...!!!!"),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DataTable(
                          dividerThickness: 2,
                          columnSpacing: 40,
                          columns: [
                            DataColumn(
                              label: Text("ORDER ID"),
                            ),
                            DataColumn(
                              label: Text("CUSTOMER"),
                            ),
                            DataColumn(
                              label: Text("CUSTOMER"),
                            ),
                            DataColumn(
                              label: Text("TRUCK"),
                            ),
                            DataColumn(
                              label: Text("DISTANCE"),
                            ),
                            DataColumn(
                              label: Text("ESTD PRICE"),
                            ),
                            DataColumn(
                              label: Text("PAYMENT"),
                            ),
                            DataColumn(
                              label: Text("ACTION"),
                            )
                          ],
                          rows: snapshot.data.documents
                              .map((DocumentSnapshot order) {
                            return DataRow(cells: [
                              DataCell(Text(
                                order.data['orderID'],
                              )),
                              DataCell(Text(
                                order.data['userName'].toString().toUpperCase() ?? "null",
                              )),
                              DataCell(Text(
                                order.data['userPhone'] ?? "Not Available",
                              )),
                              DataCell(Text(
                                order.data['truckName'] ?? "Not Available",
                              )),
                              DataCell(Text(
                                order.data['distance'].toString() ?? "Not Available",
                              )),
                              DataCell(Text(
                                order.data['price'].toString() ?? "null",
                              )),
                              DataCell(Text(
                                order.data['paymentMethod'] ?? "Not Available",
                              )),
                              DataCell(IconButton(
                                  icon: Icon(Icons.search), onPressed: () {}))
                            ]);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
          }),
    );
  }
}
