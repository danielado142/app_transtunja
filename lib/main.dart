import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'splash_screen.dart';
import 'login_screen.dart'; // Asegúrate de importar tu login
// IMPORTA AQUÍ TUS PANTALLAS DE DESTINO:
// import 'home_pasajero.dart';
// import 'home_conductor.dart';
// import 'home_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAiO-tzQjWbqFaFr4q1JfoBVEQC9vaihlg",
        authDomain: "transtunja.firebaseapp.com",
        projectId: "transtunja",
        storageBucket: "transtunja.firebasestorage.app",
        messagingSenderId: "497369853822",
        appId: "1:497369853822:web:26d1c474912f47aed80d2f",
        measurementId: "G-DKRYV7NV9R",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const TransTunjaApp());
}

class TransTunjaApp extends StatelessWidget {
  const TransTunjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TransTunja',

      // Pantalla inicial
      home: const SplashScreen(),

      // --- ESTO ES LO QUE FALTABA: DEFINIR LAS RUTAS ---
      routes: {
        '/login': (context) => const LoginScreen(),

        // Sustituye 'Container()' por el nombre de tus clases reales (ej. HomePasajero())
        '/home_pasajero': (context) => const Scaffold(body: Center(child: Text("Bienvenido Pasajero"))),
        '/home_conductor': (context) => const Scaffold(body: Center(child: Text("Bienvenido Conductor"))),
        '/home_admin': (context) => const Scaffold(body: Center(child: Text("Bienvenido Administrador"))),
      },
    );
  }
}