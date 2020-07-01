import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driverapp/AppLocalizations.dart';
import 'package:driverapp/controllers/firebase_utils.dart';
import 'package:driverapp/controllers/static_utils.dart';
import 'package:driverapp/providers/user_sharedpref_provider.dart';
import 'package:driverapp/views/tripdetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driverapp/constants/themecolors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  DateTime _datetime = DateTime.now();
  String _currentDate;
  QuerySnapshot _todaysEarning;
  FirebaseUtils _utils = FirebaseUtils();
  int getWholeMoneyOfToday = 0;
  UserPreferences userPreferences;

  @override
  void initState() {
    super.initState();
    _currentDate = "${_datetime.day}-${_datetime.month}-${_datetime.year}";
    getTodayEarning();
  }

  getTodayEarning() async {
    getWholeMoneyOfToday = 0;
    QuerySnapshot _vendorTodayData = await Firestore.instance
        .collection('vendor')
        .document(await _utils.getuserphoneno())
        .collection(_currentDate)
        .getDocuments();
    setState(() {
      _todaysEarning = _vendorTodayData;
    });
    _vendorTodayData.documents.forEach((DocumentSnapshot snapshot) {
      getWholeMoneyOfToday += snapshot.data['driverEarning'];
    });
  }

  StaticUtils _staticUtils = StaticUtils();

  @override
  Widget build(BuildContext context) {
    // double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    var formatter = new DateFormat('dd-mm-yyyy');
    userPreferences = Provider.of<UserPreferences>(context);

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
                      Text(
                          AppLocalizations.of(context)
                              .translate("Daily Earnings"),
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
            Container(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[Text("Trip Earning"), Text("₹ 8000")],
                    ),
                    Column(
                      children: <Widget>[Text("Incentive"), Text("₹ 500")],
                    ),
                    Column(
                      children: <Widget>[Text("Panelty"), Text("₹ 300")],
                    ),
                    Column(
                      children: <Widget>[Text("Surcharge"), Text("₹ 1000")],
                    )
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 1,
            ),
            StreamBuilder(
              stream: Firestore.instance
                  .collection('vendor')
                  .document(userPreferences.getUserPhone)
                  .collection(_currentDate)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> allSnapshots) {
                if (allSnapshots.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Expanded(
                    child: ListView(
                      children: allSnapshots.data.documents
                          .map((snapshot) => _buildOrderDetails(snapshot))
                          .toList(),
                    ),
                  );
                }
              },
            )
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

  Widget _buildOrderDetails(DocumentSnapshot snapshot) {
    int price = snapshot.data['totalFare'];
    int driverEarning = price - _staticUtils.comission(price, 30);
    int previousCharge = snapshot.data['previousCharge'];
    int tripFare = price - previousCharge;
    int comission = _staticUtils.comission(price, 30);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              color: Colors.blue,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(price.toString()),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Trip Fare"),
                      Text("₹ $price"),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Previous Charges"),
                      Text("₹ $previousCharge"),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Trip Earning"),
                      Text("₹ $driverEarning"),
                    ],
                  ),
                  SizedBox(height: 10),
                  ExpansionTile(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width - 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Trip Fare: ₹ $tripFare"),
                            Text("Less: - "),
                            Text("Comission Payable: ₹ $comission"),
                            Text("GST 18% : "),
                            Text("Trip Earning :")
                          ],
                        ),
                      ),
                    ],
                    title: Text(
                      "Trip Details *",
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
      ]),
    );
  }
}
