import 'package:app_notificador/src/services/provider.dart';
import 'package:app_notificador/src/services/push_notification_services.dart';
import 'package:app_notificador/src/session/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:permission_handler/permission_handler.dart';

import 'src/MVC_ADM/navegatorBar_ADM.dart';
import 'src/MVC_HOSP/pages/ListPatient_HOSP.dart';
import 'src/MVC_MED/navegatorBar_MED.dart';

void main() async{
    WidgetsFlutterBinding.ensureInitialized();
  await PushNotificatonServices.initializeApp();

  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificatonServices.initializeApp();
 
  // Obtén una instancia de SharedPreferences

  final prefs = await SharedPreferences.getInstance();
  final savedTypeDoctor = prefs.getInt('type_doctor');
  Widget initialPage = const LoginPage(); // Valor por defecto

    if (savedTypeDoctor != null) {
    // Si hay un tipo de perfil almacenado, redirige directamente a la página correspondiente
    if (savedTypeDoctor == 1) {
      initialPage = const homePageMD();
    } else if (savedTypeDoctor == 2) {
      initialPage = const homePageADM();
    } else if (savedTypeDoctor == 3) {
      initialPage = const ListPatientHOSP();
    } else {
      // Maneja cualquier otro tipo de perfil aquí o redirige a una página predeterminada
    }
  }else {
    // Si no se ha almacenado ningún tipo de perfil, muestra la página de inicio de sesión
    initialPage = const LoginPage();
  }

  initializeDateFormatting().then((_) =>   
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginProvider()),
        Provider(create: (context) => PushNotificatonServices()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "NOTIMED",
        home: initialPage,
      ),
    ),
  ));

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
      print('MyApp: $message' );

    });
  }
  
  @override
  Widget build(BuildContext context) {
    
    throw UnimplementedError();
  }

}

