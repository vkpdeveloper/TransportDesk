import 'package:flutter/material.dart';
import 'package:rideapp/AppLocalizations.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:rideapp/controllers/firebase_utils.dart';
import 'package:rideapp/providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  final UserPreferences userPreferences;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseUtils _firebaseUtils = FirebaseUtils();

  ProfileScreen({Key key, this.userPreferences}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> modalRouteData =
        ModalRoute.of(context).settings.arguments;
    UserPreferences prefs = modalRouteData['pref'];
    if (_nameController.text == "" &&
        _emailController.text == "" &&
        _phoneController.text == "") {
      _nameController.text = prefs.getUserName;
      _emailController.text = prefs.getUserEmail;
      _phoneController.text = prefs.getUserPhone.replaceAll("+91", "");
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text(AppLocalizations.of(context).translate('profile')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  labelText: AppLocalizations.of(context).translate('Fullname'),
                ),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(
                height: 15.0,
              ),
              TextField(
                controller: _phoneController,
                maxLength: 10,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  labelText: AppLocalizations.of(context).translate('Phone number'),
                ),
                textInputAction: TextInputAction.next,
              ),
              SizedBox(
                height: 15.0,
              ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  labelText: AppLocalizations.of(context).translate('Email'),
                ),
                textInputAction: TextInputAction.next,
                
              ),
              SizedBox(height: 20.0),
              MaterialButton(
                  height: 40.0,
                  minWidth: MediaQuery.of(context).size.width - 20,
                  child: Text(
                    AppLocalizations.of(context).translate('Update'),
                    style: TextStyle(fontSize: 16.0),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  textColor: Colors.white,
                  color: ThemeColors.primaryColor,
                  onPressed: () => _firebaseUtils.updateProfile(
                      _nameController.text,
                      _phoneController.text,
                      _emailController.text,
                      prefs, context))
            ],
          ),
        ),
      ),
    );
  }
}
