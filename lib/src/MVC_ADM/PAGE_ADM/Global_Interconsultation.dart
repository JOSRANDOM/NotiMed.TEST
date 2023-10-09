// ignore_for_file: unused_element, non_constant_identifier_names, file_names, avoid_unnecessary_containers, avoid_print, unnecessary_string_interpolations
import 'dart:convert';

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
  bool _showDropdowns = true;
  String? selectedValue;
  String? selectedService;
  late String clinicId;
  late String serviceId;
  List<PacienteDM> _paciente = [];
  List<Map<String, dynamic>> _services = [];

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

  Future<List<PacienteDM>> _postPaciente(
      BuildContext context, String clinicId, String serviceId) async {
    const url =
        'https://notimed.sanpablo.com.pe:8443/api/clinic/interconsultings';

    final String? tokenBD = await _loadLoginData(context);

    if (selectedValue == null) {
      throw Exception(
          'Debe seleccionar una clínica antes de hacer la solicitud.');
    }

    final parts = selectedValue!.split(' - ');
    final clinicId = parts[0];
    // Actualiza serviceId con el valor correcto
    if (selectedService != null) {
      final selectedServiceMap = _services.firstWhere(
        (service) => service['nombre'] == selectedService,
        orElse: () => {'id': '0'},
      );
      serviceId = selectedServiceMap['id'].toString();
    }

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

      // Procesa la lista de servicios y almacénala en _services
      if (jsonData['services'] != null) {
        _services = List<Map<String, dynamic>>.from(jsonData['services']);
      }

      // Modifica el código para almacenar los nombres y los IDs de los servicios
      final List<Map<String, dynamic>> servicios = jsonData['services'] != null
          ? List<Map<String, dynamic>>.from(jsonData['services'])
          : [];

      // Crear una lista de Mapas que contienen el nombre y el ID del servicio
      final serviciosConID = servicios.map((servicio) {
        final nombre = servicio['name'];
        final id = servicio['id'];
        return {'nombre': nombre, 'id': id};
      }).toList();

      // Almacena la lista de servicios en _services
      _services = serviciosConID;

      setState(() {
        _paciente = pacientes;
      });

      print('body: ${response.body}');
      print('reques: ${response.request}');
      print('headers: ${response.headers}');
      print('Data from response: ${json.decode(response.body)['data']}');
      print('Data from response: ${json.decode(response.body)['services']}');

      return pacientes;
    } else {
      print('Error en la solicitud HTTP: ${response.statusCode}');
      throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
    }
  }

  Future<void> refreshData() async {
    final pacientes = await _postPaciente(context, clinicId, serviceId);
    setState(() {
      _paciente = pacientes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Clinic> clinics = Provider.of<LoginProvider>(context).clinics;

    return LiquidPullToRefresh(
      onRefresh: refreshData,
      color: Colors.white,
      backgroundColor: Colors.deepPurple,
      height: 100,
      animSpeedFactor: 2,
      showChildOpacityTransition: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showDropdowns ? null : 0, // Altura ajustable
                child: _showDropdowns
                    ? Column(
                        children: [
                          const SizedBox(height: 10),
                          //DROPDOWN N°1
                          Container(
                            width: 320,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.black, width: 0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: DropdownButton<String>(
                                isExpanded:
                                    false, // Configura isExpanded en false para que el DropdownButton no ocupe todo el ancho del Container
                                hint: const Text('selecciona una sede'),
                                value: selectedValue,
                                borderRadius: BorderRadius.circular(10),
                                dropdownColor: Colors.white,
                                items: clinics.map((clinic) {
                                  final clinicLabel =
                                      '${clinic.id} - ${clinic.name}';
                                  return DropdownMenuItem<String>(
                                    value: clinicLabel,
                                    child: Text(
                                      clinicLabel,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) async {
                                  setState(() {
                                    selectedValue = newValue;
                                    selectedService = null;
                                  });

                                  if (selectedValue != null) {
                                    final parts = selectedValue!.split(' - ');
                                    clinicId = parts[0];
                                    serviceId = '0';
                                    await _postPaciente(
                                        context, clinicId, serviceId);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 320,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.black, width: 0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: DropdownButton<String>(
                                isExpanded:
                                    true, // Ajusta el menú para que ocupe todo el ancho disponible
                                itemHeight: null,
                                isDense:
                                    false, // Permite múltiples líneas para elementos largos
                                hint: const Text('selecciona un servicio'),
                                value: selectedService,
                                borderRadius: BorderRadius.circular(10),
                                dropdownColor: Colors.white,
                                items: _services.map((service) {
                                  final serviceName = service['nombre'];
                                  return DropdownMenuItem<String>(
                                    value: serviceName,
                                    child: Text(
                                      serviceName,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) async {
                                  setState(() {
                                    selectedService = newValue;
                                  });

                                  if (selectedValue != null) {
                                    final parts = selectedValue!.split(' - ');
                                    clinicId = parts[0];

                                    if (newValue != null) {
                                      final selectedServiceMap =
                                          _services.firstWhere(
                                        (service) =>
                                            service['nombre'] == newValue,
                                        orElse: () => {'id': '0'},
                                      );
                                      serviceId =
                                          selectedServiceMap['id'].toString();
                                    }

                                    await _postPaciente(
                                        context, clinicId, serviceId);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: 10), // Espacio entre los DropdownButtons
                        ],
                      )
                    : null, // Oculta ambos dropdowns cuando no se muestran
              ),

              // Añade un botón de flecha para mostrar/ocultar ambos dropdowns juntos
              Padding(
                padding: const EdgeInsets.all(5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showDropdowns = !_showDropdowns;
                    });
                  },
                  child: Icon(
                    _showDropdowns
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: _paciente.length,
                  itemBuilder: (context, index) {
                    final pacienteData = _paciente[index];
                    return buildPacienteWidget(pacienteData);
                  },
                ),
              ),

              // Muestra el número de resultados
              Center(
                  child: Container(
                    width: 150,
                    height: 20,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.deepPurple,
                      ),
                      child: Center(
                        child: Text(
                          'Resultados: ${_paciente.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ))),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPacienteWidget(PacienteDM pacienteData) {
    return Padding(
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
                padding: const EdgeInsets.all(10),
                child: ListTile(
                  title: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.deepPurple,
                      ),
                      child: Text(
                        '${pacienteData.patient_name_short}',
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      )),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(''),
                      Text(
                        'HC: ${pacienteData.clinic_history}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const Text(''),
                      Text(
                        'SERVICIO: ${pacienteData.solicited_service}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'HABITACION: ${pacienteData.room}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'TIPO: ${pacienteData.interconsulting_type_name}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'FECHA Y HORA DE INTERCONSULTA: ${pacienteData.last_notification_at}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const Text(''),
                      Center(
                          child: Text(
                        '${pacienteData.solicited_service}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      const Text(''),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                    '${pacienteData.patient_name_short}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Origen: ${pacienteData.episode_type_name}'),
                  Text('Habitación: ${pacienteData.room ?? ""}'),
                  const SizedBox(
                      height:
                          10), // Espacio entre los datos y el contenido HTML
                  Html(data: pacienteData.description),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
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