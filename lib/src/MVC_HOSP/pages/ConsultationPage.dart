// ignore_for_file: file_names, avoid_print, sized_box_for_whitespace, non_constant_identifier_names, unnecessary_string_interpolations, prefer_const_constructors

import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'package:app_notificador/src/models/paciente.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/login.dart';
import '../../services/provider.dart';
import '../../services/push_notification_services.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter_html/flutter_html.dart';

class Interconsulta extends StatefulWidget {
  const Interconsulta({Key? key}) : super(key: key);

  @override
  State<Interconsulta> createState() => _HomeState();
}

class _HomeState extends State<Interconsulta> {
  @override
  void initState() {
    super.initState();

    PushNotificatonServices.messagesStream.listen((message) {
      print('MyApp: $message');
    });
    _loadLoginData();
    _paciente = _postPaciente(context);
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
      final loginData = LoginData(
          username, name, tokenBD, password, tokenFB, dni, phone, cmp, email,type_doctor!);
      // ignore: use_build_context_synchronously
      context.read<LoginProvider>().setLoginData(loginData);
    }
    return tokenBD;
  }

  late Future<List<Paciente>> _paciente;

  Future<List<Paciente>> _postPaciente(BuildContext context) async {
    const url = 'https://notimed.sanpablo.com.pe:8443/api/data/earrings';

    final String? tokenBD = await _loadLoginData();

    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $tokenBD'},
    );

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      List<Paciente> pacientes = [];

      jsonData['data'].values.forEach((service) {
        if (service['services'] != null) {
          String clinicName = service['clinic_name'];
          service['services'].values.forEach((dataValue) {
            if (dataValue['data'] != null) {
              dataValue['data'].forEach((pacienteData) {
                pacientes.add(Paciente(
                  pacienteData['order_at'],
                  pacienteData['episode'],
                  pacienteData['episode_type_name'],
                  pacienteData['order_status'],
                  pacienteData['clinic_history'],
                  pacienteData['interconsulting_type_name'],
                  pacienteData['request_service'],
                  pacienteData['request_specialist'],
                  pacienteData['solicited_service'],
                  pacienteData['patient_name'],
                  pacienteData['patient_name_short'],
                  pacienteData['patient_age'],
                  pacienteData['room'],
                  pacienteData['last_notification_at'],
                  pacienteData['description'],
                  clinicName,
                ));
              });
            }
          });
        }
      });

      print('body: ${response.body}');
      print('reques: ${response.request}');
      print('headers: ${response.headers}');
      print(Service());

      return pacientes;
    } else {
      print('Error en la solicitud HTTP: ${response.statusCode}');
      throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
    }
  }

  // Function to refresh the data and update the UI
  Future<void> refreshData() async {
    setState(() {
      _paciente = _postPaciente(context);
    });
  }

//mostrar informacion - actualar animado
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NOTIMED',
      home: WillPopScope(
      onWillPop: () async {  
        return false;
      },
      child:Scaffold(
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
                    child: FutureBuilder<List<Paciente>>(
                      future: _paciente,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Paciente>> snapshot) {
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
                                  'SIN CONEXIÓN', // Mensaje de texto
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
                                  'No hay interconsulta pendiente', // Mensaje de texto
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
      ),
    );
  }

//llamada a la consulta
List<Widget> _pacientes(List<Paciente> data) {
  List<Widget> pacienteWidgets = [];

  for (var pacienteData in data) {
    Widget pacienteWidget = Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: () {
          _showDialog(context, pacienteData);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.deepPurple, width: 0),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.deepPurple,
                  ),
                  child: const Text(
                    'INTERCONSULTA PENDIENTE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              // Llama al nombre de la clínica
              Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        pacienteData.clinicName, // Usa clinic_name aquí
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Llama al número de HC
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

              // Llama al nombre del paciente
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

              // Llama a la habitación del paciente
              Row(
                children: [
                  const SizedBox(width: 20),
                  if (pacienteData.room != null)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            Text(
                              'HABITACION:  ${pacienteData.room} ',
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

              // Llama donde se originó la notificación (HOSPITALIZACIÓN - URGENCIA)
              Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ORIGEN: ${pacienteData.episode_type_name}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Llama al tipo de interconsulta
              Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          Text(
                            'TIPO:  ${pacienteData.interconsulting_type_name} ',
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

              // Llama a la fecha de creación
              Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'FECHA Y HORA DE INTERCONSULTA: ${pacienteData.order_at}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

             const Text(''),

              // Llama a la especialidad solicitada
              Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            ' ${pacienteData.solicited_service}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
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
      ),
    );

    pacienteWidgets.add(IntrinsicHeight(child: pacienteWidget));
  }

  return pacienteWidgets;
}

//FUNCION DE INFORMAACION ADICIONAL
  void _showDialog(BuildContext context, Paciente pacienteData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: const Text('Detalles de la Interconsulta'),
          content: Container(
            width: 300, // Ancho deseado
            height: 250, // Altura deseada
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)), // Borde redondeado
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${pacienteData.patient_name}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Origen: ${pacienteData.episode_type_name}'),
                  Text('Habitación: ${pacienteData.room ?? ""}'),
                  SizedBox(height: 10), // Espacio entre los datos y el contenido HTML
                  Html(data: pacienteData.description),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cerrar',
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
