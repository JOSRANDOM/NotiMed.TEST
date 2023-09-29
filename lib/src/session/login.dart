// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';

//import 'package:app_notificador/src/services/push_notification_services.dart';
//import 'package:app_notificador/src/MVC_HOSP/navegatorBar_HOSP.dart';
import 'package:app_notificador/src/MVC_HOSP/pages/ListPatient_HOSP.dart';
import 'package:app_notificador/src/models/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../MVC_ADM/navegatorBar_ADM.dart';
import '../services/provider.dart';
import 'package:provider/provider.dart';
import '../MVC_MED/navegatorBar_MED.dart';
import '../services/providerVersion.dart';

void main() async {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(ChangeNotifierProvider(
      create: (context) => LoginProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Login",
        initialRoute: 'login',
        routes: {
          'login': (_) => const LoginPage(),
          '/second': (_) => const homePageMD(),
        },
      )));
}

// ignore: must_be_immutable
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  void realizarSolicitudLogin(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    const url = 'https://notimed.sanpablo.com.pe:8443/api/auth/login';

    final usernameDM = usernameController.text;
    final passwordDM = passwordController.text;
    final tokenFB = await FirebaseMessaging.instance.getToken();

    final response = await http.post(Uri.parse(url), body: {
      'username': usernameDM,
      'password': passwordDM,
      'token': tokenFB,
    });

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);

      final serverVersion = responseBody['app_version'];
      final localVersion = GlobalData().version.toString();

      if (serverVersion != localVersion) {
        // Versiones coinciden, continuar con el inicio de sesión
        var name = responseBody['user']['name'];
        var cmp = responseBody['user']['cmp'];
        var tokenFB = await FirebaseMessaging.instance.getToken();
        var dni = responseBody['user']['document_number'];
        var email = responseBody['user']['email'];
        var phone = responseBody['user']['phone'];
        var type_doctor = responseBody['user']['type_doctor'];
        var tokenBD = responseBody['token'];

        final loginData = LoginData(usernameDM, name, cmp, passwordDM, tokenFB,
            dni, email, phone, tokenBD, type_doctor);
        final loginProvider =
            Provider.of<LoginProvider>(context, listen: false);
        loginProvider.setLoginData(loginData);

        // Guardar las credenciales en SharedPreferences
        await prefs.setString('username', usernameDM);
        await prefs.setString('password', passwordDM);
        await prefs.setString('name', name!);
        await prefs.setString('tokenFB', tokenFB!);
        await prefs.setString('document_number', dni);
        await prefs.setString('email', email);
        await prefs.setString('phone', phone);
        await prefs.setString('token', tokenBD!);
        await prefs.setString('cmp', cmp);
        await prefs.setInt('type_doctor', type_doctor);

        await prefs.setBool('isSessionActive', true);

        if (type_doctor == 1) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const homePageMD()));
        } else if (type_doctor == 2) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const homePageADM()));
        } else if (type_doctor == 3) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const ListPatientHOSP()));
        }

        // La solicitud fue exitosa
        // ignore: avoid_print
        print('Inicio de sesión exitoso');
        // ignore: avoid_print
        print('usuario: ${response.body}');
        // ignore: avoid_print
        print(loginData.tokenFB);
        // ignore: avoid_print
        print(loginData.tokenBD);
        // ignore: avoid_print
        print(loginData.name);
      } else {
        // Versiones no coinciden, mostrar mensaje de actualización
        _mostrarMensajeActualizacion(context);
      }
    } else {
      _mostrarAlerta(context);

      // Ocurrió un error en la solicitud
      // ignore: avoid_print
      print('Error: ${response.statusCode}');
      // ignore: avoid_print
      print('Error: ${response.body}');
      // ignore: avoid_print
      print('fallo en conexion');
    }
  }

  void _mostrarMensajeActualizacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Actualizar Aplicación'),
          content: Text('Por favor, actualice la aplicación para continuar.'),
          actions: [
            TextButton(
              onPressed: () {
                // Puedes agregar aquí la lógica para redirigir al usuario a la tienda de aplicaciones para la actualización.
                // Por ejemplo, para Android puedes usar:
                // launch('https://play.google.com/store/apps/details?id=your.package.name');
                Navigator.of(context).pop();
              },
              child: Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarAlerta(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text('USUARIOS INCORRECTO'),
            ],
          ),
          content: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Por favor comunicarse con el área de OCP'),
            ],
          ),
        );
      },
    );
  }

  TextEditingController usernameController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.deepPurple.shade100,
        body: Center(
          // Envuelve el Container en un Center
          child: Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
            ),
            constraints: const BoxConstraints(
              maxWidth: 640,
              maxHeight: 640,
            ),
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Agrega la imagen aquí
                    Image.asset(
                      'lib/src/images/NotiMed.png',
                      width: 150,
                    ),

                    const SizedBox(
                        height: 20), // Espacio entre la imagen y los TextField
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
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
                        labelText: 'usuario',
                        labelStyle: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        labelText: 'contraseña',
                        labelStyle: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(
                            const Size(250, 40)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.deepPurple),
                      ),
                      child: const Text(
                        'Iniciar Sesion',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        realizarSolicitudLogin(context);
                      },
                    ),

                    // Agregar el widget Text para mostrar la versión
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Versión: ${GlobalData().version}',
                        style: const TextStyle(
                          color: Colors
                              .grey, // Puedes ajustar el color según tus preferencias
                          fontSize:
                              14, // Puedes ajustar el tamaño de fuente según tus preferencias
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
