import 'package:app_notificador/src/services/provider.dart';
import 'package:app_notificador/src/services/push_notification_services.dart';
import 'package:app_notificador/src/session/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'src/session/navegatorBar.dart';

void main() async{
    WidgetsFlutterBinding.ensureInitialized();

  // Solicita permisos de notificación
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }

  await PushNotificatonServices.initializeApp();

  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificatonServices.initializeApp();

  // Obtén una instancia de SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Verifica si la sesión está activa
  bool isSessionActive = prefs.getBool('isSessionActive') ?? false;

  String initialRoute = isSessionActive ? '/second' : 'login';

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
          'login': (_) => const LoginPage (),
          '/second': (_) => const homePage(),
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
      print('MyApp: $message' );

    });
  }
  
  @override
  Widget build(BuildContext context) {
    
    throw UnimplementedError();
  }

}
