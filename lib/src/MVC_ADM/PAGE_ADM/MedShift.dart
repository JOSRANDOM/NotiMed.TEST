// ignore_for_file: unused_element, non_constant_identifier_names, file_names
import 'dart:convert';

import 'package:app_notificador/src/models/login.dart';
import 'package:app_notificador/src/services/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/push_notification_services.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificatonServices.initializeApp();

  runApp(ChangeNotifierProvider(
      create: (context) => LoginProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "NOTIMED - HOME",
        initialRoute: 'home',
        routes: {
          'home': (_) => const MedShift(),
        },
      )));
}

 class MedShift extends StatefulWidget {
  const MedShift({super.key});

  @override
  State<MedShift> createState() => _MedShiftState();
}

Future<String?> _loadLoginData(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? username = prefs.getString('username');
  String? name = prefs.getString('name');
  String? tokenBD = prefs.getString('token');
  String? password = prefs.getString('password');
  String? tokenFB = prefs.getString('tokenFB');
  String? dni = prefs.getString('document_number');
  String? phone = prefs.getString('phone');
  String? email = prefs.getString('email');
  String? cmp = prefs.getString('cmp');
  String? clinicsJson = prefs.getString('clinics');
  int? type_doctor = prefs.getInt('type_doctor');

  if (username != null &&
      name != null &&
      tokenBD != null &&
      password != null &&
      tokenFB != null &&
      dni != null &&
      phone != null) {
    List<Clinic> clinics = [];
    if (clinicsJson != null) {
      final List<dynamic> clinicData = json.decode(clinicsJson);
      clinics = clinicData
          .map((clinic) => Clinic(
                clinic['id'],
                clinic['name'],
                clinic['name_short'],
                clinic['color'],
              ))
          .toList();
    }

    final loginData = LoginData(
      username,
      name,
      tokenBD,
      password,
      tokenFB,
      dni,
      phone,
      cmp,
      email,
      type_doctor!,
      clinics, // Asigna la lista de clínicas deserializadas
    );
    context.read<LoginProvider>().setLoginData(loginData);
  }
  return tokenBD;
}

class _MedShiftState extends State<MedShift> {
  @override
  Widget build(BuildContext context) {
    final List<Clinic> clinics = Provider.of<LoginProvider>(context).clinics;

    return Scaffold(
      body: Center(
        child: DropdownButton<String>(
          value: null, // Puedes establecer un valor predeterminado aquí si lo deseas.
          items: clinics.map((clinic) {
            return DropdownMenuItem<String>(
              value: clinic.name,
              child: Text(clinic.name),
            );
          }).toList(),
          onChanged: (String? selectedValue) {
            // Implementa la lógica cuando se selecciona una clínica aquí.
          },
        ),
      ),
    );
  }
}
