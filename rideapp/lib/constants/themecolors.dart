import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

mixin ThemeColors {
  static Color primaryColor = Color(0xFF012060);
 // Color(0xFFD86F13);
  static Color yellowColor = Color(0xFFD86F13);
  static Color darkblueColor = Color(0xFF012060);
  static Color lightblueColor = Color(0xFF00A8F3);
  
}


final maintheme = ThemeData(
  primarySwatch: yellowdarkcolor,
  primaryColor: yellowdarkcolor,
  

  brightness: Brightness.light,
  backgroundColor: Colors.white,
  
  accentColor: Colors.white,
  textTheme: GoogleFonts.openSansTextTheme(),
  buttonTheme: ButtonThemeData(
    buttonColor: yellowdarkcolor
  ),
  iconTheme: IconThemeData(color: yellowdarkcolor)
);


MaterialColor yellowdarkcolor = MaterialColor(0xFFD86F13, color);

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}


Map<int, Color> color = {
  50: Color.fromRGBO(216, 83, 11, .1),
  100: Color.fromRGBO(216, 83, 11, .2),
  200: Color.fromRGBO(216, 83, 11, .3),
  300: Color.fromRGBO(216, 83, 11, .4),
  400: Color.fromRGBO(216, 83, 11, .5),
  500: Color.fromRGBO(216, 83, 11, .6),
  600: Color.fromRGBO(216, 83, 11, .7),
  700: Color.fromRGBO(216, 83, 11, .8),
  800: Color.fromRGBO(216, 83, 11, .9),
  900: Color.fromRGBO(216, 83, 11, 1),
};

