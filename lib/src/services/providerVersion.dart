// ignore_for_file: file_names

import 'package:flutter/material.dart';

class GlobalData extends ChangeNotifier {
  String version = 'v1.0' ;

  void updateVersion(String newVersion) {
    version = newVersion;
    notifyListeners(); // Notifica a los oyentes que se ha actualizado la versión.
  }
}