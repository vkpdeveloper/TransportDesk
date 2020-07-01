import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:riderappweb/constants/themecolors.dart';
import 'package:riderappweb/providers/location_provider.dart';
import 'package:riderappweb/providers/order_provider.dart';
import 'package:riderappweb/providers/user_provider.dart';

import 'pages/homepage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LocationViewProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserPreferences(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Rider App",
        theme: ThemeData(
            textTheme: GoogleFonts.openSansTextTheme(),
            primaryColor: ThemeColors.primaryColor,
            accentColor: Colors.white),
        home: HomePage(),
      ),
    );
  }
}
