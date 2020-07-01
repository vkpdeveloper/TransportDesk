import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUtils {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signInWithUser(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return await checkIfAdmin();
    } catch (e) {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    FirebaseUser _user = await _auth.currentUser();
    return _user != null;
  }

  void signOut() {
    _auth.signOut();
  }

  Future<void> sendVerificationEmail() async {
    FirebaseUser _user = await _auth.currentUser();
    await _user.sendEmailVerification();
  }

  Future<bool> checkIfAdmin() async {
    FirebaseUser _user = await _auth.currentUser();
    try {
      await Firestore.instance
          .collection('admin')
          .document('info')
          .updateData({"email": _user.email});
      return true;
    } catch (e) {
      return false;
    }
  }

  void sendPasswordResetLink() {
    _auth.sendPasswordResetEmail(email: "androcomputerhackes@gmail.com");
  }

  deleteTruck(String truckid) {
    Firestore.instance.collection('trucks').document(truckid).delete();
  }
}
