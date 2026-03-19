import 'package:flutter/material.dart';
import 'package:app_transtunja/screens/administrador/crear_ruta.dart';
import 'package:app_transtunja/screens/administrador/historial_rutas.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: const Text(
          'ADMIN DASHBOARD',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      backgroundColor: const Color(0xffefefef),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Crear ruta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CrearRuta()),
                  );
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('Historial de rutas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistorialRutas(),
                    ), // Solucionado el typo aquí
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
