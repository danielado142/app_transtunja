import 'package:flutter/material.dart';

// Importaciones necesarias
import 'login_screen.dart';
import 'register_screen.dart';
import 'splash_screen.dart';

void main() {
  runApp(const TransTunjaApp());
}

class TransTunjaApp extends StatelessWidget {
  const TransTunjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TransTunja',
      initialRoute: '/', // Inicia con el Splash
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(), // Ruta al login
        '/register': (context) => const RegisterScreen(userData: {}),
      },
    );
  }
}

// --- PANTALLA DE BIENVENIDA ---
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Imagen del Bus
            Center(
              child: Image.asset(
                'assets/images/transtunja_logo.png',
                width: MediaQuery.of(context).size.width * 0.8,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(flex: 2),
            // Botón Entrar configurado correctamente
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: ElevatedButton(
                onPressed: () {
                  // Esta instrucción te manda al inicio de sesión
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}