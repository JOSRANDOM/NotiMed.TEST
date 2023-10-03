// ignore_for_file: non_constant_identifier_names, implementation_imports

import 'package:flutter/src/material/card.dart';

class PacienteDM {
  String order_at ;
  String order_hour_at ;
  int episode;
  String episode_type_name;
  String order_status ;
  String clinic_history ;
  String interconsulting_type_name;
  String request_service;
  String request_specialist;
  String solicited_service;
  String solicited_service_id;
  int service_id;
  String patient_name;
  String patient_name_short;
  int patient_age;
  String? room = 'null';
  String last_notification_at ;
  String description ;
  int priority;
  int elapsed_time_hours;


  
  PacienteDM(
    this.order_at,
     this.order_hour_at,
     this.episode,
     this.episode_type_name,
     this.order_status,
     this.clinic_history,
     this.interconsulting_type_name,
     this.request_service,
     this.request_specialist,
     this.solicited_service,
     this.solicited_service_id,
     this.service_id,
     this.patient_name,
     this.patient_name_short, 
     this.patient_age,
     this.room,
     this.last_notification_at,
     this.description,

     this.priority,
     this.elapsed_time_hours,

  );

  void add(Card card) {}
  
}
