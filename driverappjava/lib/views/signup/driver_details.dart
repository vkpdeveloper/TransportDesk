import 'package:driverapp/providers/signup_provider.dart';
import 'package:driverapp/views/signup/driver_documents.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:driverapp/controllers/firebase_utils.dart';
import 'package:provider/provider.dart';

class DriverDetails extends StatefulWidget {
  @override
  _DriverDetailsState createState() => _DriverDetailsState();
}

class _DriverDetailsState extends State<DriverDetails> {
  final _formKey = GlobalKey<FormState>();
  String name, phoneno, vehiclemodel, vehiclenumber, city, gstin;
  FirebaseUtils _utils = FirebaseUtils();
  List<String> allTrucks = [];

  @override
  void initState() {
    super.initState();
    getAllTrucks();
  }

  getAllTrucks() async {
    List<String> trucks = await _utils.getAllListOfTrucks();
    if (!mounted) return;
    setState(() {
      allTrucks = trucks;
    });
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want stop signup'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  final BoxDecoration containerdecor = BoxDecoration(
    color: Colors.black12,
    shape: BoxShape.rectangle,
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        offset: Offset(2.0, 2.0),
        spreadRadius: 1.0,
        blurRadius: 6.0,
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    final _fireutils = FirebaseUtils();
    SignUpProvider signUpProvider = Provider.of<SignUpProvider>(context);
    return allTrucks == null
        ? Scaffold(
          backgroundColor: Colors.yellow[300],
            body: Center(
            child: CircularProgressIndicator(),
          ))
        : WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              backgroundColor: Colors.yellow[300],
              body: SafeArea(
                  child: Form(
                autovalidate: true,
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 100,
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 30, 30, 0),
                            child: Text(
                              "Dear partner \nplease provide following Details",
                              style: GoogleFonts.josefinSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.black),
                            )),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                labelText: "Name",
                                contentPadding: EdgeInsets.all(4.0),
                                prefixIcon: Icon(Icons.person)),
                            validator: (value) {
                              if (value.length < 4) {
                                return 'Please enter name';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                name = value;
                              });
                              signUpProvider.setCity(value);
                            },
                          )),
                      Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: TextFormField(
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                labelText: "Mobile Number",
                                contentPadding: EdgeInsets.all(4.0),
                                prefixIcon: Icon(Icons.call)),
                            validator: (value) {
                              if (value.length == 0) {
                                return 'Please enter mobile number';
                              } else if (!RegExp(
                                      r"^(\+91[\-\s]?)?[0]?(91)?[789]\d{9}$")
                                  .hasMatch(value)) {
                                return 'Invalid mobile number';
                              }
                              return null;
                            },
                             onChanged: (value) {
                              setState(() {
                                phoneno = value;
                              });
                              signUpProvider.setCity(value);
                            },
                          )),
                      Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                labelText: "GSTIN",
                                contentPadding: EdgeInsets.all(4.0),
                                prefixIcon: Icon(Icons.confirmation_number)),
                            validator: (value) {
                              if (value.length == 0) {
                                return 'Please enter GSTIN';
                              } else if (!RegExp(
                                      r"^([0][1-9]|[1-2][0-9]|[3][0-7])([A-Z]{5})([0-9]{4})([A-Z]{1}[1-9A-Z]{1})([Z]{1})([0-9A-Z]{1})+$")
                                  .hasMatch(value)) {
                                return 'Invalid GSTIN';
                              }
                              return null;
                            },
                           onChanged: (value) {
                              setState(() {
                                gstin = value;
                              });
                            },
                          )),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: DropdownButtonFormField<String>(
                          hint: Text("Vehicle Model"),
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.black),
                          onChanged: (String value) {
                            setState(() {
                              vehiclemodel = value;
                            });
                            signUpProvider.setVehicleName(value);
                          },
                          items: allTrucks
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                labelText: "Vehicle Number",
                                contentPadding: EdgeInsets.all(4.0),
                                prefixIcon: Icon(Icons.directions_bus)),
                            validator: (value) {
                              if (value.length == 0) {
                                return 'Please enter Vehicle no';
                              } else if (!RegExp(
                                      r"^([A-Z]{2}\s?(\d{2})?(-)?([A-Z]{1}|\d{1})?([A-Z]{1}|\d{1})?( )?(\d{4}))$")
                                  .hasMatch(value)) {
                                return 'Invalid vehicle no';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                vehiclenumber = value;
                              });
                            },
                            
                          )),
                      Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: DropdownButtonFormField<String>(
                            icon: Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                labelText: "City",
                                contentPadding: EdgeInsets.all(4.0),
                                prefixIcon: Icon(Icons.location_city)),
                            style: TextStyle(color: Colors.black),
                            onChanged: (value) {
                              setState(() {
                                city = value;
                              });
                              signUpProvider.setCity(value);
                            },
                            items: <String>['Delhi', 'Delhi-NCR', 'Other']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )),
                      Column(
                        children: <Widget>[
                          Container(
                            child: MaterialButton(
                              color: Colors.yellow[800],
                              child: Text("Proceed"),
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  _fireutils.saveUserDetails(name, phoneno, gstin,
                                      vehiclemodel, vehiclenumber, city);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DriverDocuments(phoneno: phoneno,)),
                                  );
                                }
                              },
                            ),
                          ),
                          MaterialButton(
                          color: Colors.yellow[800],
                          child: Text("Proceed Test"),
                          onPressed: () {
                            
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DriverDocuments(phoneno: phoneno,)),
                              );
                            
                          },
                        ),
                        ],
                      )
                    ],
                  ),
                ),
              )),
            ),
          );
  }
}
