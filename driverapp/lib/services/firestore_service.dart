import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driverapp/models/avatar_reference.dart';
import 'package:driverapp/services/firestore_path.dart';

class FirestoreService {
  FirestoreService({this.uid}) : assert(uid != null);
  final String uid;


  


  

  // Sets the avatar download url
  Future<void> setAvatarReference(AvatarReference avatarReference) async {
    final path = FirestorePath.avatar(uid);
    final reference = Firestore.instance.document(path);
    await reference.setData(avatarReference.toMap());
  }

  // Reads the current avatar download url
  Stream<AvatarReference> avatarReferenceStream() {
    final path = FirestorePath.avatar(uid);
    final reference = Firestore.instance.document(path);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => AvatarReference.fromMap(snapshot.data));
  }
}
