import 'package:adminappweb/const/themecolors.dart';
import 'package:adminappweb/pages/userdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class UserManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: ThemeColors.primaryColor),
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(
          "Users Manager",
          style: TextStyle(color: ThemeColors.primaryColor),
        ),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('user').snapshots(),
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
                  child: Text("No Users...!!!!"),
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
                              label: Text("USER UID"),
                            ),
                            DataColumn(
                              label: Text("USER NAME"),
                            ),
                            DataColumn(
                              label: Text("USER PHONE"),
                            ),
                            DataColumn(
                              label: Text("VENDOR EMAIL"),
                            ),
                            DataColumn(
                              label: Text("ACTION"),
                            )
                          ],
                          rows: snapshot.data.documents
                              .map((DocumentSnapshot user) {
                            return DataRow(cells: [
                              DataCell(Text(
                                user.documentID,
                              )),
                              DataCell(Text(
                                user.data['name']??"null",
                              )),
                              DataCell(Text(
                                user.data['phone']?? "Not Available",
                              )),
                              DataCell(Text(
                                user.data['email']?? "Not Available",
                              )),
                              DataCell(IconButton(
                                icon: Icon(Icons.search),
                                onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> UserDetails(data: user.data,)))
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