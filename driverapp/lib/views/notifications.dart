import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  bool _isBoxOpen = false;

  @override
  void initState() {
    super.initState();
    openData();
  }

  openData() async {
    var box = await Hive.openBox('notification');
    if(box.isOpen) {
      setState(() {
        _isBoxOpen = box.isOpen;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification"),
      
      ),
      body: _isBoxOpen ? WatchBoxBuilder(
        box: Hive.box('notification'),
        builder: (context, box) {
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final notification = box.getAt(index) as List<String>;
              return ListTile(
                title: Text(notification[0]),
                subtitle: Text(notification[1]),
              );
            }
            );
        },
      ) : Center(child: CircularProgressIndicator(),)

    );
  }
}

class Notification {
  final String title;
  final String message;

  Notification(this.title, this.message);
}