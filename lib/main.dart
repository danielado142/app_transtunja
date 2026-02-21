import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'splash_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'verification_screen.dart';
import 'role_selection_screen.dart';

void main() async {
  // 1. Asegura la comunicación con los servicios nativos del celular
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // Configuración específica para Web
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
      // 2. Inicialización para Android usando el google-services.json actualizado
      await Firebase.initializeApp();
      debugPrint("Firebase listo en Android");
    }
  } catch (e) {
    // Si esto falla, verás el error en la consola de VS Code
    debugPrint("Error crítico al iniciar Firebase: $e");
  }

  // 3. Arranca la interfaz solo después de que Firebase termine de cargar
  runApp(const TransTunjaApp());
}

class TransTunjaApp extends StatelessWidget {
  const TransTunjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TransTunja',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: false,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/verification': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          return VerificationScreen(
            verificationId: args['verificationId'] ?? '',
            userData: args['userData'] ?? {},
          );
        },
        '/role_selection': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          return RoleSelectionScreen(
            userData: args ?? {},
          );
        },
        '/home_pasajero': (context) => const Scaffold(body: Center(child: Text("Bienvenido Pasajero"))),
        '/home_conductor': (context) => const Scaffold(body: Center(child: Text("Bienvenido Conductor"))),
        '/home_admin': (context) => const Scaffold(body: Center(child: Text("Bienvenido Administrador"))),
      },
    );
  }
}