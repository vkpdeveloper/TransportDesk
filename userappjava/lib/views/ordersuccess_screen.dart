import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:rideapp/AppLocalizations.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/providers/orderprovider.dart';

class OrderSuccessful extends StatelessWidget {
  final String orderID;

  const OrderSuccessful({Key key, this.orderID}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    OrderProvider orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Center(
                child: Container(
                  height: 200.0,
                  width: MediaQuery.of(context).size.width - 80,
                  child: FlareActor(
                    "asset/success.flr",
                    alignment: Alignment.center,
                    animation: "Animate",
                    fit: BoxFit.fitWidth,
                    callback: (name) {
                      print(name);
                    },
                  ),
                ),
              ),
            ),
            Text(
              AppLocalizations.of(context).translate("ORDER SUCCESSFUL"),
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.green),
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context).translate("ORDER ID"),
                  style: TextStyle(
                      color: ThemeColors.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  orderID,
                  style: TextStyle(
                      color: ThemeColors.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context).translate("RECEIVER NAME"),
                  style: TextStyle(
                      color: ThemeColors.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  orderProvider.getReceiverName,
                  style: TextStyle(
                      color: ThemeColors.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context).translate("TRUCK"),
                  style: TextStyle(
                      color: ThemeColors.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  orderProvider.getTruckName,
                  style: TextStyle(
                      color: ThemeColors.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context).translate("PRICE"),
                  style: TextStyle(
                      color: ThemeColors.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  orderProvider.getOrderPrice.toString(),
                  style: TextStyle(
                      color: ThemeColors.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListTile(
                title: Text(
                  AppLocalizations.of(context).translate("PAYMENT METHOD"),
                  style: TextStyle(
                      color: ThemeColors.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  orderProvider.getSelectedPaymentMethod == 0
                      ? "Paytm"
                      : "Card",
                  style: TextStyle(
                      color: ThemeColors.primaryColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            FloatingActionButton.extended(
                elevation: 8,
                highlightElevation: 12.0,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                hoverElevation: 12.0,
                icon: Icon(Icons.location_on),
                onPressed: () =>
                    Navigator.pushNamed(context, '/allordersscreen'),
                foregroundColor: Colors.white,
                backgroundColor: ThemeColors.primaryColor,
                label: Text("All ORDERS")),
            SizedBox(
              height: 40.0,
            ),
          ],
        ),
      ),
    );
  }
}
