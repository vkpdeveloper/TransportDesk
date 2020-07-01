import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rideapp/model/avatar_reference.dart';
import 'package:rideapp/services/firestore_path.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  FirestoreService({@required this.uid}) : assert(uid != null);
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
