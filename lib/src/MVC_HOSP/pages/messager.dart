// ignore_for_file: unnecessary_const

import 'package:flutter/material.dart';

void main() => runApp(const MessagerSP());

class MessagerSP extends StatelessWidget {
  const MessagerSP({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: Scaffold(
        body: const Center(
          child:  Text('MENSAJERIA INTERNA'),
        ),
      ),
    );
  }
}