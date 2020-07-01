import 'dart:io';

import 'package:driverapp/constants/themecolors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SendBill extends StatefulWidget {
  @override
  _SendBillState createState() => _SendBillState();
}

class _SendBillState extends State<SendBill> {
  File _image;
  final picker = ImagePicker();

  Future getImageFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future getImageFromStorage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send Bill"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: _image == null
                    ? Center(
                        child: Text(
                        'Please Select Bill Image',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ))
                    : Center(child: Image.file(_image)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      getImageFromCamera();
                    },
                    icon: Icon(
                      Icons.camera,
                      size: 60,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      getImageFromStorage();
                    },
                    icon: Icon(
                      Icons.folder,
                      size: 60,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20),
              child: MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                color: ThemeColors.darkblueColor,
                minWidth: 150,
                onPressed: () {
                  //store to firestore
                },
                child: Text(
                  "Send Image",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
