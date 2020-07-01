import 'package:adminappweb/const/themecolors.dart';
import 'package:flutter/material.dart';

class StaticUtils {
  void showSnackBar(String content, GlobalKey<ScaffoldState> scaffoldState) {
    SnackBar snackBar = SnackBar(
      content: Text(
        content,
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 2),
      backgroundColor: ThemeColors.primaryColor,
    );
    scaffoldState.currentState.showSnackBar(snackBar);
  }
}
