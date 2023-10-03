// ignore_for_file: unused_element, non_constant_identifier_names, file_names
import 'dart:convert';
//import 'dart:developer';

import 'package:app_notificador/src/models/login.dart';
import 'package:app_notificador/src/services/provider.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

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
  List<PacienteDM> _paciente = [];

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
        jsonData['data'].forEach((pacienteData) {
          // Verificar si los campos son null antes de acceder a ellos
          String orderAt =
              pacienteData['order_at'] ?? ''; // Ejemplo de verificación
          String orderHourAt =
              pacienteData['order_hour_at'] ?? ''; // Ejemplo de verificación

          pacientes.add(PacienteDM(
            orderAt,
            orderHourAt,
            pacienteData['episode'] ?? '',
            pacienteData['episode_type_name'] ?? '',
            pacienteData['order_status'] ?? '',
            pacienteData['clinic_history'] ?? '',
            pacienteData['interconsulting_type_name'] ?? '',
            pacienteData['request_service'] ?? '',
            pacienteData['request_specialist'] ?? '',
            pacienteData['solicited_service'] ?? '',
            pacienteData['solicited_service_id'] ?? '',
            pacienteData['service_id'] ?? '',
            pacienteData['patient_name'] ?? '',
            pacienteData['patient_name_short'] ?? '',
            pacienteData['patient_age'] ??
                0, // Cambiar 0 al valor predeterminado adecuado
            pacienteData['room'] ??
                '', // Cambiar '' al valor predeterminado adecuado
            pacienteData['last_notification_at'] ??
                '', // Cambiar '' al valor predeterminado adecuado
            pacienteData['description'] ??
                '', // Cambiar '' al valor predeterminado adecuado
            pacienteData['priority'] ??
                0, // Cambiar 0 al valor predeterminado adecuado
            pacienteData['elapsed_time_hours'] ??
                0, // Cambiar 0 al valor predeterminado adecuado
          ));
        });
      }
      setState(() {
        _paciente = pacientes;
      });

      print('body: ${response.body}');
      print('reques: ${response.request}');
      print('headers: ${response.headers}');
      print('Data from response: ${json.decode(response.body)['data']}');

      return pacientes;
    } else {
      print('Error en la solicitud HTTP: ${response.statusCode}');
      throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
    }
  }

  // Function to refresh the data and update the UI
  Future<void> refreshData() async {
    setState(() {
      _paciente = _postPaciente(context) as List<PacienteDM>;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Clinic> clinics = Provider.of<LoginProvider>(context).clinics;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              child: DropdownButton<String>(
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
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (selectedValue != null) {
                  final parts = selectedValue!.split(' - ');
                  clinicId = parts[0];
                  serviceId =
                      '0'; // Valor fijo de service_id, debes actualizarlo si es necesario
                  await _postPaciente(
                      context); // Llamar a la consulta con los nuevos valores
                }
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size>(const Size(200, 40)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.deepPurple),
              ),
              child: Text('Consultar Pacientes'),
            ),
            Expanded(
              child: LiquidPullToRefresh(
                onRefresh: refreshData,
                color: Colors.white,
                backgroundColor: Colors.deepPurple,
                height: 100,
                animSpeedFactor: 2,
                showChildOpacityTransition: false,
                child: ListView.builder(
                  itemCount: _paciente.length,
                  itemBuilder: (context, index) {
                    final pacienteData = _paciente[index];
                    return ListTile(
                      title: Text(pacienteData.patient_name),
                      subtitle: Text(pacienteData.request_service),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}
