// ignore_for_file: file_names, no_leading_underscores_for_local_identifiers, avoid_print, sized_box_for_whitespace, non_constant_identifier_names

import 'dart:convert';
import 'dart:core';
import 'package:app_notificador/src/MVC_HOSP/pages/UserPage.dart';
import 'package:app_notificador/src/models/PatinetHospitalized.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/login.dart';
import '../../models/user.dart';
import '../../services/provider.dart';
import '../../services/push_notification_services.dart';
import 'package:lottie/lottie.dart';

import '../../utill/IDI.dart';
import '../../utill/Logout.dart';

class ListPatient extends StatefulWidget {
  const ListPatient({Key? key}) : super(key: key);

  @override
  State<ListPatient> createState() => _ListPatient();
}

class _ListPatient extends State<ListPatient> {
  late Future<List<Usuario>> _usuario;
  @override
  void initState() {
    super.initState();
    _usuario = _postUsuario();
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
    int? type_doctor = prefs.getInt('type_doctor');

    if (username != null &&
        name != null &&
        tokenBD != null &&
        password != null &&
        tokenFB != null &&
        dni != null &&
        phone != null) {
      final loginData = LoginData(username, name, tokenBD, password, tokenFB,
          dni, phone, cmp, email, type_doctor!);
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
          element['patient_name_short'],
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

  Future<List<Usuario>> _postUsuario() async {
    const url = 'https://notimed.sanpablo.com.pe:8443/api/profile';

    final String? tokenBD = await _loadLoginData();

    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $tokenBD'},
    );

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      List<Usuario> usuarios = [];

      print(jsonData['data']);

      usuarios.add(Usuario(
        jsonData['data']['name'],
        jsonData['data']['cmp'],
        jsonData['data']['document_number'],
        jsonData['data']['email'],
        jsonData['data']['phone'],
      ));

      print('body: ${response.body}');
      print('reques: ${response.request}');
      print('headers: ${response.headers}');

      return usuarios;
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.deepPurple),
          title: FutureBuilder<List<Usuario>>(
            future: _usuario,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Error');
              } else if (snapshot.hasError) {
                return const Text('Error');
              } else if (snapshot.hasData) {
                String? userName = snapshot.data![0].name;
                return RichText(
                  text: TextSpan(
                    text: 'Bienvenido: ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18),
                    children: [
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: userName,
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 18,
                        ),
                      ),
                      const TextSpan(text: ' '),
                      const TextSpan(
                        text: 'usuarios hospitalario',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Text('No data');
              }
            },
          ),
        ),
        endDrawer: Drawer(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(top: 50, bottom: 10),
                  child: Image.asset('lib/src/images/NotiMed.png'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserPage()));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 30),
                    padding: const EdgeInsets.all(20),
                    width: 300,
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DATOS DEL USUARIO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Icon(
                          Icons.account_circle_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    IDI(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(20),
                    width: 300,
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '¿Quiénes Somos?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Icon(
                          Icons.co_present_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: Container()),
                GestureDetector(
                  onTap: () {
                    logout(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(20),
                    width: 250,
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'CERRAR SESIÓN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
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
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.blue, width: 0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Añade esta línea
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
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
              Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          pacienteData.patient_name_short,
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

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
