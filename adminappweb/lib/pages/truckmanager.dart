import 'package:adminappweb/const/themecolors.dart';
import 'package:adminappweb/controllers/firebase_utils.dart';
import 'package:adminappweb/provider/truckEditingProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TruckManager extends StatefulWidget {
  @override
  _TruckManagerState createState() => _TruckManagerState();
}

class _TruckManagerState extends State<TruckManager> {
  FirebaseUtils _utils = FirebaseUtils();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _truckNameController = TextEditingController();
  TextEditingController _truckCapacityController = TextEditingController();
  TextEditingController _truckPriceFactorController = TextEditingController();
  TextEditingController _truckDimensionController = TextEditingController();
  TextEditingController _truckImageURLController = TextEditingController();

  editDialog(Map<String, dynamic> data, String documentID) {
    return showDialog(
        context: _scaffoldKey.currentContext,
        barrierDismissible: true,
        builder: (context) {
          TruckEditingProvider truckEditingProvider =
              Provider.of<TruckEditingProvider>(context);
          truckEditingProvider.setCategory(data['category']);
          _truckNameController.text = data['name'];
          _truckCapacityController.text = data['capacity'];
          _truckPriceFactorController.text = data['priceFactor'].toString();
          _truckDimensionController.text = data['dimension'];
          return AlertDialog(
            actions: [
              FlatButton(
                onPressed: () =>
                    Navigator.of(_scaffoldKey.currentContext).pop(),
                child: Text("Close"),
              ),
              FlatButton(
                onPressed: () => Firestore.instance
                    .collection('trucks')
                    .document(documentID)
                    .updateData({
                  "category": truckEditingProvider.getSelectedCategoty,
                  "name": _truckNameController.text,
                  "capacity": _truckCapacityController.text,
                  "dimension": _truckDimensionController.text,
                  "priceFactor": _truckPriceFactorController.text
                }).whenComplete(
                        () => Navigator.of(_scaffoldKey.currentContext).pop()),
                child: Text("Done"),
              ),
            ],
            title: Text("Edit Truck Details"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _truckNameController,
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      hintText: "Truck Name",
                      labelText: "Truck Name"),
                ),
                TextField(
                  controller: _truckCapacityController,
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      hintText: "Truck Capacity",
                      labelText: "Truck Capacity"),
                ),
                TextField(
                  controller: _truckDimensionController,
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      hintText: "Truck Dimension",
                      labelText: "Truck Dimension"),
                ),
                TextField(
                  controller: _truckPriceFactorController,
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      hintText: "Price Factor",
                      labelText: "Price Factor"),
                ),
                DropdownButton<String>(
                  value: truckEditingProvider.getSelectedCategoty,
                  onChanged: (val) {
                    data['category'] = val;
                    truckEditingProvider.setCategory(val);
                  },
                  isExpanded: true,
                  items: truckEditingProvider.getAllCategories
                      .map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                )
              ],
            ),
          );
        });
  }

  addTruck() {
    return showDialog(
        context: _scaffoldKey.currentContext,
        barrierDismissible: true,
        builder: (context) {
          TruckEditingProvider truckEditingProvider =
              Provider.of<TruckEditingProvider>(context);
          return AlertDialog(
            actions: [
              FlatButton(
                onPressed: () =>
                    Navigator.of(_scaffoldKey.currentContext).pop(),
                child: Text("Close"),
              ),
              FlatButton(
                onPressed: () => Firestore.instance.collection('trucks').add({
                  "category": truckEditingProvider.getSelectedCategoty,
                  "name": _truckNameController.text,
                  "capacity": _truckCapacityController.text,
                  "dimension": _truckDimensionController.text,
                  "priceFactor": _truckPriceFactorController.text,
                  "image": _truckImageURLController.text
                }).whenComplete(
                    () => Navigator.of(_scaffoldKey.currentContext).pop()),
                child: Text("Done"),
              ),
            ],
            title: Text("Add New Truck"),
            content: Container(
              width: MediaQuery.of(context).size.width - 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _truckNameController,
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        hintText: "Truck Name",
                        labelText: "Truck Name"),
                  ),
                  TextField(
                    controller: _truckCapacityController,
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        hintText: "Truck Capacity",
                        labelText: "Truck Capacity"),
                  ),
                  TextField(
                    controller: _truckDimensionController,
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        hintText: "Truck Dimension",
                        labelText: "Truck Dimension"),
                  ),
                  TextField(
                    controller: _truckPriceFactorController,
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        hintText: "Price Factor",
                        labelText: "Price Factor"),
                  ),
                  TextField(
                    controller: _truckImageURLController,
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        hintText: "Truck Image",
                        labelText: "Truck Image"),
                  ),
                  DropdownButton<String>(
                    value: truckEditingProvider.getSelectedCategoty,
                    onChanged: (val) {
                      truckEditingProvider.setCategory(val);
                    },
                    isExpanded: true,
                    items: truckEditingProvider.getAllCategories
                        .map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => addTruck(),
          )
        ],
        iconTheme: IconThemeData(color: ThemeColors.primaryColor),
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(
          "Truck Manager",
          style: TextStyle(color: ThemeColors.primaryColor),
        ),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('trucks').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ThemeColors.primaryColor),
                ),
              );
            } else if (snapshot.error != null) {
              print(snapshot.error.toString());
              return Text(snapshot.error.toString());
            } else {
              if (snapshot.data.documents.length == 0) {
                return Center(
                  child: Text("No Trucks...!!!!"),
                );
              } else {
                return AnimatedPadding(
                  duration: Duration(seconds: 1),
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          MediaQuery.of(context).size.width <= 600 ? 10 : 80,
                      vertical: 10),
                  child: ListView(
                    shrinkWrap: true,
                    children:
                        snapshot.data.documents.map((DocumentSnapshot truck) {
                      return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Image.network(truck['image']),
                          ),
                          title: Text(truck['name']),
                          subtitle:
                              Text("Capacity : ${truck.data['capacity']}"),
                          trailing: Wrap(
                            children: [
                              IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () =>
                                      editDialog(truck.data, truck.documentID)),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () =>
                                    _utils.deleteTruck(truck.documentID),
                              ),
                            ],
                          ));
                    }).toList(),
                  ),
                );
              }
            }
          }),
    );
  }
}
