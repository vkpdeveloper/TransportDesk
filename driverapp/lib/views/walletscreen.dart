import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driverapp/controllers/firebase_utils.dart';
import 'package:driverapp/views/tripdetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driverapp/constants/themecolors.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  DateTime _datetime = DateTime.now();
  String _currentDate;
  Map<String, dynamic> _todaysEarning;
  FirebaseUtils _utils = FirebaseUtils();
  int getWholeMoneyOfToday = 0;

  @override
  void initState() {
    super.initState();
    _currentDate = "${_datetime.day}-${_datetime.month}-${_datetime.year}";
    getTodayEarning();
  }

  getTodayEarning() async {
    getWholeMoneyOfToday = 0;
    DocumentSnapshot _vendorTodayData = await Firestore.instance
        .collection('vendor')
        .document(await _utils.getuserphoneno())
        .collection('wallet')
        .document(_currentDate)
        .get();
    if (_vendorTodayData.data != null) {
      for (dynamic moneyKey in _vendorTodayData.data.keys) {
        getWholeMoneyOfToday += _vendorTodayData.data[moneyKey];
      }
    }
    setState(() {
      _todaysEarning = _vendorTodayData.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    var formatter = new DateFormat('dd-mm-yyyy');
    String formatted = formatter.format(_datetime);

    return Scaffold(
        body: Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              color: ThemeColors.primaryColor,
              height: (MediaQuery.of(context).size.height / 2) - 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text("Daily Earnings",
                          style: GoogleFonts.openSans(
                              letterSpacing: 1.5,
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(_currentDate,
                          style: GoogleFonts.openSans(
                              letterSpacing: 1.5,
                              fontSize: 12.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold))
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            FontAwesome.rupee,
                            color: Colors.white,
                            size: 30.0,
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            getWholeMoneyOfToday.toString(),
                            style: GoogleFonts.openSans(
                                letterSpacing: 1.5,
                                fontSize: 28.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            Divider(
              thickness: 1,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => TripDetails()));
              },
              child: Container(
                child: Column(
                  children: <Widget>[
                    Card(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 10),
                        width: _width - 20,
                        child: Column(
                          children: <Widget>[
                            Container(
                                color: Colors.green,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(_currentDate),
                                    ],
                                  ),
                                )),
                            SizedBox(height: 10),
                            if (_todaysEarning != null)
                              for (String keys in _todaysEarning.keys) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(keys),
                                        Text("₹ ${_todaysEarning[keys]}")
                                      ],
                                    ),
                                    Divider(
                                      color: Colors.black45,
                                    )
                                  ]),
                                )
                              ],
                            if (_todaysEarning == null)
                              Text("No Earning record !")
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: 5,
          top: 30,
          child: FlatButton(
              shape: CircleBorder(),
              padding: EdgeInsets.all(8.0),
              onPressed: () {
                showDatePicker(
                        context: context,
                        initialDate: _datetime,
                        firstDate: DateTime(2019),
                        lastDate: DateTime.now())
                    .then((date) {
                  if (date != null) {
                    setState(() {
                      _datetime = date;
                      _currentDate = "${date.day}-${date.month}-${date.year}";
                    });
                    getTodayEarning();
                  }
                });
              },
              child: Icon(
                FontAwesome.calendar,
                color: Colors.white,
                size: 25,
              )),
        ),
      ],
    ));
  }
}
