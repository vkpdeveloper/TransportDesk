import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DriverDocuments extends StatefulWidget {
  String phoneno;
  DriverDocuments({Key key, this.phoneno}) : super(key: key);
  @override
  _DriverDocumentsState createState() => _DriverDocumentsState();
}

class _DriverDocumentsState extends State<DriverDocuments> {
  int currentStep = 0;

  int docsuploaded = 0;
  bool complete = false;
  File _idfront, _idback, _dlfront, _dlback, _rcfront, _rcback;

  @override
  Widget build(BuildContext context) {
    Future<File> getImage() async {
      return await ImagePicker.pickImage(source: ImageSource.gallery);
    }

    /// Cropper plugin

    _pickImage<File>(File filename) async {
      final imageSource = await showDialog<ImageSource>(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Select the image source"),
                actions: <Widget>[
                  MaterialButton(
                    child: Text("Camera"),
                    onPressed: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  MaterialButton(
                    child: Text("Gallery"),
                    onPressed: () =>
                        Navigator.pop(context, ImageSource.gallery),
                  )
                ],
              ));

      if (imageSource != null) {
        return await ImagePicker.pickImage(source: imageSource);
      }
      return filename;
    }

    goTo(int step) {
      setState(() => currentStep = step);
    }

    next() {
      currentStep + 1 != 3
          ? goTo(currentStep + 1)
          : setState(() => complete = true);
    }

    cancel() {
      if (currentStep > 0) {
        goTo(currentStep - 1);
      }
    }

    return new Scaffold(
        backgroundColor: Colors.yellow[300],
        body: Stack(
          children: <Widget>[
            Column(children: <Widget>[
              Expanded(
                child: Stepper(
                  currentStep: currentStep,
                  onStepContinue: next,
                  onStepTapped: (step) => goTo(step),
                  onStepCancel: cancel,
                  steps: [
                    Step(
                      isActive: true,
                      state: StepState.editing,
                      title: const Text('Owner Adhaar or voter ID'),
                      subtitle: const Text(
                          'Upload clear photos of your from \nboth sides'),
                      content: Row(
                        children: <Widget>[
                          Container(
                            color: Colors.blue,
                            height: 150,
                            width: 130,
                            child: Column(
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    _idfront == null
                                        ? Container(
                                            color: Colors.blue,
                                          )
                                        : Image.file(
                                            _idfront,
                                            fit: BoxFit.fitWidth,
                                            height: 100,
                                            width: 130,
                                          ),
                                    InkWell(
                                        onTap: () async {
                                          File newimage =
                                              await _pickImage(_idfront);
                                          setState(() {
                                            _idfront = newimage;
                                          });
                                        },
                                        child: Center(
                                            child: Container(
                                          height: 100,
                                          width: 130,
                                          child: Opacity(
                                            opacity: _idfront == null ? 1.0 : 0,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(Icons.camera_alt),
                                                Text("front photo"),
                                              ],
                                            ),
                                          ),
                                        ))),
                                  ],
                                ),
                                Uploader(
                                  file: _idfront,
                                  filename: "idfront",
                                  phoneno: widget.phoneno,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            color: Colors.blue,
                            height: 150,
                            width: 130,
                            child: Column(
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    _idback == null
                                        ? Container(
                                            color: Colors.blue,
                                          )
                                        : Image.file(
                                            _idback,
                                            fit: BoxFit.fitWidth,
                                            height: 100,
                                            width: 130,
                                          ),
                                    InkWell(
                                        onTap: () async {
                                          File newimage =
                                              await _pickImage(_idback);
                                          setState(() {
                                            _idback = newimage;
                                          });
                                        },
                                        child: Center(
                                            child: Container(
                                          height: 100,
                                          width: 130,
                                          child: Opacity(
                                            opacity: _idback == null ? 1.0 : 0,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(Icons.camera_alt),
                                                Text("back photo"),
                                              ],
                                            ),
                                          ),
                                        ))),
                                  ],
                                ),
                                Uploader(
                                  file: _idback,
                                  filename: "idback",
                                  phoneno: widget.phoneno,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Driving Licence'),
                      subtitle: const Text(
                          'Upload Photo of your driving licence \nfrom both sides'),
                      isActive: true,
                      state: StepState.editing,
                      content: Row(
                        children: <Widget>[
                          Container(
                            color: Colors.blue,
                            height: 150,
                            width: 130,
                            child: Column(
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    _dlfront == null
                                        ? Container(
                                            height: 100,
                                            width: 130,
                                            color: Colors.blue,
                                          )
                                        : Image.file(
                                            _dlfront,
                                            fit: BoxFit.fitWidth,
                                            height: 100,
                                            width: 130,
                                          ),
                                    InkWell(
                                        onTap: () async {
                                          File newimage =
                                              await _pickImage(_dlfront);
                                          setState(() {
                                            _dlfront = newimage;
                                          });
                                        },
                                        child: Container(
                                          height: 100,
                                          width: 130,
                                          child: Center(
                                              child: Opacity(
                                            opacity:
                                                _dlfront == null ? 1.0 : 0.0,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(Icons.camera_alt),
                                                Text("front photo"),
                                              ],
                                            ),
                                          )),
                                        )),
                                  ],
                                ),
                                Uploader(
                                  file: _dlfront,
                                  filename: "dlfront",
                                  phoneno: widget.phoneno,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            color: Colors.blue,
                            height: 150,
                            width: 130,
                            child: Column(
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    _dlback == null
                                        ? Container(
                                            height: 100,
                                            width: 130,
                                            color: Colors.blue,
                                          )
                                        : Image.file(
                                            _dlback,
                                            fit: BoxFit.fitWidth,
                                            height: 100,
                                            width: 130,
                                          ),
                                    InkWell(
                                        onTap: () async {
                                          File newimage =
                                              await _pickImage(_dlback);
                                          setState(() {
                                            _dlback = newimage;
                                          });
                                        },
                                        child: Container(
                                          height: 100,
                                          width: 130,
                                          child: Center(
                                              child: Opacity(
                                            opacity:
                                                _idback == null ? 1.0 : 0.0,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(Icons.camera_alt),
                                                Text("back photo"),
                                              ],
                                            ),
                                          )),
                                        )),
                                  ],
                                ),
                                Uploader(
                                  file: _dlback,
                                  filename: "dlback",
                                  phoneno: widget.phoneno,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Step(
                      isActive: true,
                      state: StepState.editing,
                      title: const Text('RC of Vehicle'),
                      subtitle: const Text(
                          'Upload photos of your RC from \nboth sides'),
                      content: Row(
                        children: <Widget>[
                          Container(
                            color: Colors.blue,
                            height: 150,
                            width: 130,
                            child: Column(
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    _rcfront == null
                                        ? Container(
                                            height: 100,
                                            width: 130,
                                            color: Colors.blue,
                                          )
                                        : Image.file(
                                            _rcfront,
                                            fit: BoxFit.fitWidth,
                                            height: 100,
                                            width: 130,
                                          ),
                                    InkWell(
                                        onTap: () async {
                                          File newimage =
                                              await _pickImage(_rcfront);
                                          setState(() {
                                            _rcfront = newimage;
                                          });
                                        },
                                        child: Container(
                                          height: 100,
                                          width: 130,
                                          child: Center(
                                              child: Opacity(
                                            opacity:
                                                _rcfront == null ? 1.0 : 0.0,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(Icons.camera_alt),
                                                Text("front photo"),
                                              ],
                                            ),
                                          )),
                                        )),
                                  ],
                                ),
                                Uploader(
                                  file: _rcfront,
                                  filename: "rcfront",
                                  phoneno: widget.phoneno,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            color: Colors.blue,
                            height: 150,
                            width: 130,
                            child: Column(
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    _rcback == null
                                        ? Container(
                                            height: 100,
                                            width: 130,
                                            color: Colors.blue,
                                          )
                                        : Image.file(
                                            _rcback,
                                            fit: BoxFit.fitWidth,
                                            height: 100,
                                            width: 130,
                                          ),
                                    InkWell(
                                        onTap: () async {
                                          File newimage =
                                              await _pickImage(_idback);
                                          setState(() {
                                            _rcback = newimage;
                                          });
                                        },
                                        child: Container(
                                          height: 100,
                                          width: 130,
                                          child: Center(
                                              child: Opacity(
                                            opacity:
                                                _rcback == null ? 1.0 : 0.0,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(Icons.camera_alt),
                                                Text("back photo"),
                                              ],
                                            ),
                                          )),
                                        )),
                                  ],
                                ),
                                Uploader(
                                  file: _rcback,
                                  filename: "rcback",
                                  phoneno: widget.phoneno,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
            Positioned(
              bottom: 30,
              right: MediaQuery.of(context).size.width / 2 - 100,
              child: Container(
                height: 40,
                width: 200,
                child: MaterialButton(
                    color: Colors.green,
                    child: Text("Done"),
                    onPressed: () {
                      //Confirm upload and Show Done Animation..
                    }),
              ),
            )
          ],
        ));
  }
}

class Uploader extends StatefulWidget {
  final File file;
  final String phoneno;
  final String filename;
  Uploader({Key key, this.file, this.phoneno, this.filename}) : super(key: key);
  @override
  _UploaderState createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://logisticsuber-6dd8d.appspot.com');

  StorageUploadTask _uploadTask;

  /// Starts an upload task
  void _startUpload() {
    /// Unique file name for the file
    String filePath = 'DriverDocs/${widget.phoneno}/${widget.filename}';

    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      /// Manage the task state and event subscription with a StreamBuilder
      return StreamBuilder<StorageTaskEvent>(
          stream: _uploadTask.events,
          builder: (_, snapshot) {
            var event = snapshot?.data?.snapshot;

            double progressPercent = event != null
                ? event.bytesTransferred / event.totalByteCount
                : 0;

            return Column(
              children: [
                if (_uploadTask.isComplete) Text('Done'),
                LinearProgressIndicator(
                  value: progressPercent,
                  backgroundColor: Colors.blue,
                ),
                Text('${(progressPercent * 100).toStringAsFixed(2)} % '),
              ],
            );
          });
    } else {
      // Allows user to decide when to start the upload
      return FlatButton.icon(
        label: Text('Upload'),
        icon: Icon(Icons.cloud_upload),
        onPressed: _startUpload,
      );
    }
  }
}
