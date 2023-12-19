  // ignore_for_file: non_constant_identifier_names, file_names, avoid_print

  import 'package:app_notificador/src/utill/Logout.dart';
import 'package:flutter/material.dart';

void ShowDialogLogout(BuildContext context) async {
    try {
      // Mostrar un cuadro de diálogo de confirmación
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirmar Cierre de Sesión"),
            content: const Text("¿Está seguro de que desea cerrar la sesión?"),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el cuadro de diálogo
                },
              ),
              TextButton(
                child: const Text("Confirmar"),
                onPressed: () async {
                  logout(context);
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error durante el cierre de sesión: $e");
    }
  }