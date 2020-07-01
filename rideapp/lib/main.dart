
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:rideapp/providers/locationViewProvider.dart';
import 'package:rideapp/providers/orderprovider.dart';
import 'package:rideapp/providers/user_provider.dart';
import 'package:rideapp/services/firebase_auth_service.dart';
import 'package:rideapp/services/image_picker_service.dart';
import 'package:rideapp/views/allbookings_screen.dart';
import 'package:rideapp/views/customerdetails.dart';
import 'package:rideapp/views/homescreen.dart';
import 'package:rideapp/views/loginscreen.dart';
import 'package:rideapp/views/notifications.dart';
import 'package:rideapp/views/orderdetailsscreen.dart';
import 'package:rideapp/views/saveaddress_screen.dart';
import 'package:rideapp/views/splashscreen.dart';
import 'package:rideapp/views/supportscreen.dart';
import 'package:rideapp/views/walletscreen.dart';
import 'package:rideapp/views/profile_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
          routes: {
            '/loginscreen': (context) => LoginScreen(),
            '/homescreen': (context) => HomeScreen(),
            '/customerscreen': (context) => CustomerDetails(),
            '/walletscreen': (context) => WalletScreen(),
            '/savedaddressscreen': (context) => SavedAddress(),
            '/allordersscreen': (context) => AllBookings(),
            '/orderdetailsscreen': (context) => OrderDetailsScreen(),
            '/profile': (context) => ProfileScreen(),
            '/notifications':(context)=> Notifications(),
            '/support': (context)=> SupportScreen(),
          },
          theme: ThemeData(
              textTheme: GoogleFonts.openSansTextTheme(),
              primaryColor: ThemeColors.primaryColor,
              accentColor: Colors.white),
          home: SplashScreen()));
        
  }
}