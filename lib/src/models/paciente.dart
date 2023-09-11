// ignore: implementation_imports
import 'package:flutter/src/material/card.dart';

class Paciente {
  // ignore: non_constant_identifier_names
  String order_at ;
  int episode;
  // ignore: non_constant_identifier_names
  String episode_type_name;
  // ignore: non_constant_identifier_names
  String order_status ;
  // ignore: non_constant_identifier_names
  String clinic_history ;
  // ignore: non_constant_identifier_names
  String interconsulting_type_name;
  // ignore: non_constant_identifier_names
  String request_service;
  // ignore: non_constant_identifier_names
  String request_specialist;
  // ignore: non_constant_identifier_names
  String solicited_service;
  // ignore: non_constant_identifier_names
  String patient_name;
  // ignore: non_constant_identifier_names
  int patient_age;
  String? room = 'null';
  // ignore: non_constant_identifier_names
  String last_notification_at ;
  String description ;
  final String clinicName;
  
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
     this.patient_age,
     this.room,
     this.last_notification_at, 
     this.description,
     this.clinicName,

  );

  void add(Card card) {}
  
}
