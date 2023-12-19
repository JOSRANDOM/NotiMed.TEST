// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void ShowDialogComplete(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? tokenBD = prefs.getString('token');
    if (tokenBD == null) {
      // Handle the case where token is not available
      return;
    }
  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController phoneController = TextEditingController(text: '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Ingresar Información Faltante',
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
                  // ignore: avoid_print
                  print('Data updated successfully');

                  Navigator.of(context).pop();// Call the reload function
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
          ],
        );
      },
    );
  }