import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Configuración para el navegador
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
    // Configuración para Android
    await Firebase.initializeApp();
  }

  // ¡ESTA LÍNEA DEBE IR AQUÍ ADENTRO!
  runApp(const TransTunjaApp());
}

// Aquí abajo debe continuar tu clase TransTunjaApp...
class TransTunjaApp extends StatelessWidget {
  const TransTunjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TransTunja',
      home: const LoginScreen(),
    );
  }
}