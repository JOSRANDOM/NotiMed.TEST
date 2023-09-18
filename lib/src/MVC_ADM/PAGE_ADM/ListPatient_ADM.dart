// ignore_for_file: file_names, no_leading_underscores_for_local_identifiers, avoid_print, sized_box_for_whitespace

import 'dart:convert';
import 'dart:core';
import 'package:app_notificador/src/models/PatinetHospitalized.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/login.dart';
import '../../services/provider.dart';
import '../../services/push_notification_services.dart';
import 'package:lottie/lottie.dart';

class ListPatientADM extends StatefulWidget {
  const ListPatientADM({Key? key}) : super(key: key);

  @override
  State<ListPatientADM> createState() => _ListPatient();
}

class _ListPatient extends State<ListPatientADM> {
  @override
  void initState() {
    super.initState();

    PushNotificatonServices.messagesStream.listen((message) {
      print('MyApp: $message');
    });
    _loadLoginData();
    _patient = _postPaciente(context);
  }

  // ignore: body_might_complete_normally_nullable
  Future<String?> _loadLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? username = prefs.getString('usarname');
    String? name = prefs.getString('name');
    String? tokenBD = prefs.getString('token');
    String? password = prefs.getString('password');
    String? tokenFB = prefs.getString('tokenFB');
    String? dni = prefs.getString('document_number');
    String? phone = prefs.getString('phone');
    String? email = prefs.getString('email');
    String? cmp = prefs.getString('cmp');

    if (username != null &&
        name != null &&
        tokenBD != null &&
        password != null &&
        tokenFB != null &&
        dni != null &&
        phone != null) {
      final loginData = LoginData(
          username, name, tokenBD, password, tokenFB, dni, phone, cmp, email);
      // ignore: use_build_context_synchronously
      context.read<LoginProvider>().setLoginData(loginData);
    }
    return tokenBD;
  }

  late Future<List<Patient>> _patient;

  Future<List<Patient>> _postPaciente(BuildContext context) async {
    const url = 'https://notimed.sanpablo.com.pe:8443/api/data/hospitalized';

    final String? tokenBD = await _loadLoginData();

    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $tokenBD'},
    );

    List<Patient> _patient = [];

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      for (var element in jsonData['data']) {
        _patient.add(Patient(
          element['date_origin_at'],
          element['patient_name'],
          element['room'],
          element['patient_sex'],
          element['patient_age'],
          element['clinic_history'],
          element['specialty'],
          element['clinic_name'],
          element['clinic_short_name'],
          element['date_at'],
          element['hour_at'],
        ));
      }
      return _patient;
    } else {
      throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
    }
  }

  // Function to refresh the data and update the UI
  Future<void> refreshData() async {
    setState(() {
      _patient = _postPaciente(context);
    });
  }

//mostrar informacion - actualar animado
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NOTIMED',
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Expanded(
            child: SizedBox(
              width: 370, // Establece un ancho máximo de 200
              child: LiquidPullToRefresh(
                  onRefresh: refreshData,
                  color: Colors.white,
                  backgroundColor: Colors.deepPurple,
                  height: 100,
                  animSpeedFactor: 2,
                  showChildOpacityTransition: false,
                  child: FutureBuilder<List<Patient>>(
                    future: _patient,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Patient>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.purple),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        print(snapshot.error);
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 200,
                                height: 150,
                                child: Lottie.network(
                                  'https://lottie.host/18d935ef-9547-4a4c-b38e-09787ed6dbac/l5OvPNglfK.json', // URL de la animación Lottie
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(
                                  height:
                                      20), // Espacio entre la animación y el texto
                              const Text(
                                'SIN CONEXIÓN',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 200,
                                height: 150,
                                child: Lottie.network(
                                  'https://lottie.host/69025247-2fa4-44ba-900b-0c8095da728f/rEY38pWAPN.json', // URL de la animación Lottie
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(
                                  height:
                                      20), // Espacio entre la animación y el texto
                              const Text(
                                'No tiene pacientes hospitalizados', // Mensaje de texto
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                            ],
                          ),
                        );
                      } else {
                        print('envío correcto');
                        return ListView(
                          children: _pacientes(snapshot.data!),
                        );
                      }
                    },
                  )),
            ),
          ),
        ),
      ),
    );
  }

//llamada a la consulta
List<Widget> _pacientes(List<Patient> data) {
  List<Widget> pacienteWidgets = [];

  for (var pacienteData in data) {
    Widget pacienteWidget = Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 200,
        ),
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.blue, width: 0),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.blue.shade200,
                ),
                child: const Text(
                  'PACIENTE HOSPITALIZADO',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            //llama al nombre de la clinica
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      pacienteData.clinic_name, // Usa clinic_name aquí
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //llama al numero de HC
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'HC: ${pacienteData.clinic_history}',
                      style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //llama al nombre del paciente
           /* Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        pacienteData.patient_name,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),*/

            //llama donde se origino la notificacion (HOSIPITALIZACION - URGENCIA)
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'HABITACIÓN: ${pacienteData.room}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // SEXO DEL PACIENTE
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'SEXO: ${pacienteData.patient_sex}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //EDAD DEL PACIENTE
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'EDAD: ${pacienteData.patient_age}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //FECHA DE INGRESO
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      children: [
                        Text(
                          'FECHA:  ${pacienteData.date_at} ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            //HORA DE INGRESO
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      children: [
                        Text(
                          'HORA:  ${pacienteData.hour_at} ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // llama a la espacialidad solicitada
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text(
                          ' ${pacienteData.specialty}',
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    pacienteWidgets.add(pacienteWidget);
  }

  return pacienteWidgets;
}

}