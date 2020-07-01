import 'package:driverapp/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';

class ReferralScreen extends StatefulWidget {
  @override
  _ReferralScreenState createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  //MethodChannel _myChannel = MethodChannel("com.transportdesk.vendor/share");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate("Referral"))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).translate("Your Raferral Id"),
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
                decoration: BoxDecoration(
                    color: Colors.yellow[300],
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 8.0),
                  child: SelectableText(
                    "JK3657",
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
                        sharePopupTitle:
                            AppLocalizations.of(context).translate("Share"),
                        mimeType: "text/plain",
                        text:
                            "Hey, try this app for earning money by driving trucks. Use my Referral code to get promotions. REFERRAL CODE GJH76576")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
