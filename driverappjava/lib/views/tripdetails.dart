import 'package:flutter/material.dart';

class TripDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    //double _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Trip Details"),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.black26,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 10),
                    Icon(Icons.map),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("CRN453534543543534"),
                        Text(
                          "TimeStamp",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.blue,
              height: _height / 3,
              child: Center(
                child: Text("Show Map Details for trip"),
              ),
            ),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.location_on,
                        color: Colors.green,
                      ),
                      Text("ride Start address")
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                      ),
                      Text("ride Stop address")
                    ],
                  ),
                ),
                const Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        const Text("Trip Distance"),
                        Text("100 km",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    VerticalDivider(
                      thickness: 1,
                    ),
                    Column(
                      children: <Widget>[
                        const Text("Trip Time"),
                        Text("120 min",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    VerticalDivider(
                      color: Colors.blue,
                      thickness: 1,
                    ),
                    Column(
                      children: <Widget>[
                        const Text("Dry Run Distance"),
                        Text("2 to 5 km",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: <Widget>[
                      const Text("Earning Details"),
                      Divider(
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Total Earning (including extra ₹50)'),
                          Row(
                            children: <Widget>[
                              Text("₹ 500"),
                              Icon(Icons.arrow_forward)
                            ],
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Cash Collected'),
                          Text('₹ 320'),
                        ],
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Your Payout'),
                          Text('₹ 200'),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
