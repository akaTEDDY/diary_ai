import 'package:flutter/material.dart';

class LocationHistoryUpdateProvider with ChangeNotifier {
  bool _updated = false;

  bool get updated => _updated;

  void setUpdated(bool value) {
    _updated = value;
    notifyListeners();
  }
}
