// ignore_for_file: non_constant_identifier_names, implementation_imports

import 'package:flutter/src/material/card.dart';

class Paciente {
  String order_at ;
  int episode;
  String episode_type_name;
  String order_status ;
  String clinic_history ;
  String interconsulting_type_name;
  String request_service;
  String request_specialist;
  String solicited_service;
  String patient_name;
  String patient_name_short;
  int patient_age;
  String? room = 'null';
  String last_notification_at ;
  String description ;
  final String clinicName;
  String order_date_at ;
  String order_hour_at ;
  
  
  Paciente(
    this.order_at,
     this.episode,
     this.episode_type_name,
     this.order_status,
     this.clinic_history,
     this.interconsulting_type_name,
     this.request_service,
     this.request_specialist,
     this.solicited_service,
     this.patient_name,
     this.patient_name_short,
     this.patient_age,
     this.room,
     this.last_notification_at, 
     this.description,
     this.clinicName,
     this.order_date_at,
     this.order_hour_at,

  );

  void add(Card card) {}
  
}
