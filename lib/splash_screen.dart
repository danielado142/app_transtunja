import 'package:flutter/material.dart';
import 'login_screen.dart'; // Importa la pantalla de inicio de sesión

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // CORREGIDO: Añadido el nombre del parámetro
            children: <Widget>[
              const Spacer(),
              // Asumiendo que la imagen del logo está en esta ruta
              Image.asset('assets/images/logo.png'), 
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Navega a la pantalla de login reemplazando la actual
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 40), // Un poco de espacio al final
            ],
          ),
        ),
      ),
    );
  }
}
