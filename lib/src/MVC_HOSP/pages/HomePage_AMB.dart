// ignore_for_file: avoid_print, use_build_context_synchronously, prefer_const_constructors, sized_box_for_whitespace, non_constant_identifier_names

import 'dart:convert';
import 'dart:core';
import 'package:app_notificador/src/models/turno.dart';
import 'package:http/http.dart' as http;
// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../../models/login.dart';
import '../../services/provider.dart';
import '../../services/push_notification_services.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificatonServices.initializeApp();


  runApp(
    ChangeNotifierProvider(
      create: (context) => LoginProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "NOTIMED",
        initialRoute: 'home',
        routes: {
          'home': (_) => const Home(),
        },
      ),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late DateTime _selectedDay;
  final Map<String, List<Turno>> _groupedTurnos = {}; // Agregado

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _initializeData(); // Llamar a la función para inicializar los datos
    PushNotificatonServices.messagesStream.listen((message) {
      print('MyApp: $message');
    });
  }

  Future<void> _initializeData() async {
    await _loadLoginData(); // Esperar a que _loadLoginData se complete
    // Aquí puedes realizar otras operaciones de inicialización
  }

  Future<String?> _loadLoginData() async {
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
    int? type_doctor = prefs.getInt('type_doctor');

    if (username != null &&
        name != null &&
        tokenBD != null &&
        password != null &&
        tokenFB != null &&
        dni != null &&
        phone != null) {
      final loginData = LoginData(
          username, name, tokenBD, password, tokenFB, dni, phone, cmp, email, type_doctor!);
      context.read<LoginProvider>().setLoginData(loginData);
    }
    return tokenBD;
  }

  Future<void> _postTurnoConFecha(
      BuildContext context, DateTime fechaSeleccionada) async {
    const url = 'https://notimed.sanpablo.com.pe:8443/api/schedules';

    final String? tokenBD = await _loadLoginData();

    final response = await http.post(Uri.parse(url), headers: {
      'Authorization': 'Bearer $tokenBD',
    }, body: {
      'date_at': DateFormat('yyyy-MM-dd').format(fechaSeleccionada),
    });

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      for (var element in jsonData['data']) {
        String initDate = element['init_date_at'];

        if (isSameDay(DateTime.parse(_formatDate(initDate)), _selectedDay)) {
          String clinicName = element['clinic_name'];

          _handleTurnoData(clinicName, element);
        }
      } 
    } else {
      // Manejar otros códigos de estado aquí si es necesario
      print('Error en la solicitud HTTP: ${response.statusCode}');
      throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
    }
  }

  void _handleTurnoData(String clinicName, Map<String, dynamic> element) {
    if (!_groupedTurnos.containsKey(clinicName)) {
      _groupedTurnos[clinicName] = [];
    }

    _groupedTurnos[clinicName]?.add(Turno(
      clinicName,
      element['clinic_name_short'],
      element['clinic_color'],
      element['service_name'],
      element['init_date_at'],
      element['init_hour_at'],
      element['end_date_at'],
      element['end_hour_at'],
    ));
  }

  // Function to refresh the data and update the UI
  Future<List<Widget>> refreshData() async {
    _groupedTurnos.clear();
    await _loadLoginData();
    await _postTurnoConFecha(context, _selectedDay);

    // Generar los widgets después de realizar las operaciones asincrónicas
    List<Widget> turnoCards = _groupedTurnos.entries
        .map((entry) => _buildClinicTurnos(entry.key, entry.value))
        .toList();

    // Puedes regresar la lista de widgets directamente, o simplemente actualizar el estado con setState si estás en un StatefulWidget.
    return turnoCards;
  }

  String _formatDate(String inputDate) {
    final dateParts = inputDate.split('/');
    final day = dateParts[0].padLeft(2, '0');
    final month = dateParts[1].padLeft(2, '0');
    final year = dateParts[2];
    return '$year-$month-$day';
  }

  Widget _buildClinicTurnos(String clinicName, List<Turno> turnos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: turnos.length,
          itemBuilder: (context, index) {
            return _buildTurnoCard(context,
                turnos[index]); // Pasar el contexto y el turno correctos
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NOTIMED',
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                ),
                child: TableCalendar(
                  locale: 'es_Es',
                  focusedDay: _selectedDay,
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'mes',
                    CalendarFormat.week: 'semana',
                  },
                  headerStyle: HeaderStyle(
                    headerPadding: EdgeInsets.zero,
                    formatButtonVisible: false,
                    titleTextFormatter: (DateTime date, dynamic locale) {
                      return DateFormat.MMMM(locale)
                          .format(date); // Mostrar solo el nombre del mes
                    },
                    titleTextStyle:
                        const TextStyle(color: Colors.deepPurple, fontSize: 20),
                    titleCentered: true,
                    leftChevronIcon: const Icon(Icons.chevron_left,
                        color: Colors
                            .deepPurple), // Cambiar el color de la flecha izquierda
                    rightChevronIcon: const Icon(Icons.chevron_right,
                        color: Colors
                            .deepPurple), // Cambiar el color de la flecha derecha
                  ),
                  calendarStyle: CalendarStyle(
                      outsideDaysVisible: true,
                      selectedDecoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(color: Colors.white),
                      todayDecoration: BoxDecoration(
                          color: Colors.deepPurple.shade200,
                          shape: BoxShape.circle)),
                  onDaySelected: (fechaSeleccionada, _) {
                    setState(() {
                      _selectedDay = fechaSeleccionada;
                    });
                    refreshData; // Obtener datos para la nueva fecha seleccionada
                  },
                ),
              ),
            ),
            Expanded(
              child: LiquidPullToRefresh(
                onRefresh: refreshData,
                color: Colors.white,
                backgroundColor: Colors.deepPurple,
                height: 100,
                animSpeedFactor: 2,
                showChildOpacityTransition: false,
                child: FutureBuilder(
                  future: refreshData(), // Llamada a refreshData solo aquí
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.purple),
                        ),
                      );
                    } else if (snapshot.hasError) {
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
                            SizedBox(
                                height:
                                    20), // Espacio entre la animación y el texto
                            Text(
                              'SIN CONEXIÓN', // Mensaje de texto
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return ListView.builder(
                        // Usar ListView.builder para una mejor eficiencia
                        itemCount: _groupedTurnos.length,
                        itemBuilder: (context, index) {
                          var clinicName = _groupedTurnos.keys.elementAt(index);
                          var turnos = _groupedTurnos[clinicName];
                          return _buildClinicTurnos(clinicName, turnos!);
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildTurnoCard(BuildContext context, Turno turnoData) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: IntrinsicHeight(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                child: Row(
                  children: [
                    Text(
                      ' ${turnoData.init_date_at}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 100),
                    Flexible(
                      child: Text(
                        ' ${turnoData.clinic_name}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 5),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      ' ${turnoData.service_name}',
                      style: TextStyle(
                        color: Colors.deepPurple.shade300,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2, // Cambia a la cantidad de líneas deseada
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 5),
              child: Row(
                children: [
                  const SizedBox(width: 30),
                  Text(
                    ' ${turnoData.init_hour_at} - ${turnoData.end_hour_at}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
