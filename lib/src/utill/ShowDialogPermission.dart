  // ignore_for_file: non_constant_identifier_names, file_names, avoid_print


import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void ShowDialogPermission(BuildContext context) async {
    try {
      // Mostrar un cuadro de diálogo de confirmación
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Permisos Requeridos"),
            content: const Text("Por su seguridad, solicitamos permisos de notificacion"),
            actions: [
              TextButton(
                child: const Text("aceptar"),
                onPressed: () async {
                  requestPermissions();
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

  Future<void> requestPermissions() async {
  final permissions = [
    Permission.notification,
    Permission.systemAlertWindow,
    Permission.accessNotificationPolicy,
  ];

  await permissions.request();
}