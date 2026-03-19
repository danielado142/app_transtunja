import 'package:flutter/material.dart';
import 'admin_dashboard.dart'; // Tu dashboard real

class AdminInicio extends StatelessWidget {
  const AdminInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Módulo Administrativo")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navegas a tu trabajo real sin tocar el main.dart
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          },
          child: const Text("Entrar a mi módulo"),
        ),
      ),
    );
  }
}
