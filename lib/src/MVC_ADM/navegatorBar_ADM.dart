// ignore_for_file: file_names, camel_case_types, library_private_types_in_public_api, avoid_print, non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';
//import 'package:app_notificador/src/MVC_ADM/PAGE_ADM/Med_Guard.dart';
import 'package:app_notificador/src/services/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/login.dart';
import '../models/user.dart';
import '../services/push_notification_services.dart';
import '../utill/IDI.dart';
import '../utill/ShowDialogComplete.dart';
import '../utill/ShowDialogLogout.dart';

import 'PAGE_ADM/Global_Interconsultation.dart';
import 'PAGE_ADM/ListPatient_ADM.dart';
import 'PAGE_ADM/UserPageADM.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  await PushNotificatonServices.initializeApp();

  runApp(ChangeNotifierProvider(
      create: (context) => LoginProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "NOTIMED - HOME",
        initialRoute: 'home',
        routes: {
          'home': (_) => const homePageADM(),
        },
      )));
}

class homePageADM extends StatefulWidget {
  const homePageADM({Key? key}) : super(key: key);

  @override
  _homePageADM createState() => _homePageADM();
}

class _homePageADM extends State<homePageADM> {
  late Future<List<Usuario>> _usuario;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();

    PushNotificatonServices.messagesStream.listen((message) {
      print('MyApp: $message');
    });
    _usuario = _postUsuario();
    _loadLoginData();
    //secureScreen();
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

      if (jsonData['data']['email'] == null ||
          jsonData['data']['email'] == '' ||
          jsonData['data']['phone'] == null ||
          jsonData['data']['phone'] == '') {
        // Email o phone está vacío o nulo, mostrar un ShowDialog
        ShowDialogComplete(context);
      }

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
/*
  secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    await FlutterWindowManager.addFlags(
        FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
  }*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
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
                        ],
                      ),
                    );
                  } else {
                    return const Text('No data');
                  }
                },
              ),
              bottom: const TabBar(
                indicatorColor: Colors.deepPurple,
                unselectedLabelColor: Colors.orange,
                tabs: [
                  //PAGINA DE GUARDIAS
                  /*
                  Tab(
                    icon: Icon(Icons.calendar_month, color: Colors.deepPurple),
                    child: Text(
                      'GUARDIAS',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 12,
                      ),
                    ),
                  ),
*/
                  //PAGINA DE INTERCONSULTAS
                  Tab(
                    icon: Icon(Icons.add_alert_sharp, color: Colors.deepPurple),
                    child: Text(
                      'INTERCONSULTAS EMG',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 12,
                      ),
                    ),
                  ),
                                    //PAGINA DE INTERCONSULTAS
                  Tab(
                    icon: Icon(Icons.add_home_work_rounded, color: Colors.deepPurple),
                    child: Text(
                      'INTERCONSULTAS HOSP',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              elevation: 0.0,
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
                                builder: (context) => const UserPageADM()));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 30),
                        padding: const EdgeInsets.all(20),
                        width: 300,
                        decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'DATOS DEL USUARIO',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            Icon(
                              Icons
                                  .account_circle_rounded, // Cambia Icons.add_circle con el icono que desees utilizar
                              color: Colors
                                  .white, // Cambia Colors.blue con el color deseado para el icono
                              size:
                                  24, // Ajusta el tamaño del icono según tus necesidades
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '¿Quiénes Somos?',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            Icon(
                              Icons
                                  .co_present_rounded, // Cambia Icons.add_circle con el icono que desees utilizar
                              color: Colors
                                  .white, // Cambia Colors.blue con el color deseado para el icono
                              size:
                                  24, // Ajusta el tamaño del icono según tus necesidades
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                    GestureDetector(
                      onTap: () {
                        ShowDialogLogout(context);
                        // Lógica que deseas ejecutar cuando se toque el Container
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(20),
                        width: 250,
                        decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        alignment: Alignment.center,
                        child: const Text(
                          'CERRAR SESIÓN',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            body: const TabBarView(
              children: [/*MedGuard(),*/ MedShift(), ListPatientADM()],
            ),
          ),
        ),
      ),
    );
  }
}
