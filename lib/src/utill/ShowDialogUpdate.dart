  // ignore_for_file: file_names

  import 'package:flutter/material.dart';

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
        ));
      });
    }


    