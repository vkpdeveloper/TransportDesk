import 'package:driverapp/AppLocalizations.dart';
import 'package:driverapp/constants/themecolors.dart';
import 'package:driverapp/providers/user_sharedpref_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
  }

  UserPreferences userPreferences;

  @override
  Widget build(BuildContext context) {
    UserPreferences user = Provider.of<UserPreferences>(context);
    String userName = user.getUserName;
    String userPhone = user.getUserPhone;
    String userProfileUrl = user.getProfile;
    String vehicleName = user.getVehicleName;
    String vehicleNumber = user.getVehicleNumber;
    double rating = user.getRating;
    String referral = user.getReferral;
    userPreferences = Provider.of<UserPreferences>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      backgroundColor: Colors.blue[300],
      body: SafeArea(
          child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      userName ?? AppLocalizations.of(context).translate("loading..."),
                      style: TextStyle(fontSize: 25, color: Colors.black),
                    ),
                    Text("$vehicleName | $vehicleNumber")
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(userProfileUrl),
                        backgroundColor: ThemeColors.primaryColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: SmoothStarRating(
                            allowHalfRating: false,
                            onRated: (v) {},
                            starCount: 5,
                            rating: rating,
                            size: 25.0,
                            isReadOnly: true,
                            color: Colors.yellow,
                            borderColor: Colors.yellow,
                            spacing: 0.0),
                      ),
                      Text(
                        rating.toString(),
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        userPhone.toString(),
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    AppLocalizations.of(context).translate("Your Raferral Id"),
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.yellow[300], borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                        child: SelectableText(
                          referral,
                          style: TextStyle(fontSize: 30),
                        ),
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(
                            Icons.share,
                            size: 40,
                          ),
                          onPressed: () => WcFlutterShare.share(
                              sharePopupTitle: AppLocalizations.of(context).translate("Share"),
                              mimeType: "text/plain",
                              text:
                                  "Hey, try this app for earning money by driving trucks. Use my Referral code to get promotions. REFERRAL CODE $referral")),
                    ],
                  )
                ],
              ),
            ],
          ),
        ],
      )),
    );
  }
}
