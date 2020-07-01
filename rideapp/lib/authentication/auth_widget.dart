// import 'package:rideapp/views/homescreen.dart';
// import 'package:rideapp/views/loginscreen.dart';
// import 'package:rideapp/services/firebase_auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:rideapp/views/splashscreen.dart';

// /// Builds the signed-in or non signed-in UI, depending on the user snapshot.
// /// This widget should be below the [MaterialApp].
// /// An [AuthWidgetBuilder] ancestor is required for this widget to work.
// class AuthWidget extends StatelessWidget {
//   const AuthWidget({Key key, @required this.userSnapshot}) : super(key: key);
//   final AsyncSnapshot<User> userSnapshot;

//   @override
//   Widget build(BuildContext context) {
//     bool loggedin;
//     if (userSnapshot.connectionState == ConnectionState.active) {
//       loggedin = true;

//       return userSnapshot.hasData ? SplashScreen(loggedin: loggedin): SplashScreen(loggedin: !loggedin);
//     }return Container();
//   }
// }
