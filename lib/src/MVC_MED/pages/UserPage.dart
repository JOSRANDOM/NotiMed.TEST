// ignore_for_file: file_names, sized_box_for_whitespace, non_constant_identifier_names

import 'dart:convert';
import 'dart:core';
import 'package:app_notificador/src/models/user.dart';
import 'package:app_notificador/src/utill/Datos_card.dart';
import 'package:app_notificador/src/MVC_MED/navegatorBar_MED.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/login.dart';
import '../../services/provider.dart';
import '../../services/push_notification_services.dart';

Future<void> main() async {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

  runApp(ChangeNotifierProvider(
      create: (context) => LoginProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "NOTIMED - USUARIO",
        initialRoute: 'usuario',
        routes: {
          'usuario': (_) => const UserPage(),
        },
      )));
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificatonServices.initializeApp();
}

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPage();
}

class _UserPage extends State<UserPage> {
  Future<void> _reloadUserData() async {
    setState(() {
      _usuario = _postUsuario();
    });
  }

  @override
  void initState() {
    super.initState();

    PushNotificatonServices.messagesStream.listen((message) {
      // ignore: avoid_print
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


  late Future<List<Usuario>> _usuario;

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

      // ignore: avoid_print
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
      // ignore: avoid_print
      print('body: ${response.body}');
      // ignore: avoid_print
      print('reques: ${response.request}');
      // ignore: avoid_print
      print('headers: ${response.headers}');

      return usuarios;
    } else {
      throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return WillPopScope(
      onWillPop: () async {  
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            children: [
             const SizedBox(height: 20,),
              //app bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //NAME
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: TextStyle(
                            color: Colors.deepPurple.shade200,
                            fontWeight: FontWeight.bold,
                            fontSize: 35 * textScaleFactor,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        FutureBuilder<List<Usuario>>(
                          future: _usuario,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData) {
                              return const Text('No hay datos disponibles');
                            } else {
                              String? nombreUsuario = snapshot.data![0].name;
    
                              return RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight
                                          .bold // Establece el color del texto en blanco
                                      ),
                                  children: [
                                    TextSpan(text: nombreUsuario),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    //profile picture
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const homePageMD()));
                      },
                      child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          child: const Icon(
                            Icons.keyboard_return,
                            color: Colors.white,
                          )),
                    )
                  ],
                ),
              ),
    
              const SizedBox(
                height: 25,
              ),
    
              // card -> bienvenida
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  padding: EdgeInsets.all(20 * textScaleFactor),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      //animacion de usuario
                      Container(
                          height: 100,
                          width: 100,
                          decoration: const BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          child: Image.asset(
                            'lib/src/images/NotiMed.png',
                            width: 50,
                          ) /*Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 50,
                        ),*/
                          ),
                      //texto de bienvenida al app
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Bienvendo a NotiMed,',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18 * textScaleFactor,
                              ),
                            ),
                            Text(
                              'Tu app de notificaciones',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18 * textScaleFactor,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
    
                            //INFORMACION DE LA APLICACION
                            GestureDetector(
                              onTap: () {
                                _IDI(context);
                              },
                              child: Container(
                                width: 150,
                                height: 50,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(20)),
                                  color: Colors.deepPurple.shade100,
                                ),
                                child: const Center(
                                  child: Text(
                                    'Quiero Saber más',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    
              SizedBox(
                height: 25 * textScaleFactor,
              ),
    
              //Lista de datos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Datos del profesional',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20 * textScaleFactor,
                      ),
                    ),
                  ],
                ),
              ),
    
              const SizedBox(
                height: 25,
              ),
    
              Container(
                width: 250,
                height: 350,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Column(
                  children: [
                    // GIF de médico
                    const SizedBox(height: 10),
                    Image.asset(
                        'lib/src/images/b54400b6-9443-4785-8ac1-6d800e4d45f6.gif'),
                    const SizedBox(height: 25),
                    // Lista de datos
                    FutureBuilder<List<Usuario>>(
                      future: _usuario,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData) {
                          return const Text('No hay datos disponibles');
                        } else {
                          String? correoUsuario = snapshot.data![0].email;
                          String? cmpUsuario = snapshot.data![0].cmp;
                          String? celularUsuario = snapshot.data![0].phone;
    
                          return RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                const TextSpan(
                                  text: 'CORREO: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: correoUsuario),
                                const TextSpan(text: '\n'),
                                const WidgetSpan(
                                  child: SizedBox(
                                      height:
                                          20), // Ajusta la altura según tu preferencia
                                ),
                                const TextSpan(
                                  text: 'CMP: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: cmpUsuario),
                                const TextSpan(text: '\n'),
                                const WidgetSpan(
                                  child: SizedBox(
                                      height:
                                          20), // Ajusta la altura según tu preferencia
                                ),
                                const TextSpan(
                                  text: 'CELULAR: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: celularUsuario),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
    
              const SizedBox(
                height: 25,
              ),
    
              Container(
                width: 230,
                height: 100, // Establece el ancho deseado aquí
                child: GestureDetector(
                  onTap: () {
                    _showEditDialog(context);
                  },
                  child: DateCard(
                    dateName: 'Editar Datos',
                    iconImagePath:
                        'lib/src/images/53f0bc35-ab34-439c-8c4f-ad2c887ad57e.gif',
                  ),
                ),
              ),
    
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        )),
      ),
    );
  }

    Future<void> refreshData() async {
    setState(() {
      _usuario = _postUsuario();
    });
  }


//FUNCION DE ACTUALIZAR DATOS
  void _showEditDialog(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? tokenBD = prefs.getString('token');
    if (tokenBD == null) {
      // Handle the case where token is not available
      return;
    }
    // Obtén los datos de usuario de _postUsuario()
    List<Usuario> usuarios = await _postUsuario();
    if (usuarios.isEmpty) {
      // Handle the case where user data is not available
      return;
    }

    var userEmail = usuarios[0].email;
    var userPhone = usuarios[0].phone;

  TextEditingController emailController = TextEditingController(text: userEmail);
  TextEditingController phoneController = TextEditingController(text: userPhone);


    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Editar Información',
            style: TextStyle(color: Colors.deepPurple.shade200),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //INGRESAR NUEVO CORREO
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'email',
                  labelStyle: TextStyle(color: Colors.deepPurple),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              //INGRESAR NUEVO CELULAR
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'phone',
                  labelStyle: TextStyle(color: Colors.deepPurple),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final newEmail = emailController.text;
                final newPhone = phoneController.text;

                final response = await http.post(
                  Uri.parse(
                      'https://notimed.sanpablo.com.pe:8443/api/profile/update'),
                  headers: {
                    'Authorization': 'Bearer $tokenBD',
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode({
                    'email': newEmail,
                    'phone': newPhone,
                  }),
                );

                if (response.statusCode == 200) {
                  // Actualiza los datos del usuario después de la edición
                  await _postUsuario();

                  // Cierra el diálogo
                  refreshData();

                  // ignore: avoid_print
                  print('Data updated successfully');
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  _reloadUserData(); // Call the reload function
                } else {
                  // ignore: avoid_print
                  print('Failed to update data');
                }
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
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
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 10),
            Text('NOTIMED'),
          ],
        ),
        content: const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Qué es?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'NotiMed es una herramienta innovadora que permite presentar un recordatorio por medio de notificaciones, cualesquiera que existan para la gestión o cumplimiento total de un objetivo. Esto significa que ya no habrá dependencia de métodos de comunicación tradicionales, como llamadas telefónicas o papeleo para recibir información crucial. ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '¿Para qué?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'En un primer momento con NotiMed, los médicos pueden recibir notificaciones inmediatas cuando se solicita una interconsulta en emergencia u hospitalización. ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
