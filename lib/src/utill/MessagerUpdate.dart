  // ignore_for_file: unused_element, file_names

  import 'package:flutter/material.dart';

void mostrarVersionIncorrecta(BuildContext context, String apiVersion) {
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
            Text('VERSIÓN INCORRECTA'),
          ],
        ),
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('La versión de la aplicación no coincide con la versión del servidor.'),
            Text('Por favor, actualice la aplicación.'),
          ],
        ),
      );
    },
  );
}
