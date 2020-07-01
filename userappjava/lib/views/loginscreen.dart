import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rideapp/AppLocalizations.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:rideapp/controllers/firebase_utils.dart';
import 'package:rideapp/widgets/otp_input.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  FirebaseUtils _utils = FirebaseUtils();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TextEditingController _pinEditingController = TextEditingController();

  Future<FirebaseUser> signIn(AuthCredential authCreds) async {
    try {
      AuthResult result = await _firebaseAuth.signInWithCredential(authCreds);
      return result.user;
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid OTP Code");
      return null;
    }
  }

  signInWithOTP(smsCode, verId) async {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(
        verificationId: verId, smsCode: smsCode);

    FirebaseUser _user = await signIn(authCreds);

    if (_user != null) {
      print(_user.uid);
      if (await _utils.isUserExist()) {
        Navigator.pushReplacementNamed(context, '/homescreen');
      } else {
        Navigator.pushReplacementNamed(context, '/customerscreen');
      }
      // Navigator.pushReplacementNamed(context, '/customerscreen');
    }
  }

  FirebaseMessaging _messaging = FirebaseMessaging();

  Future<void> verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified =
        (AuthCredential authResult) async {
      FirebaseUser _user = await signIn(authResult);
      if (_user != null) {
        //  _utils.isUserSuspended();
        if (await _utils.isUserExist()) {
          Navigator.pushReplacementNamed(context, '/homescreen');
        } else {
          Navigator.pushReplacementNamed(context, '/customerscreen');
        }
      }
    };

    final PhoneVerificationFailed verificationfailed =
        (AuthException authException) {
      print('${authException.message}');
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.codeSent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 60),
        verificationCompleted: verified,
        verificationFailed: verificationfailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }

  Future<void> googleSignIn() async {
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    AuthResult result = (await _auth.signInWithCredential(credential));
    assert(result.user.uid != null);
    _user = result.user;
    print(_user.uid);
    _utils.saveGoogleLoginData();
    if (await _utils.isUserExist()) {
      Navigator.pushReplacementNamed(context, '/homescreen');
    } else {
      Navigator.pushReplacementNamed(context, '/customerscreen');
    }
  }

  GoogleSignIn _googleSignIn = GoogleSignIn();

  String phoneNo, verificationId, smsCode;

  bool codeSent = false;

  PinDecoration _pinDecoration = UnderlineDecoration(
      textStyle: TextStyle(color: Colors.white),
      color: Colors.white,
      enteredColor: Colors.white,
      hintText: '666666',
      obscureStyle: ObscureStyle(isTextObscure: true));

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: _height,
          width: _width,
          child: ListView(
            children: <Widget>[
              Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Container(
                    width: _width,
                    height: _height / 1.8,
                    child: Center(
                        child: Container(
                      height: 220,
                      width: 220,
                      child: Image.asset('asset/images/newlogo.png'),
                    )),
                    decoration: BoxDecoration(color: ThemeColors.primaryColor),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 30,
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)
                            .translate("Login Using Phone Number"),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                      ),
                    ),
                  ),
                  codeSent
                      ? Container()
                      : Positioned(
                          child: Container(
                              width: (_width / 2) + 100,
                              child: Material(
                                elevation: 15.0,
                                color: Colors.white10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                shadowColor: ThemeColors.primaryColor,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                      prefix: Text(
                                        "+91  ",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      fillColor: ThemeColors.primaryColor,
                                      filled: true,
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(20.0)),
                                      hintStyle: TextStyle(color: Colors.white),
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                      labelText: AppLocalizations.of(context)
                                          .translate("Enter Phone Number"),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0))),
                                  onChanged: (val) {
                                    setState(() {
                                      this.phoneNo = "+91$val";
                                      print(phoneNo);
                                    });
                                  },
                                ),
                              )),
                          bottom: -23,
                          left: 50,
                          right: 50,
                        ),
                  codeSent
                      ? Positioned(
                          child: Container(
                              width: (_width / 2) + 100,
                              child: Material(
                                elevation: 15.0,
                                color: ThemeColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                shadowColor: ThemeColors.primaryColor,
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
                                          this.smsCode = pin;
                                          print(smsCode);
                                        });
                                      } else {}
                                    },
                                  ),
                                ),
                              )),
                          bottom: -23,
                          left: 50,
                          right: 50,
                        )
                      : Container(),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          codeSent
                              ? ArgonButton(
                                  height: 50,
                                  roundLoadingShape: true,
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  onTap: (startLoading, stopLoading, btnState) {
                                    if (btnState == ButtonState.Idle) {
                                      startLoading();
                                      signInWithOTP(smsCode, verificationId);
                                    } else {
                                      stopLoading();
                                    }
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("Login"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  loader: Container(
                                      padding: EdgeInsets.all(10),
                                      child: SpinKitDualRing(
                                          color: Colors.white24)),
                                  borderRadius: 5.0,
                                  color: Colors.blue,
                                )
                              : Container(),
                          codeSent
                              ? Container()
                              : ArgonButton(
                                  height: 50,
                                  roundLoadingShape: true,
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  onTap: (startLoading, stopLoading, btnState) {
                                    if (btnState == ButtonState.Idle) {
                                      startLoading();
                                      verifyPhone(phoneNo);
                                    } else {
                                      stopLoading();
                                    }
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("Get OTP"),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  loader: Container(
                                      padding: EdgeInsets.all(10),
                                      child: SpinKitDualRing(
                                          color: Colors.white24)),
                                  borderRadius: 5.0,
                                  color: Colors.blue,
                                )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: RichText(
                        text: TextSpan(
                            text: "Or",
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.primaryColor)),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ArgonButton(
                      height: 50,
                      roundLoadingShape: true,
                      width: MediaQuery.of(context).size.width * 0.6,
                      onTap: (startLoading, stopLoading, btnState) {
                        if (btnState == ButtonState.Idle) {
                          startLoading();
                          googleSignIn();
                        } else {
                          stopLoading();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            AntDesign.google,
                            color: Colors.white,
                            size: 25.0,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            "Google",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      loader: Container(
                          padding: EdgeInsets.all(10),
                          child: SpinKitDualRing(color: Colors.white24)),
                      borderRadius: 5.0,
                      color: Colors.red,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ArgonButton(
                      height: 50,
                      roundLoadingShape: true,
                      width: MediaQuery.of(context).size.width * 0.6,
                      onTap: (startLoading, stopLoading, btnState) {
                        if (btnState == ButtonState.Idle) {
                          startLoading();
                        } else {
                          stopLoading();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            FontAwesome.facebook,
                            color: Colors.white,
                            size: 25.0,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            "Facebook",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      loader: Container(
                          padding: EdgeInsets.all(10),
                          child: SpinKitDualRing(color: Colors.white24)),
                      borderRadius: 5.0,
                      color: Colors.blue,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/tandc'),
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
                      onTap: () =>
                          Navigator.pushNamed(context, '/privacypolicy'),
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
            ],
          ),
        ),
      ),
    );
  }
}
