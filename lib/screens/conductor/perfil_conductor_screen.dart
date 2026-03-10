import 'package:flutter/material.dart';

class PerfilConductorScreen extends StatelessWidget {
  const PerfilConductorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Perfil del conductor",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}