// ignore_for_file: file_names, camel_case_types, library_private_types_in_public_api, avoid_print, non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';
import 'package:app_notificador/src/MVC_ADM/PAGE_ADM/ConsultationPage_ADM.dart';
import 'package:app_notificador/src/MVC_ADM/PAGE_ADM/ListPatient_ADM.dart';
import 'package:app_notificador/src/MVC_MED/pages/UserPage.dart';
import 'package:app_notificador/src/services/provider.dart';
import 'package:app_notificador/src/session/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../models/login.dart';
import '../models/user.dart';
import '../services/push_notification_services.dart';

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
          'login': (_) => const LoginPage(),
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
    secureScreen();
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

  secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_KEEP_SCREEN_ON);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          //BOTON FLOTANTE
         /* floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Botón principal que controla la expansión
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded; // Cambiar el estado de expansión
                  });
                },
                backgroundColor: Colors.white, // Color de fondo blanco
                foregroundColor: Colors.black, // Color del icono negro
                tooltip: 'Mostrar/Ocultar',
                child: Icon(isExpanded
                    ? Icons.close
                    : Icons.add), // Cambiar el ícono según el estado
              ),
              SizedBox(height: 16.0), // Espacio entre los botones flotantes

              // Botón 1 - Editar Calendario
              AnimatedContainer(
                duration:
                    Duration(milliseconds: 300), // Duración de la animación
                height: isExpanded
                    ? 56.0
                    : 0.0, // Altura 0 para ocultar, 56 para mostrar
                child: Visibility(
                  visible: isExpanded, // Controlar la visibilidad
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditCalendar()));
                    },
                    backgroundColor: Colors.white, // Color de fondo blanco
                    foregroundColor: Colors.black, // Color del icono negro
                    tooltip: 'Editar Calendario',
                    child: Icon(Icons.calendar_month),
                  ),
                ),
              ),
              SizedBox(height: 16.0), // Espacio entre los botones flotantes

              // Botón 2 - Messenger SP
              AnimatedContainer(
                duration:
                    Duration(milliseconds: 300), // Duración de la animación
                height: isExpanded
                    ? 56.0
                    : 0.0, // Altura 0 para ocultar, 56 para mostrar
                child: Visibility(
                  visible: isExpanded, // Controlar la visibilidad
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MessagerSP()));
                    },
                    backgroundColor: Colors.white, // Color de fondo blanco
                    foregroundColor: Colors.black, // Color del icono negro
                    tooltip: 'Messenger SP',
                    child: Icon(Icons.message),
                  ),
                ),
              ),
            ],
          ),*/

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
                          text: 'usuarios adminstrativo',
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
            bottom: const TabBar(
              indicatorColor: Colors.deepPurple,
              unselectedLabelColor: Colors.orange,
              tabs: [
                Tab(
                  icon: Icon(Icons.bookmark, color: Colors.deepPurple),
                  child: Text(
                    'INTERCONSULTAS',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 12,
                    ),
                  ),
                ),
                Tab(
                  icon: Icon(Icons.person_pin_sharp, color: Colors.deepPurple),
                  child: Text(
                    'HOSPITALIZACION',
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
                      _IDI(context);
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
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      _IDI(context);
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
                            'Registro de Horario',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Icon(
                            Icons.add_circle_rounded,
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
                      _logout(context);
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
          body: const TabBarView(
            children: [InterconsultaADM(), ListPatientADM()],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.clear(),
        DefaultCacheManager().emptyCache(),
        FirebaseMessaging.instance.deleteToken(),
      ]);

      context.read<LoginProvider>().setLoginData(null);

      Navigator.popUntil(context, (route) => route.isFirst);

      Navigator.pushReplacementNamed(context, 'login');
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  void _IDI(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.deepPurple),
              SizedBox(width: 10),
              Text(
                '¿Quiénes somos?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '-Investigación, Desarrollo e Innovación (IDI)-',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(''),
                Text('Líder de Proyecto: Renzo Silva'),
                Text(''),
                Text('Desarrollador: Joseph Mori'),
                Text(''),
                Text(
                  '-Una división de Informática Biomédica- ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(''),
                Text('Jefe de Área: Oscar Huapaya'),
                Text(''),
                Text(
                  '-En colaboración con las siguientes áreas-',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(''),
                Text('Backend: Christopher Vergara - HOSMED'),
                Text(''),
                Text('Desing: Andrea Agreda - HCE'),
                Text(''),
                Text(''),
                Text(''),
                Text(
                  'Copyright © 2023 Grupo San Pablo - Investigación,Desarrollo e Innovación',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
