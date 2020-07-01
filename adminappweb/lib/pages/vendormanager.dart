import 'package:adminappweb/const/themecolors.dart';
import 'package:adminappweb/pages/vendordetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VendorManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: ThemeColors.primaryColor),
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(
          "Vendor Manager",
          style: TextStyle(color: ThemeColors.primaryColor),
        ),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('vendor').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor),
                ),
              );
            } else {
              if (snapshot.data.documents.length == 0) {
                return Center(
                  child: Text("No Vendors...!!!!"),
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
                          columnSpacing: 150,
                          columns: [
                            DataColumn(
                              label: Text("VENDOR ID"),
                            ),
                            DataColumn(
                              label: Text("VENDOR NAME"),
                            ),
                            DataColumn(
                              label: Text("VENDOR PHONE"),
                            ),
                            DataColumn(
                              label: Text("VENDOR EMAIL"),
                            ),
                            DataColumn(
                              label: Text("ACTION"),
                            )
                          ],
                          rows: snapshot.data.documents
                              .map((DocumentSnapshot vendor) {
                            return DataRow(cells: [
                              DataCell(Text(
                                vendor.data['userID'],
                              )),
                              DataCell(Text(
                                vendor.data['name'],
                              )),
                              DataCell(Text(
                                vendor.data['phone'],
                              )),
                              DataCell(Text(
                                vendor.data['email'],
                              )),
                              DataCell(IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => VendorDetails(
                                              data: vendor.data,
                                            ))),
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
