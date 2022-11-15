import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helpers/wordpair.dart';

class SuggestionsNotifier extends ChangeNotifier {
  late List<WordPair> _saved = <WordPair>[];
  late FirebaseFirestore _firestore;
  late User? _user;

  // late List<WordPair> _fromCloud;
  List<WordPair> _fromCloud = <WordPair>[];

  List<WordPair> get saved => _saved;

  List<WordPair> get fromCloud => _fromCloud;

  setSavedSuggestions(List<WordPair> saved, String? userUid) async {
    _saved = saved;
    storeOnFirebase(userUid);
    notifyListeners();
  }

  SuggestionsNotifier() {
    _firestore = FirebaseFirestore.instance;
  }

  void addUser(String email, userUid) async {
    await _firestore
        .collection('users')
        .doc(userUid)
        .set({'email': email, 'savedSuggestions': wordPairToJson(saved)});
  }

  Future<void> getUserSavedSuggestions(String? userUid) async {
    var cloudUserSavedSuggestions =
        await _firestore.collection('users').doc(userUid).get();
    final data = cloudUserSavedSuggestions.data();
    _fromCloud = wordPairFromJson(data!['savedSuggestions']);
    var unionWithLocal = <WordPair>{...saved, ..._fromCloud}.toList();
    setSavedSuggestions(unionWithLocal, userUid);
  }

  Future<void> storeOnFirebase(String? userUid) async {
    if (userUid != null) {
      _firestore
          .collection('users')
          .doc(userUid)
          .update({'savedSuggestions': wordPairToJson(saved)});
    }
  }
}
