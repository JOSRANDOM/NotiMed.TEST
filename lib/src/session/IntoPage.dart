// ignore_for_file: use_build_context_synchronously, file_names, non_constant_identifier_names, prefer_final_fields

import 'package:app_notificador/src/others/IntoPage/Into1.dart';
import 'package:app_notificador/src/others/IntoPage/Into2.dart';
import 'package:app_notificador/src/others/IntoPage/into3.dart';
import 'package:app_notificador/src/session/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntoPage extends StatefulWidget {
  const IntoPage({super.key});

  @override
  State<IntoPage> createState() => _IntoPageState();
}

class _IntoPageState extends State<IntoPage> {
  PageController _Controller = PageController();

  bool onlastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _Controller,
            onPageChanged: (index) {
              setState(() {
                onlastPage = (index == 2);
              });
            },
            children: [IntoPage1(), IntoPage2(), IntoPage3()],
          ),

          //indicador de pestañas
          Container(
              alignment: const Alignment(0, 0.90),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                      onTap: () {
                        _Controller.jumpToPage(2);
                      },
                      child: const Text('OMITIR')),

                  SmoothPageIndicator(controller: _Controller, count: 3),

                  //SIGUIENTE BUTTON
                  // Dentro de la página de introducción, por ejemplo, en el lugar donde el usuario toma la acción de avanzar desde la última diapositiva
                  onlastPage
                      ? GestureDetector(
                          onTap: () async {
                            // Actualiza la variable de estado en SharedPreferences
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setBool('isIntroShown', true);

                            // Navega a la página de inicio de sesión
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return const LoginPage();
                              }),
                            );
                          },
                          child: const Text('INICIAR'))
                      : GestureDetector(
                          onTap: () {
                            _Controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                          },
                          child: const Text('SIGUIENTE'))
                ],
              ))
        ],
      ),
    );
  }
}
