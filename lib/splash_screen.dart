import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Espaciador superior para empujar el logo al centro
              const SizedBox(height: 20),
              
              // Logo central (imagen con el bus y los pins de ubicación)
              Center(
                child: Image.asset(
                  'assets/images/transtunja_logo.png', // Asegúrate que la ruta sea correcta
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.directions_bus, size: 100, color: Colors.red);
                  },
                ),
              ),

              // Botón "Entrar" en la parte inferior
              ElevatedButton(
                onPressed: () {
                  // Navega a la pantalla de login (o la que tengas configurada como /login)
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
