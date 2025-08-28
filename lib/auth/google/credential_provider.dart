import 'package:flutter/material.dart';

class GoogleCredentialProvider with ChangeNotifier {
  String? token;

  GoogleCredentialProvider({this.token});

  void setValue(String? token) {
    this.token = token;
    notifyListeners();
  }
}
