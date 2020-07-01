import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/AppLocalizations.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:rideapp/providers/locationViewProvider.dart';
import 'package:rideapp/providers/orderprovider.dart';
import 'package:rideapp/providers/payment_provider.dart';
import 'package:rideapp/providers/user_provider.dart';
import 'package:rideapp/services/firebase_auth_service.dart';
import 'package:rideapp/services/image_picker_service.dart';
import 'package:rideapp/views/allbookings_screen.dart';
import 'package:rideapp/views/customerdetails.dart';
import 'package:rideapp/views/docs/aboutus.dart';
import 'package:rideapp/views/docs/privacy_policy.dart';
import 'package:rideapp/views/docs/terms&conditions.dart';
import 'package:rideapp/views/homescreen.dart';
import 'package:rideapp/views/loginscreen.dart';
import 'package:rideapp/views/notifications.dart';
import 'package:rideapp/views/orderdetailsscreen.dart';
import 'package:rideapp/views/saveaddress_screen.dart';
import 'package:rideapp/views/splashscreen.dart';
import 'package:rideapp/views/supportscreen.dart';
import 'package:rideapp/views/suspended_view.dart';
import 'package:rideapp/views/walletscreen.dart';
import 'package:rideapp/views/profile_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rideapp/views/weblogin.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    openData();
    _firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      addToDatabase(message);
    }, onResume: (data) {
      addToDatabaseFromResume(data);
    });
    super.initState();
  }

  openData() async {
    path.getApplicationDocumentsDirectory().then((value) async {
      Hive.init(value.path);
      //var box = await Hive.openBox('notification');
    });
  }

  addToDatabase(Map<String, dynamic> data) async {
    print(data);
    var box = await Hive.openBox('notification');
    box.put(box.length + 1,
        [data['notification']['title'].toString(), data['notification']['body'].toString()]);
  }

  addToDatabaseFromResume(Map<String, dynamic> data) async {
    print(data);
    var box = await Hive.openBox('notification');
    box.put(box.length + 1, [data['data']['title'].toString(), data['data']['body'].toString()]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => LocationViewProvider()),
          ChangeNotifierProvider(create: (context) => PaymentProvider()),
          ChangeNotifierProvider(
            create: (context) => OrderProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => UserPreferences(),
          ),
          Provider<FirebaseAuthService>(
            create: (_) => FirebaseAuthService(),
          ),
          Provider<ImagePickerService>(
            create: (_) => ImagePickerService(),
          ),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Ride App",
            initialRoute: '/',
            supportedLocales: [
              const Locale('en', 'US'), // English, no country code
              const Locale('hi', 'IN'),
            ],
            routes: {
              '/loginscreen': (context) => LoginScreen(),
              '/homescreen': (context) => HomeScreen(),
              '/customerscreen': (context) => CustomerDetails(),
              '/walletscreen': (context) => WalletScreen(),
              '/savedaddressscreen': (context) => SavedAddress(),
              '/allordersscreen': (context) => AllBookings(),
              '/orderdetailsscreen': (context) => OrderDetailsScreen(),
              '/profile': (context) => ProfileScreen(),
              '/notifications': (context) => Notifications(),
              '/support': (context) => SupportScreen(),
              '/suspension': (context) => SuspendedScreen(),
              '/aboutus': (context) => AboutUs(),
              '/tandc': (context) => TermsAndConditions(),
              '/privacypolicy': (context) => PrivacyPolicy(),
              '/weblogin': (context) => WebLogin(),
            },
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode &&
                    supportedLocale.countryCode == locale.countryCode) {
                  return supportedLocale;
                }
              }

              return supportedLocales.first;
            },
            theme: ThemeData(
                textTheme: GoogleFonts.openSansTextTheme(),
                primaryColor: ThemeColors.primaryColor,
                accentColor: Colors.white),
            home: SplashScreen()));
  }
}
