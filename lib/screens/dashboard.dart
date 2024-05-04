import 'package:flutter/material.dart';

class Dashbaord extends StatefulWidget {
  const Dashbaord({Key? key}) : super(key: key);

  @override
  State<Dashbaord> createState() => _DashbaordState();
}

class _DashbaordState extends State<Dashbaord> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:Text(
          "Dashboard"
        )
      ),
    );
  }
}
