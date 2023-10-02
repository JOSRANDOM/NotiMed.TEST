// ignore_for_file: unused_element, non_constant_identifier_names, file_names
import 'dart:convert';
import 'dart:developer';

import 'package:app_notificador/src/models/login.dart';
import 'package:app_notificador/src/services/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/pacienteDM.dart';
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

late Future<List<PacienteDM>> _paciente;

class _MedShiftState extends State<MedShift> {
  String? selectedValue;
  late String clinicId;
  late String serviceId;
  List<PacienteDM> _pacientesData = [];
  bool _mostrarLista = false;

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

  Future<List<PacienteDM>> _postPaciente(BuildContext context) async {
    const url =
        'https://notimed.sanpablo.com.pe:8443/api/clinic/interconsultings';

    final String? tokenBD = await _loadLoginData(context);

    if (selectedValue == null) {
      throw Exception(
          'Debe seleccionar una clínica antes de hacer la solicitud.');
    }

    final parts = selectedValue!.split(' - ');
    final clinicId = parts[0];
    final serviceId = '0'; // Valor fijo de service_id

    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $tokenBD'},
      body: {
        'clinic_id': clinicId,
        'service_id': serviceId,
      },
    );

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      List<PacienteDM> pacientes = [];

      if (jsonData['data'] != null) {
        jsonData['data'].forEach((service) {
          if (service['services'] != null) {
            String clinicName = service['clinic_name'];
            service['services'].forEach((dataValue) {
              if (dataValue['data'] != null) {
                dataValue['data'].forEach((pacienteData) {
                  pacientes.add(PacienteDM(
                    pacienteData['order_at'],
                    pacienteData['order_hour_at'],
                    pacienteData['episode'],
                    pacienteData['episode_type_name'],
                    pacienteData['order_status'],
                    pacienteData['clinic_history'],
                    pacienteData['interconsulting_type_name'],
                    pacienteData['request_service'],
                    pacienteData['request_specialist'],
                    pacienteData['solicited_service'],
                    pacienteData['solicited_service_id'],
                    pacienteData['service_id'],
                    pacienteData['patient_name'],
                    pacienteData['patient_name_short'],
                    pacienteData['patient_age'],
                    pacienteData['room'],
                    pacienteData['last_notification_at'],
                    pacienteData['description'],
                    pacienteData['priority'],
                    pacienteData['elapsed_time_hours'],
                    clinicName as int,
                  ));
                });
              }
            });
          }
          // Actualiza la variable de estado con los datos de los pacientes
          setState(() {
            _pacientesData = pacientes;
          });
        });
      }

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

  @override
  Widget build(BuildContext context) {
    final List<Clinic> clinics = Provider.of<LoginProvider>(context).clinics;

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedValue,
              items: clinics.map((clinic) {
                final clinicLabel = '${clinic.id} - ${clinic.name}';
                return DropdownMenuItem<String>(
                  value: clinicLabel,
                  child: Text(clinicLabel),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue;
                });
              },
            ),
            ElevatedButton(
            onPressed: () async {
              if (selectedValue != null) {
                final parts = selectedValue!.split(' - ');
                clinicId = parts[0];
                serviceId = '0'; // Valor fijo de service_id, debes actualizarlo si es necesario
                await _postPaciente(context); // Llamar a la consulta con los nuevos valores
                setState(() {
                  _mostrarLista = true; // Mostrar la lista de pacientes
                });
              }
            },
            child: Text('Consultar Pacientes'),
          ),
          if (_mostrarLista)
            Expanded(
              child: ListView(
                children: _pacientes(_pacientesData),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //llamada a la consulta
  List<Widget> _pacientes(List<PacienteDM> data) {
    List<Widget> pacienteWidgets = [];

    for (var pacienteData in _pacientesData) {
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
  void _showDialog(BuildContext context, PacienteDM pacienteData) {
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
              borderRadius:
                  BorderRadius.all(Radius.circular(10.0)), // Borde redondeado
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'H.C: ${pacienteData.clinic_history}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Origen: ${pacienteData.episode_type_name}'),
                  Text('Habitación: ${pacienteData.room ?? ""}'),
                  SizedBox(
                      height:
                          10), // Espacio entre los datos y el contenido HTML
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
