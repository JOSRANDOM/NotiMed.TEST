  import 'package:flutter/material.dart';

void IDI(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.deepPurple),
              SizedBox(width: 10),
              Text(
                '¿Quiénes somos?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '-Investigación, Desarrollo e Innovación (IDI)-',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(''),
                Text('Líder de Proyecto: Renzo Silva'),
                Text(''),
                Text('Desarrollador: Joseph Mori'),
                Text(''),
                Text(
                  '-Una división de Informática Biomédica- ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(''),
                Text('Jefe de Área: Oscar Huapaya'),
                Text(''),
                Text(
                  '-En colaboración con las siguientes áreas-',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(''),
                Text('Backend: Christopher Vergara - HOSMED'),
                Text(''),
                Text('Desing: Andrea Agreda - HCE'),
                Text(''),
                Text(''),
                Text(''),
                Text(
                  'Copyright © 2023 Grupo San Pablo - Investigación,Desarrollo e Innovación',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }