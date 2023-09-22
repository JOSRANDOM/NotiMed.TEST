// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../models/clinic.dart';

class ClinicDropdown extends StatefulWidget {
  final List<Clinic> clinics; // Supongamos que tienes una clase Clinic para representar una clínica
  final Function(Clinic) onChanged;

  const ClinicDropdown({required this.clinics, required this.onChanged});

  @override
  _ClinicDropdownState createState() => _ClinicDropdownState();
}

class _ClinicDropdownState extends State<ClinicDropdown> {
  Clinic? _selectedClinic;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Clinic>(
      value: _selectedClinic,
      onChanged: (Clinic? newValue) {
        setState(() {
          _selectedClinic = newValue;
        });
        widget.onChanged(newValue!);
      },
      items: widget.clinics.map((Clinic clinic) {
        return DropdownMenuItem<Clinic>(
          value: clinic,
          child: Text(clinic.name), // Supongamos que Clinic tiene un campo 'name'
        );
      }).toList(),
      hint: const Text('Selecciona una clínica'),
    );
  }
}
