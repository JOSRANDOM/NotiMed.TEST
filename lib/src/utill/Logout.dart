  // ignore_for_file: use_build_context_synchronously, avoid_print, file_names

  import 'package:app_notificador/src/services/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void logout(BuildContext context) async {
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