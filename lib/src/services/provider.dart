import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
// ignore: unnecessary_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/login.dart';

class LoginProvider with ChangeNotifier {
  LoginData? _loginData;

   get loginData => _loginData;

Future<void> loadLoginData(BuildContext context) async  {

    const url =
        'https://notimed.sanpablo.com.pe:8443/api/auth/login'; // Reemplaza con la URL de tu endpoint de inicio de sesión en localhost

    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final username = loginProvider.loginData?.username;
    final password = loginProvider.loginData?.password;
    final tokenFB = await FirebaseMessaging.instance.getToken();


    final response = await http.post(Uri.parse(url), body: {
      'username' :username ,
      'password' : password,
      'token' : tokenFB,
    });

    if (response.statusCode == 200) {

      final responseBody = json.decode(response.body);
      var username = '';
      var passwordDM = '';
      var name = responseBody['user']['name'];
      var cmp= responseBody['user']['cmp'];
      var tokenFB= await FirebaseMessaging.instance.getToken();
      var dni =  responseBody['user']['document_number'];
      var email =  responseBody['user']['email'];
      var phone =  responseBody['user']['phone'];
      var tokenBD =  responseBody['token'];

     final loginData = LoginData(username, name,cmp,passwordDM , tokenFB, dni, email, phone,tokenBD );
      // ignore: use_build_context_synchronously
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      loginProvider.setLoginData(loginData);

      // Guardar los datos de inicio de sesión en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString( 'username', username);
      await prefs.setString( 'password', passwordDM);
      await prefs.setString( 'name', name!);
      await prefs.setString( 'tokenFB', tokenFB!);
      await prefs.setString('document_number', dni );
      await prefs.setString('email', email );
      await prefs.setString('phone', phone );
      await prefs.setString('token', tokenBD!);
      await prefs.setString('cmp', cmp );
      await prefs.setBool('isSessionActive', true);


      // ignore: avoid_print
      print('conexion establecida');
      // ignore: avoid_print
      print(name);
      
    } else {

      // Ocurrió un error en la solicitud
      // ignore: avoid_print
      print('Error: ${response.statusCode}');
      // ignore: avoid_print
      print('fallo en conexion');
    }
  }

  void setLoginData(LoginData? loginData) {
    
    _loginData = loginData;

    notifyListeners();
  }

}
