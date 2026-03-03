import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:io'; // Necesario para detectar la plataforma

// --- TUS IMPORTACIONES ---
import 'login_screen.dart';
import 'register_screen.dart';
import 'splash_screen.dart';
import 'map_screen.dart';
import 'verification_screen.dart';
import 'role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();

    // --- FUNCIÓN PARA VER EL HASH EN LA CONSOLA ---
    if (Platform.isAndroid) {
      // Esta línea intentará obtener la información y lanzará el hash al Logcat
      // si hay un error de configuración.
      debugPrint("Verificando configuración de Facebook...");
    }
  } catch (e) {
    debugPrint("Error inicialización: $e");
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES')],
      locale: const Locale('es', 'ES'),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(userData: {}),
        '/mapa_pasajero': (context) => const MapScreen(),

        '/verification': (context) {
          final settings = ModalRoute.of(context)?.settings;
          final args = settings?.arguments;

          if (args is Map<String, dynamic>) {
            return VerificationScreen(
              verificationId: args['verificationId'] ?? '',
              userData: args['userData'] ?? {},
            );
          }
          return const VerificationScreen(verificationId: '', userData: {});
        },

        '/role_selection': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;

          if (args is Map<String, dynamic>) {
            return RoleSelectionScreen(userData: args);
          }
          return const RoleSelectionScreen(userData: {});
        },
      },
    );
  }
}