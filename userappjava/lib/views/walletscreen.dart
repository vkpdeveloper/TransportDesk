import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/AppLocalizations.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:rideapp/controllers/firebase_utils.dart';
import 'package:rideapp/model/tabviewmodel.dart';
import 'package:rideapp/providers/user_provider.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {

  final FirebaseUtils _utils = FirebaseUtils();

  int currentIndex = 0;

  int typedMoney = 0;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    UserPreferences userPreferences = Provider.of<UserPreferences>(context);
    final List<TabItem> allTabs = [
   TabItem(
        text: AppLocalizations.of(context).translate("History",),
        icon: Icon(
          FontAwesome.history,
          color: Colors.white,
        )),
    TabItem(
        text: AppLocalizations.of(context).translate("Help"),
        icon: Icon(
          FontAwesome.question_circle,
          color: Colors.white,
        ))
  ];
    return DefaultTabController(
      length: allTabs.length,
      child: Scaffold(
          body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              color: ThemeColors.primaryColor,
              height: (MediaQuery.of(context).size.height / 2) - 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(AppLocalizations.of(context).translate("Wallet"),
                      style: GoogleFonts.openSans(
                          letterSpacing: 1.5,
                          fontSize: 24.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        FontAwesome.rupee,
                        color: Colors.white,
                        size: 30.0,
                      ),
                      SizedBox(width: 5.0),
                      Text(
                        userPreferences.getWalletBalance.toString(),
                        style: GoogleFonts.openSans(
                            letterSpacing: 1.5,
                            fontSize: 28.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),
            new Container(
              width: MediaQuery.of(context).size.width,
              decoration:
                  new BoxDecoration(color: Theme.of(context).primaryColor),
              child: new TabBar(
                onTap: (value) {
                  setState(() {
                    currentIndex = value;
                  });
                },
                tabs: allTabs
                    .map(
                        (TabItem item) => Tab(text: item.text, icon: item.icon))
                    .toList(),
              ),
            ),
            if (currentIndex == 0)
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[Text(AppLocalizations.of(context).translate("History"))],
                  ),
                ),
              ),
            if (currentIndex == 1)
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[Text(AppLocalizations.of(context).translate("Help"))],
                  ),
                ),
              ),
          ],
        ),
      )),
    );
  }
}
