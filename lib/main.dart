import 'package:flutter/material.dart';
import 'package:app_transtunja/screens/conductor/home_conductor.dart';

void main() {
  runApp(const TransTunjaApp());
}

class TransTunjaApp extends StatelessWidget {
  const TransTunjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeConductor(nombreConductor:"danie " ,),
    );
  }
}