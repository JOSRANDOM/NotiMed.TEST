// ignore_for_file: non_constant_identifier_names, implementation_imports

import 'package:flutter/src/material/card.dart';

class DoctorDM {
  String clinic_name;
  String clinic_name_short;
  String clinic_color;
  int service_id;
  String service_name;
  String service_color;
  String doctor_name;
  String doctor_color;
  String init_date_at;
  String init_hour_at;
  String end_date_at;
  String end_hour_at;

  DoctorDM(
    this.clinic_name,
    this.clinic_name_short,
    this.clinic_color,
    this.service_id,
    this.service_name,
    this.service_color,
    this.doctor_name,
    this.doctor_color,
    this.init_date_at,
    this.init_hour_at,
    this.end_date_at,
    this.end_hour_at,
  );

  void add(Card card) {}
}
