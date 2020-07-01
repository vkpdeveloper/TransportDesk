import 'package:adminappweb/const/themecolors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UnassignedOrders extends StatefulWidget {
  @override
  _UnassignedOrdersState createState() => _UnassignedOrdersState();
}

class _UnassignedOrdersState extends State<UnassignedOrders> {
  @override
  void initState() {
    super.initState();
  }

  GlobalKey<ScaffoldState> _scafffoldKey = GlobalKey<ScaffoldState>();

  assignOrder(String orderID, String phone) {
    Firestore.instance
        .collection('vendor')
        .document(phone)
        .get()
        .then((value) => {
              if (value.exists)
                {
                  Firestore.instance
                      .collection('allOrders')
                      .document(orderID)
                      .updateData({
                    "isPending": false,
                    "riderPhone": phone,
                    "riderUserID": value.data['userID']
                  })
                }
            });
    Navigator.of(_scafffoldKey.currentContext).pop();
  }

  showAssignDialog(String orderID) => showDialog(
      context: _scafffoldKey.currentContext,
      barrierDismissible: true,
      builder: (context) {
        TextEditingController _phoneController = TextEditingController();
        return AlertDialog(
            actions: [
              MaterialButton(
                onPressed: () => assignOrder(orderID, _phoneController.text),
                child: Text("ASSIGN"),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
              )
            ],
            title: Text("Assign Order"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: "Enter Vendor Phone",
                      labelText: "Phone",
                      prefixIcon: Icon(Icons.dialpad)),
                )
              ],
            ));
      });

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
          "Order Manager",
          style: TextStyle(color: ThemeColors.primaryColor),
        ),
      ),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('allOrders')
              .where("isPending", isEqualTo: true)
              .snapshots(),
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
                              label: Text("CUSTOMER PHONE"),
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
                                order.data['userName']
                                        .toString()
                                        .toUpperCase() ??
                                    "Unknown",
                              )),
                              DataCell(Text(
                                order.data['userPhone'] ?? "Not Available",
                              )),
                              DataCell(Text(
                                order.data['truckName'] ?? "Not Available",
                              )),
                              DataCell(Text(
                                order.data['distance'].toString() ??
                                    "Not Available",
                              )),
                              DataCell(Text(
                                order.data['price'].toString() ?? "null",
                              )),
                              DataCell(Text(
                                order.data['paymentMethod'] ?? "Not Available",
                              )),
                              DataCell(MaterialButton(
                                onPressed: () =>
                                    showAssignDialog(order.data['orderID']),
                                child: Text("ASSIGN"),
                                color: Theme.of(context).primaryColor,
                                textColor: Colors.white,
                              ))
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
