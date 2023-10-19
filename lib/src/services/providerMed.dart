// ignore_for_file: file_names

import 'package:flutter/material.dart';

class DoctorNameProvider extends ChangeNotifier {
  late String _doctorName;

  String get doctorName => _doctorName;

  void setDoctorName(String name) {
    _doctorName = name;
    notifyListeners();
  }
}
