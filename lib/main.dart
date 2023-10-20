// ignore_for_file: unnecessary_import

import 'package:app_notificador/src/services/provider.dart';
import 'package:app_notificador/src/services/providerVersion.dart';
import 'package:app_notificador/src/services/push_notification_services.dart';
import 'package:app_notificador/src/session/login.dart';
import 'package:app_notificador/src/utill/ShowDialogUpdate.dart';
import 'package:app_notificador/src/utill/version%20management/Version.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

//import 'package:permission_handler/permission_handler.dart';

import 'src/MVC_ADM/navegatorBar_ADM.dart';
import 'src/MVC_HOSP/pages/ListPatient_HOSP.dart';
import 'src/MVC_MED/navegatorBar_MED.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificatonServices.initializeApp();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    final prefs = await SharedPreferences.getInstance();
    final savedTypeDoctor = prefs.getInt('type_doctor');
    Widget initialPage = const LoginPage();

    if (savedTypeDoctor != null) {
      if (savedTypeDoctor == 1) {
        initialPage = const homePageMD();
      } else if (savedTypeDoctor == 2) {
        initialPage = const homePageADM();
      } else if (savedTypeDoctor == 3) {
        initialPage = const ListPatientHOSP();
      } else {
        // Handle any other profile type here or redirect to a default page
      }
    } else {
      initialPage = const LoginPage();
    }

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Builder(
            builder: (context) {
              // Realizar la validación de la versión antes de continuar
              const VersionAPI().validateAppVersion(context).then((versionMatch) {
                if (!versionMatch) {
                  // Mostrar cuadro de diálogo de actualización y no iniciar la aplicación
                  mostrarDialogActualizarApp(context);
                } else {
                  initializeDateFormatting().then((_) {
                    runApp(
                      MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                              create: (context) => GlobalData()),
                          ChangeNotifierProvider(
                              create: (context) => VersionProvider()),
                          ChangeNotifierProvider(
                              create: (context) => LoginProvider()),
                        ],
                        child: MaterialApp(
                          debugShowCheckedModeBanner: false,
                          title: "NOTIMED",
                          home: initialPage,
                        ),
                      ),
                    );
                  });
                }
              });

              return Center(
                child: Container(
                  color: Colors.white, // Fondo blanco
                  padding: const EdgeInsets.all(
                      16.0), // Ajusta el espacio alrededor del CircularProgressIndicator
                  child: const Column(
                    mainAxisSize:
                        MainAxisSize.min, // Alinea el contenido verticalmente
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.deepPurple), // Color del indicador
                        strokeWidth: 2.0, // Grosor del indicador
                      ),
                      SizedBox(
                          height: 10), // Espacio entre el indicador y el texto
                      Text("Buscando nuevas versiones",
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  });
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    PushNotificatonServices.messagesStream.listen((message) {
      // ignore: avoid_print
      print('MyApp: $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
