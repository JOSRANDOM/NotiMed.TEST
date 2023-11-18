// ignore_for_file: unused_element, non_constant_identifier_names, file_names, avoid_unnecessary_containers, avoid_print, unnecessary_string_interpolations, use_build_context_synchronously
import 'dart:convert';

import 'package:app_notificador/src/models/login.dart';
import 'package:app_notificador/src/services/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
//import 'package:flutter_html/flutter_html.dart';

import '../../models/doctor.dart';
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
          'home': (_) => const MedGuard(),
        },
      )));
}

class MedGuard extends StatefulWidget {
  const MedGuard({super.key});

  @override
  State<MedGuard> createState() => _MedShiftState();
}

late Future<List<DoctorDM>> _doctor;

class _MedShiftState extends State<MedGuard> {
  bool _showDropdowns = true;
  String? selectedValue;
  String? selectedService;
  late String clinicId;
  late String serviceId;
  List<DoctorDM> _doctor = [];
  List<Map<String, dynamic>> _services = [];
  late DateTime initAt = DateTime.now();
  late DateTime endAt = DateTime.now().add(const Duration(days: 1));
  final initAtController = TextEditingController();

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

    final initAtString = prefs.getString('init_at');
    final endAtString = prefs.getString('end_at');

    if (initAtString != null && endAtString != null) {
      initAt = DateTime.parse(initAtString);
      endAt = DateTime.parse(endAtString);
      initAtController.text = DateFormat('yyyy-MM-dd').format(initAt);
    }

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

  Future<List<DoctorDM>> _postDoctor(
      BuildContext context, String clinicId, String serviceId) async {
    const url = 'https://notimed.sanpablo.com.pe:8443/api/clinic/schedules';

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
        'init_at': DateFormat('yyyy-MM-dd').format(initAt), // Agregar init_at
        'end_at': DateFormat('yyyy-MM-dd').format(endAt), // Agregar end_at
      },
    );

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      List<DoctorDM> doctores = [];

      if (jsonData['data'] != null) {
        jsonData['data'].forEach((doctorData) {
          doctores.add(DoctorDM(
            doctorData['clinic_name'] ?? '',
            doctorData['clinic_name_short'] ?? '',
            doctorData['clinic_color'] ?? '',
            doctorData['service_id'] ?? '',
            doctorData['service_name'] ?? '',
            doctorData['service_color'] ?? '',
            doctorData['doctor_name'] ?? '',
            doctorData['doctor_color'] ?? '',
            doctorData['init_date_at'] ?? '',
            doctorData['init_hour_at'] ?? '',
            doctorData['end_date_at'] ?? '',
            doctorData['end_hour_at'] ?? '',
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
        _doctor = doctores;
      });

      print('body: ${response.body}');
      print('reques: ${response.request}');
      print('headers: ${response.headers}');
      print('Data from response: ${json.decode(response.body)['data']}');
      print('Data from response: ${json.decode(response.body)['services']}');

      return doctores;
    } else {
      print('Error en la solicitud HTTP: ${response.statusCode}');
      throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
    }
  }

  Future<void> refreshData() async {
    final doctores = await _postDoctor(context, clinicId, serviceId);
    setState(() {
      _doctor = doctores;
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
                          //DROPDOWN - SEDES
                          Container(
                            width: 320,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border:
                                  Border.all(color: Colors.purple, width: 0),
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
                                underline: Container(
                                  // Cambiar el color de la línea debajo del botón desplegable
                                  height: 2,
                                  color: Colors.transparent,
                                ),
                                onChanged: (String? newValue) async {
                                  setState(() {
                                    selectedValue = newValue;
                                    selectedService = null;
                                  });

                                  if (selectedValue != null) {
                                    final parts = selectedValue!.split(' - ');
                                    clinicId = parts[0];
                                    serviceId = '0';
                                    await _postDoctor(
                                        context, clinicId, serviceId);
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          //DROPDOWN - SERVICIOS
                          Container(
                            width: 320,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border:
                                  Border.all(color: Colors.purple, width: 0),
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
                                icon: const Icon(Icons.arrow_drop_down),
                                underline: Container(
                                  // Cambiar el color de la línea debajo del botón desplegable
                                  height: 2,
                                  color: Colors.transparent,
                                ),
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

                                    await _postDoctor(
                                        context, clinicId, serviceId);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: 10), // Espacio entre los DropdownButtons

                          // DatePicker para seleccionar fecha de init_at
                          Container(
                            width: 320,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border:
                                  Border.all(color: Colors.purple, width: 0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: TextField(
                                controller: initAtController,
                                readOnly: true,
                                onTap: () async {
                                  final selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: initAt,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2101),
                                      builder: (context, child) => Theme(
                                            data: ThemeData().copyWith(
                                              colorScheme:
                                                  const ColorScheme.light(
                                                primary: Colors.deepPurple,
                                              ),
                                            ),
                                            child: child ??
                                                const SizedBox(), // Usar un widget vacío si child es nulo
                                          ));
                                  if (selectedDate != null) {
                                    setState(() {
                                      initAt = selectedDate;
                                      endAt = selectedDate
                                          .add(const Duration(days: 1));
                                      initAtController.text =
                                          DateFormat('yyyy-MM-dd')
                                              .format(initAt);
                                    });
                                    // Llama a la función refreshData para actualizar la consulta con la nueva fecha seleccionada
                                    refreshData();
                                  }
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de inicio',
                                  labelStyle: TextStyle(
                                      color: Colors
                                          .deepPurple), // Color del labelText
                                  hintText: 'Seleccione una fecha',
                                  hintStyle: TextStyle(
                                      color: Colors
                                          .deepOrange), // Color del hintText
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.calendar_today,
                                    color: Colors.purple, // Color del icono
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                  itemCount: _doctor.length,
                  itemBuilder: (context, index) {
                    final pacienteData = _doctor[index];
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
                          'Resultados: ${_doctor.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ))),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPacienteWidget(DoctorDM doctorData) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: () {},
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
                        '${doctorData.clinic_name}',
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
                        'Dr: ${doctorData.doctor_name}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const Text(''),
                      Text(
                        'Inicio de Turno ${doctorData.init_hour_at} - ${doctorData.init_date_at}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      const Text(''),
                      Text(
                        'Fin de Turno     ${doctorData.end_hour_at} - ${doctorData.end_date_at}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      const Text(''),
                      Center(
                          child: Text(
                        '${doctorData.service_name}',
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
}
