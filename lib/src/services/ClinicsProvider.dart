// ignore_for_file: file_names

import 'package:flutter/foundation.dart';

import '../models/login.dart';

class ClinicProvider with ChangeNotifier {
  List<Clinic> _clinics = [];

  List<Clinic> get clinics => _clinics;

  void setClinics(List<Clinic> clinics) {
    _clinics = clinics;
    notifyListeners(); // Notifica a los observadores que se han producido cambios
  }
}
