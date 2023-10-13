// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void mostrarDialogActualizarApp(BuildContext context) {
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
            Text('ACTUALIZAR APLICACIÓN'),
          ],
        ),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Por favor actualiza la aplicación para continuar.'),
          ],
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple), // Color del botón
              ),
              onPressed: () {
                // Aquí redirige al navegador web al enlace proporcionado
                _launchURL("https://notimed.sanpablo.com.pe:8443");
              },
              child: const Text(
                'Actualizar',
                style: TextStyle(color: Colors.white), // Color del texto
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Función para abrir un enlace web en el navegador
void _launchURL(String url) async {
  final chromeURL = 'googlechrome://$url';

  if (await canLaunch(chromeURL)) {
    await launch(chromeURL);
  } else if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'No se pudo abrir el enlace $url';
  }
}


