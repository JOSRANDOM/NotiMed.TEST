// ignore_for_file: file_names, use_build_context_synchronously, avoid_print, non_constant_identifier_names, deprecated_member_use

import 'dart:convert';

import 'package:app_notificador/src/pages/ListPatient.dart';
import 'package:app_notificador/src/pages/UserPage.dart';
import 'package:app_notificador/src/services/provider.dart';
import 'package:app_notificador/src/pages/ConsultationPage.dart';
//import 'package:app_notificador/src/pages/PendingPage.dart';
import 'package:app_notificador/src/session/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../models/login.dart';
import '../models/user.dart';
import '../pages/HomePage.dart';
import '../services/push_notification_services.dart';
//import 'package:url_launcher/url_launcher.dart';
 
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
          'home': (_) => const homePage(),
          'login': (_) => const LoginPage(),
        },
      )));
}

// ignore: camel_case_types
class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _homePage createState() => _homePage();
}

// ignore: camel_case_types
class _homePage extends State<homePage> {
  late Future<List<Usuario>> _usuario;

  @override
  void initState() {
    super.initState();

    PushNotificatonServices.messagesStream.listen((message) {
      print('MyApp: $message');
    });
    _usuario = _postUsuario();
    _loadLoginData();
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

    if (username != null &&
        name != null &&
        tokenBD != null &&
        password != null &&
        tokenFB != null &&
        dni != null &&
        phone != null) {
      final loginData = LoginData(
          username, name, tokenBD, password, tokenFB, dni, phone, cmp, email);
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

      //jsonData['data'].values.forEach((data) {
      //if (data['data'] != null) {

      usuarios.add(Usuario(
        jsonData['data']['name'],
        jsonData['data']['cmp'],
        jsonData['data']['document_number'],
        jsonData['data']['email'],
        jsonData['data']['phone'],
      ));
      //}
      //});
      print('body: ${response.body}');
      print('reques: ${response.request}');
      print('headers: ${response.headers}');

      return usuarios;
    } else {
      throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        initialIndex: 1, //LLAMAR A HOME COMO PAGINA PRINCIPAL
        length: 3, //DETERMINAS CUANTAS PAGINAS SERAN
        child: Scaffold(
          /*floatingActionButton: FloatingActionButton(
                      onPressed: () {
            _WhatsAppSG();
          },
          backgroundColor: Colors.white,
          child: Image.asset('lib/src/images/fdd89706e35f9bc4493559caef4f1122.png'),
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
                        const TextSpan(
                          text: 'Dr. ',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 18,
                          ),
                        ),
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

               //PAGINA INTERCONSULTAS
                Tab(
                  icon: Icon(
                    Icons.bookmark, color: Colors.deepPurple,
                  ),
                ),

                //PAGINA DE INICIO - HORARIO DEL PERSONNAL
                Tab(
                  icon: Icon(Icons.home, color: Colors.deepPurple),
                ),


                //PAGINA DE PACINETES HOSPITALIZADOS - INACTIVO POR AHORA
                Tab(
                  icon: Icon(Icons.person_pin_sharp, color: Colors.deepPurple),
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
                  /*const Text(
                    'SAN PABLO - NOTIMED',
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),*/
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
                      decoration: const  BoxDecoration(
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
                      _IDI(context);
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
                      _logout(context);
                      // Lógica que deseas ejecutar cuando se toque el Container
                      // Por ejemplo, cerrar la sesión del usuario
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
            children: [ Interconsulta(),Home(), ListPatient()], // DEFINES LAS PAGINAS
          ),
        ),
      ),
    );
  }

/*void _WhatsAppSG() async {
  const phoneNumber = "+51972990952"; // Reemplaza con el número de teléfono deseado

  String url = "whatsapp://send?phone=$phoneNumber";

  launchUrl(Uri.parse(url));

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print('error al hipervincular');
  }
}*/

}

Future<void> _logout(BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.clear(),
      DefaultCacheManager().emptyCache(),
      FirebaseMessaging.instance.deleteToken(),
    ]);

    context.read<LoginProvider>().setLoginData(null);

    // Utilizar Navigator.popUntil para eliminar todas las rutas anteriores
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

              //DESARROLLADORES Y RESPONSABLES DE LA CREACION DEL APLICATIVO
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

              //LICENCIA DE DERECHOS DE AUTOR
              Text('Copyright © 2023 Grupo San Pablo - Investigación,Desarrollo e Innovación', 
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10),
                ),
            ],
          ),
        ),
      );
    },
  );
}
