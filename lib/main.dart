import 'package:app_notificador/src/services/provider.dart';
import 'package:app_notificador/src/services/push_notification_services.dart';
import 'package:app_notificador/src/session/IntoPage.dart';
import 'package:app_notificador/src/session/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:permission_handler/permission_handler.dart';

import 'src/session/navegatorBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
/*
  // Solicita permisos de notificación
  final notificationStatus = await Permission.notification.status;
  if (!notificationStatus.isGranted) {
    await Permission.notification.request();
  }


  // Solicita permisos de systemAlertWindows
  final windowsStatus = await Permission.systemAlertWindow.status;
  if (!windowsStatus.isGranted) {
    await Permission.systemAlertWindow.request();
  }
*/
  // Obtén una instancia de SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await PushNotificatonServices.initializeApp();

  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificatonServices.initializeApp();

  // Verifica si la página de introducción ya se ha mostrado antes
  bool isIntroShown = prefs.getBool('isIntroShown') ?? false;

  // Decide qué ruta inicial mostrar
  String initialRoute = isIntroShown ? 'login' : '/intro';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginProvider()),
        Provider(create: (context) => PushNotificatonServices()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "NOTIMED",
        initialRoute: initialRoute,
        routes: {
          'login': (_) => const LoginPage(),
          '/second': (_) => const homePage(),
          '/intro': (_) =>const IntoPage(), // Agrega la ruta de la página de introducción
        },
      ),
    ),
  );
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
