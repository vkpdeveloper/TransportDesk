import 'dart:async';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:driverapp/AppLocalizations.dart';
import 'package:driverapp/controllers/firebase_utils.dart';
import 'package:driverapp/providers/auth_provider.dart';
import 'package:driverapp/widgets/otp_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:driverapp/constants/themecolors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  FirebaseUtils _utils = FirebaseUtils();

  TextEditingController _pinEditingController = TextEditingController();

  String _username, _password;

  @override
  initState() {
    super.initState();
    AuthProvider().reset();
  }

  PinDecoration _pinDecoration = UnderlineDecoration(
      textStyle: TextStyle(color: Colors.white),
      color: Colors.white,
      enteredColor: Colors.white,
      hintText: '******',
      obscureStyle: ObscureStyle(isTextObscure: true));

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: ThemeColors.primaryColor,
        body: SingleChildScrollView(
          child: Container(
            height: _height,
            width: _width,
            child: Padding(
              padding: const EdgeInsets.only(right: 20, left: 20.0, top: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                      height: 200,
                      width: 200,
                      child: Image.asset("assets/images/newlogo.png")),
                  SizedBox(
                    height: _height / 5,
                  ),
                  if (!authProvider.getIsCodeSent)
                    Container(
                        width: (_width / 2) + 100,
                        child: Material(
                          elevation: 8.0,
                          color: Colors.white10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          shadowColor: ThemeColors.primaryColor,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                prefix: Text("+91"),
                                fillColor: ThemeColors.primaryColor,
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(20.0)),
                                hintStyle: TextStyle(color: Colors.white),
                                labelStyle: TextStyle(color: Colors.white),
                                labelText: AppLocalizations.of(context)
                                    .translate("Phone"),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0))),
                            onChanged: (val) {
                              setState(() {
                                _username = val;
                              });
                            },
                          ),
                        )),
                  SizedBox(
                    height: 10,
                  ),
                  if (authProvider.getIsCodeSent)
                    Container(
                        width: (_width / 2) + 100,
                        child: Material(
                          elevation: 8.0,
                          color: ThemeColors.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          shadowColor: Colors.black,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(14, 0, 14, 5),
                            child: PinInputTextField(
                              pinLength: 6,
                              decoration: _pinDecoration,
                              controller: _pinEditingController,
                              autoFocus: true,
                              textInputAction: TextInputAction.done,
                              onChanged: (pin) {
                                if (pin.length == 6) {
                                  setState(() {
                                    _password = pin;
                                  });
                                } else {}
                              },
                            ),
                          ),
                        )),
                  SizedBox(
                    height: 20,
                  ),
                  if (authProvider.getIsCodeSent)
                    ArgonButton(
                      height: 50,
                      roundLoadingShape: true,
                      width: MediaQuery.of(context).size.width * 0.6,
                      onTap: (startLoading, stopLoading, btnState) async {
                        if (btnState == ButtonState.Idle) {
                          startLoading();

                          if (_password.length == 6) {
                            authProvider.setSMSCode(_password);
                            try {
                              FirebaseUser _user =
                                  await _utils.loginWithOTP(authProvider);

                              if (_user.uid != null) {
                                Navigator.pushReplacementNamed(
                                    context, '/homescreen');
                              } else {
                                Fluttertoast.showToast(msg: "Login Failed");
                              }
                            } catch (e) {
                              print(e.toString());
                            }
                          } else {
                            Fluttertoast.showToast(msg: "Wrong OTP");
                          }
                        } else {
                          stopLoading();
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context).translate("Login"),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                      loader: Container(
                          padding: EdgeInsets.all(10),
                          child: SpinKitDualRing(color: Colors.white24)),
                      borderRadius: 5.0,
                      color: ThemeColors.yellowColor,
                    ),
                  if (!authProvider.getIsCodeSent)
                    Container(
                      child: ArgonButton(
                        color: ThemeColors.yellowColor,
                        height: 50,
                        roundLoadingShape: true,
                        borderRadius: 5.0,
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Center(
                            child: Text(
                          AppLocalizations.of(context).translate("Login"),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold),
                        )),
                        onTap: (startLoading, stopLoading, btnState) async {
                          if (btnState == ButtonState.Idle) {
                            authProvider.setPhoneNumber(_username);
                            try {
                              _utils.signInWithPhone(authProvider);
                            } catch (e) {
                              print(e.toString());
                            }
                          }
                        },
                        loader: Container(
                            padding: EdgeInsets.all(10),
                            child: SpinKitDualRing(color: Colors.white24)),
                      ),
                    ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/termsandcondition'),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "By logging in you Accept Terms and Conditions and",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/privacypolicy'),
                    child: Text(
                      "Privacy Policy",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
