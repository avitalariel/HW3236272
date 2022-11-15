import 'dart:convert';

import 'package:english_words/english_words.dart';

List<WordPair> wordPairFromJson(String str) =>
    List<WordPair>.from(json.decode(str).map((x) => fromJson(x)));

String wordPairToJson(List<WordPair> data) =>
    json.encode(List<dynamic>.from(data.map((x) => toJson(x))));

WordPair fromJson(Map<String, dynamic> json) => WordPair(
      json["first"],
      json["second"],
    );

Map<String, dynamic> toJson(x) => {
      "first": x.first,
      "second": x.second,
    };
