// ignore_for_file: use_build_context_synchronously, avoid_print, file_names

import 'package:app_notificador/src/services/provider.dart';
import 'package:app_notificador/src/session/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void logout(BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Eliminar todos los datos guardados en SharedPreferences
    await prefs.clear();

    context.read<LoginProvider>().setLoginData(null);

    // Elimina el token de Firebase Messaging u otros datos de sesión específicos
    // Asegúrate de que la clave sea la misma que se usó para guardar el token durante el inicio de sesión.
    await FirebaseMessaging.instance.deleteToken();

    Navigator.popUntil(context, (route) => route.isFirst);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  } catch (e) {
    print("Error during logout: $e");
  }
}

