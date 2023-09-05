// ignore_for_file: prefer_typing_uninitialized_variables, file_names, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';


class DateCard extends StatelessWidget {
  final  iconImagePath;
  final String dateName;

  DateCard({
    required this.iconImagePath,
    required this.dateName,
  });

  @override
  Widget build(BuildContext context) {
    
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Padding(
      padding:  EdgeInsets.only(left: 25 * textScaleFactor),
      child: Expanded(
        child: Container(
          width: 155,
          height: 155,
          padding:  EdgeInsets.all(12 * textScaleFactor),
          decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12))
          ),
          
          child: Row(
            children: [
              Image.asset(
                iconImagePath,
                height: 50,
              ),
              SizedBox(
                width: 2,
              ),
              Text(dateName,style: TextStyle(fontSize: 15),),
            ],
          ),
        ),
      ),
    );
  }
}
