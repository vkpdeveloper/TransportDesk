import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthProvider with ChangeNotifier {
  String _verificationID;
  String _smsCode;
  AuthException _error;
  String _phoneNumber;
  FirebaseUser _user;
  bool _isCodeSent;

  AuthProvider() {
    _verificationID = "";
    _smsCode = "";
    _phoneNumber = "";
    _isCodeSent = false;
  }

  String get smsCode => _smsCode;
  String get verificationID => _verificationID;
  AuthException get error => _error;
  String get phoneNumber => _phoneNumber;
  FirebaseUser get user => _user;
  bool get getIsCodeSent => _isCodeSent;

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  void setIsCodeSent(bool isSent) {
    _isCodeSent = isSent;
    notifyListeners();
  }

  void setVerificationID(String id) {
    _verificationID = id;
    notifyListeners();
  }

  void setError(AuthException error) {
    _error = error;
    notifyListeners();
    throw AuthException(_error.message, _error.code);
  }

  void setSMSCode(String code) {
    _smsCode = code;
    notifyListeners();
  }

  void setUser(FirebaseUser user) {
    _user = user;
    notifyListeners();
  }
}
