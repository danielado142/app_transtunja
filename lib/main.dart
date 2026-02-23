import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Importaciones de tus pantallas
import 'login_screen.dart';
import 'register_screen.dart';
import 'splash_screen.dart';
import 'map_screen.dart'; // IMPORTANTE: Asegúrate de que este archivo exista

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

      // --- CONFIGURACIÓN DE IDIOMA ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
      // -------------------------------

      initialRoute: '/', // Inicia con el Splash
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(userData: {}),

        // --- RUTA DEL MAPA PARA PASAJEROS AGREGADA ---
        '/mapa_pasajero': (context) => const MapScreen(),
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
            Center(
              child: Image.asset(
                'assets/images/transtunja_logo.png',
                width: MediaQuery.of(context).size.width * 0.8,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.directions_bus, size: 100, color: Colors.red),
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: ElevatedButton(
                onPressed: () {
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