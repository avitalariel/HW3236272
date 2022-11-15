import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

enum Status { authenticated, authenticating, unauthenticated }

class AuthNotifier extends ChangeNotifier {
  late FirebaseAuth _auth;

  // firebase_storage.FirebaseStorage storage =
  //     firebase_storage.FirebaseStorage.instance;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  String? _userAvatar;
  User? _user;
  late Status _status = Status.unauthenticated;

  Status get status => _status;

  User? get user => _user;

  String? get userAvatar => _userAvatar;

  AuthNotifier() {
    _user = null;
    _auth = FirebaseAuth.instance;
    _auth.authStateChanges().listen((firebaseUser) async {
      print('Im here');
      if (firebaseUser == null) {
        print('Not connected');

        _user = null;
        _status = Status.unauthenticated;
      } else {
        print('Connected');

        _user = firebaseUser;
        _status = Status.authenticated;
        await downloadFile(_user?.uid);
      }
      print('Got here!!!');
      print(_status);
      notifyListeners();
    });
  }

  Future<void> logOut() async {
    _auth.signOut();
  }

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      _status = Status.authenticating;
      notifyListeners();
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      _status = Status.unauthenticated;
      notifyListeners();
      return null;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _status = Status.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> downloadFile(String? filename) async {
    try {
      if(filename==null) return;
      _userAvatar =
          await storage.ref('avatars').child(filename).getDownloadURL();
      notifyListeners();
    } catch (e) {
      print('No avatar');
      _userAvatar = null;
      print('No avatar2');

    }
  }
}
