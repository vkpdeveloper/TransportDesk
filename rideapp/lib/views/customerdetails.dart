import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rideapp/controllers/firebase_utils.dart';

class CustomerDetails extends StatelessWidget {
  String firstName;
  String lastName;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseUtils _firebaseUtils = FirebaseUtils();

  @override
  Widget build(BuildContext context) {
    saveMyUserData() async {
      _firebaseUtils.saveGivenData(firstName, lastName);
      Navigator.pushReplacementNamed(context, '/homescreen');
    }

    return WillPopScope(
      onWillPop: () async {
        Fluttertoast.showToast(msg: "You can't go back !");
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0.0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
              ),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            bottom: PreferredSize(
              child: Container(
                padding: EdgeInsets.only(left: 16.0, bottom: 16, top: 20),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Customer Details",
                          style: TextStyle(
                              fontSize: 22.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Enter First and Last Name",
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              preferredSize: Size.fromHeight(100),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Form(
                    key: _formKey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            width: (MediaQuery.of(context).size.width / 2) - 50,
                            child: TextFormField(
                              validator: (String value) {
                                if (value.length < 3) {
                                  return "Invalid";
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (String value) {
                                firstName = value;
                              },
                              autofocus: true,
                              decoration:
                                  InputDecoration(hintText: "First Name"),
                            )),
                        Container(
                            width: (MediaQuery.of(context).size.width / 2) - 50,
                            child: TextFormField(
                              validator: (String value) {
                                if (value.length < 3) {
                                  return "Invalid";
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (String value) {
                                lastName = value;
                              },
                              decoration:
                                  InputDecoration(hintText: "Last Name"),
                            ))
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: RaisedButton(
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          "GO AHEAD",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            print(firstName);
                            print(lastName);
                            saveMyUserData();
                          }
                        },
                        padding: EdgeInsets.all(16.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
