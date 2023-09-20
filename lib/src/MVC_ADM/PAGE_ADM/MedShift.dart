// ignore_for_file: file_names

import 'package:flutter/material.dart';

void main() => runApp(const MedShift());

class MedShift extends StatelessWidget {
  const MedShift({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NOTIMED',
      home: Scaffold(
        body: Center(
          child: Text('LISTA MEDICOS DE TURNO'),
        ),
      ),
    );
  }
}