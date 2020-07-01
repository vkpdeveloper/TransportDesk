import 'package:driverapp/AppLocalizations.dart';
import 'package:driverapp/providers/auth_provider.dart';
import 'package:driverapp/providers/signup_provider.dart';
import 'package:driverapp/providers/user_sharedpref_provider.dart';
import 'package:driverapp/views/bookings.dart';
import 'package:driverapp/views/chatscreen.dart';
import 'package:driverapp/views/docs/aboutus.dart';
import 'package:driverapp/views/docs/privacy_policy.dart';
import 'package:driverapp/views/docs/terms&conditions.dart';
import 'package:driverapp/views/notifications.dart';
import 'package:driverapp/views/profilescreen.dart';
import 'package:driverapp/views/referral.dart';
import 'package:driverapp/views/ridesscreen.dart';
import 'package:driverapp/views/signup/Verification.dart';
import 'package:driverapp/views/walletscreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:driverapp/constants/themecolors.dart';
import 'package:driverapp/providers/locationViewProvider.dart';
import 'package:driverapp/providers/order_provider.dart';
import 'package:driverapp/services/firebase_auth_service.dart';
import 'package:driverapp/services/image_picker_service.dart';
import 'package:driverapp/views/homescreen.dart';
import 'package:driverapp/views/loginscreen.dart';
import 'package:driverapp/views/splashscreen.dart';
import 'package:driverapp/views/signup/driver_details.dart';
import 'package:path_provider/path_provider.dart' as path;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      var box = await Hive.openBox('notification');
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
          ChangeNotifierProvider(
            create: (context) => OrderProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => UserPreferences(),
          ),
          ChangeNotifierProvider(
            create: (context) => SignUpProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => AuthProvider(),
          ),
          Provider<FirebaseAuthService>(
            create: (_) => FirebaseAuthService(),
          ),
          Provider<ImagePickerService>(
            create: (_) => ImagePickerService(),
          ),
        ],
        child: MaterialApp(
          //     locale: DevicePreview.of(context).locale, // <--- Add the locale
          // builder: DevicePreview.appBuilder,
          debugShowCheckedModeBanner: false,
          title: "Ride App",
          initialRoute: '/',
          supportedLocales: [
            const Locale('en', 'US'), // English, no country code
            const Locale('hi', 'IN'),
          ],
          routes: {
            '/loginscreen': (context) => LoginScreen(),
            '/homescreen': (context) => VerificationCheck(),
            '/signup': (context) => DriverDetails(),
            '/walletscreen': (context) => WalletScreen(),
            '/ridesscreen': (context) => RidesScreen(),
            '/profilescreen': (context) => Profile(),
            '/verification': (cotext) => Verification(),
            '/bookings': (context) => Bookings(),
            '/chat': (context) => ChatScreen(),
            '/referral': (context) => ReferralScreen(),
            '/notification': (context) => Notifications(),
            '/aboutus': (context) => AboutUs(),
            '/termsandcondition': (context) => TermsAndConditions(),
            '/privacypolicy': (context) => PrivacyPolicy(),
          },
          localizationsDelegates: [
            // THIS CLASS WILL BE ADDED LATER
            // A class which loads the translations from JSON files
            AppLocalizations.delegate,
            // Built-in localization of basic text for Material widgets
            GlobalMaterialLocalizations.delegate,
            // Built-in localization for text direction LTR/RTL
            GlobalWidgetsLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            // Check if the current device locale is supported
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode &&
                  supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
            // If the locale of the device is not supported, use the first one
            // from the list (English, in this case).
            return supportedLocales.first;
          },
          theme: ThemeData(
              textTheme: GoogleFonts.openSansTextTheme(),
              primaryColor: ThemeColors.primaryColor,
              accentColor: Colors.white),
          home: SplashScreen(),
        ));
  }
}
