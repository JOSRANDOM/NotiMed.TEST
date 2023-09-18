import 'package:flutter/material.dart';

void main() => runApp(const EditCalendar());

class EditCalendar extends StatelessWidget {
  const EditCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: Scaffold(
        body: const Center(
          child:  Text('EDICION DE CALENDARIO'),
        ),
      ),
    );
  }
}