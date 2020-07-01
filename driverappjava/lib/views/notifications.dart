import 'package:driverapp/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool _isBoxOpen = false;
  var box;

  @override
  void initState() {
    super.initState();
    openData();
  }

  openData() async {
    box = await Hive.openBox('notification');
    if (box.isOpen) {
      setState(() {
        _isBoxOpen = box.isOpen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate("Notification")),
        ),
        body: _isBoxOpen
            ? box.length > 0
                ? WatchBoxBuilder(
                    box: Hive.box('notification'),
                    builder: (context, box) {
                      return ListView.builder(
                          itemCount: box.length,
                          itemBuilder: (context, index) {
                            int lastIndex = box.length - (index + 1);

                            final notification = box.getAt(lastIndex) as List<String>;
                            return ListTile(
                              trailing: box.length == index + 1
                                  ? Icon(
                                      Icons.desktop_mac,
                                      color: Colors.white,
                                    )
                                  : IconButton(
                                      onPressed: () => box.deleteAt(index),
                                      icon: Icon(Icons.delete),
                                    ),
                              title: Text(notification[0]),
                              subtitle: Text(notification[1]),
                            );
                          });
                    },
                  )
                : Center(
                    child:
                        Text(AppLocalizations.of(context).translate("No Previous Notifications")))
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}

class Notification {
  final String title;
  final String message;

  Notification(this.title, this.message);
}

// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// class Notifications extends StatefulWidget {
//   @override
//   _NotificationsState createState() => _NotificationsState();
// }

// class _NotificationsState extends State<Notifications> {
//   bool _isBoxOpen = false;
//   var box;

//   @override
//   void initState() {
//     super.initState();
//     openData();
//   }

//   openData() async {
//     box = await Hive.openBox('notification');
//     if (box.isOpen) {
//       setState(() {
//         _isBoxOpen = box.isOpen;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Notification"),
//         ),
//         body: _isBoxOpen
//             ? box.length > 0
//                 ? WatchBoxBuilder(
//                     box: Hive.box('notification'),
//                     builder: (context, box) {

//                       return ListView.builder(
//                           itemCount: box.length,
//                           itemBuilder: (context, index) {

//                             final notification =
//                                 box.getAt(index) as List<String>;
//                             return ListTile(
//                               trailing: box.length == index + 1
//                                   ? Icon(Icons.desktop_mac, color: Colors.white,)
//                                   : IconButton(
//                                       onPressed: () => box.deleteAt(index),
//                                       icon: Icon(Icons.delete),
//                                     ),
//                               title: Text(notification[0]),
//                               subtitle: Text(notification[1]),
//                             );
//                           });
//                     },
//                   )
//                 : Center(child: Text("No Previous Notifications"))
//             : Center(
//                 child: CircularProgressIndicator(),
//               ));
//   }
// }

// class Notification {
//   final String title;
//   final String message;

//   Notification(this.title, this.message);
// }
