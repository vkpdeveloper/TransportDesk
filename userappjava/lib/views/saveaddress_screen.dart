import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/AppLocalizations.dart';
import 'package:rideapp/constants/apikeys.dart';
import 'package:rideapp/constants/themecolors.dart';
import 'package:rideapp/providers/locationViewProvider.dart';
import 'package:rideapp/providers/user_provider.dart';

class SavedAddress extends StatefulWidget {
  final bool isFromHome;
  final TextEditingController mainController;

  const SavedAddress({Key key, this.isFromHome, this.mainController})
      : super(key: key);
  @override
  _SavedAddressState createState() => _SavedAddressState();
}

class _SavedAddressState extends State<SavedAddress> {
  final addressController = TextEditingController();

  int _maxLines = 1;
  bool _isFromHome = false;

  @override
  void initState() {
    super.initState();
    if (widget.isFromHome == null) {
      _isFromHome = false;
    } else {
      _isFromHome = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    UserPreferences userPreferences = Provider.of<UserPreferences>(context);
    LocationViewProvider locationViewProvider =
        Provider.of<LocationViewProvider>(context);

    String address = "";
    LatLng latLng;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              if (_maxLines == 1) {
                setState(() {
                  _maxLines = 5;
                });
              } else {
                setState(() {
                  _maxLines = 1;
                });
              }
            },
            child: _maxLines == 1
                ? Text(
                    AppLocalizations.of(context).translate("Full"),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )
                : Text(
                    AppLocalizations.of(context).translate("Hide"),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
            textColor: Colors.white,
          ),
          IconButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) {
                    LocationViewProvider provider =
                        Provider.of<LocationViewProvider>(context);
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      title: Text(AppLocalizations.of(context)
                          .translate("Add New Address")),
                      contentPadding: const EdgeInsets.all(15),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: addressController,
                            readOnly: true,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(10.0),
                                hintText: AppLocalizations.of(context)
                                    .translate("Address"),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.0)),
                                prefixIcon: IconButton(
                                  onPressed: () async {
                                    LocationResult result =
                                        await showLocationPicker(
                                            context, APIKeys.googleMapsAPI,
                                            appBarColor:
                                                ThemeColors.primaryColor,
                                            hintText: AppLocalizations.of(
                                                    context)
                                                .translate("Enter Location"),
                                            automaticallyAnimateToCurrentLocation:
                                                true,
                                            layersButtonEnabled: true,
                                            myLocationButtonEnabled: true,
                                            requiredGPS: true);
                                    address = result.address;
                                    latLng = result.latLng;
                                    addressController.text = address;
                                  },
                                  color: ThemeColors.primaryColor,
                                  icon: Icon(Icons.location_on),
                                )),
                          ),
                          SizedBox(height: 20),
                          MaterialButton(
                            onPressed: () {
                              Firestore.instance
                                  .collection('user')
                                  .document(userPreferences.getUserID)
                                  .collection('address')
                                  .add({
                                "address": address,
                                "latlng": [latLng.latitude, latLng.longitude]
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text(AppLocalizations.of(context)
                                .translate("SAVE ADDRESS")),
                            textColor: Colors.white,
                            minWidth: MediaQuery.of(context).size.width - 30,
                            height: 40,
                            color: ThemeColors.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                          )
                        ],
                      ),
                    );
                  }),
              icon: Icon(Icons.add),
              color: Colors.white),
        ],
        backgroundColor: ThemeColors.primaryColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text(AppLocalizations.of(context).translate("Saved Address")),
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('user')
            .document(userPreferences.getUserID)
            .collection('address')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
                child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor),
            ));
          else {
            if (snapshot.data.documents.length == 0)
              return Center(
                  child: Text(AppLocalizations.of(context)
                      .translate("No Saved Address !")));
            else {
              return ListView(
                children:
                    snapshot.data.documents.map((DocumentSnapshot address) {
                  return ListTile(
                    onTap: _isFromHome
                        ? () {
                            locationViewProvider
                                .setAddress(address.data['address']);
                            LatLng latlng = LatLng(address.data['latlng'][0],
                                address.data['latlng'][1]);
                            widget.mainController.text =
                                address.data['address'];
                            locationViewProvider.setDestinationLatLng(latlng);
                            Navigator.of(context).pop();
                          }
                        : null,
                    leading: Icon(Icons.location_on),
                    title: Text(
                      address.data['address'],
                      maxLines: _maxLines,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                    trailing: IconButton(
                      onPressed: () => Firestore.instance
                          .collection('user')
                          .document(userPreferences.getUserID)
                          .collection('address')
                          .document(address.documentID)
                          .delete(),
                      icon: Icon(Icons.delete),
                      color: ThemeColors.primaryColor,
                    ),
                  );
                }).toList(),
              );
            }
          }
        },
      ),
    );
  }
}
