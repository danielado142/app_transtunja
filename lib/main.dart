import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

// Imports de tus pantallas
import 'pantalla_bienvenida.dart';
import 'package:app_transtunja/screens/usuario/login_screen.dart';
import 'package:app_transtunja/screens/usuario/register_screen.dart';
import 'package:app_transtunja/screens/usuario/role_selection_screen.dart';
import 'package:app_transtunja/screens/usuario/verification_screen.dart'; // Asegúrate que esta ruta sea correcta

Future<void> main() async {
  // 1. Esto es vital para que las promesas (async) funcionen en el main
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Inicializar Firebase
    await Firebase.initializeApp();
    print("✅ Firebase conectado con éxito");
  } catch (e) {
    print("❌ Error conectando Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TransTunja',
      debugShowCheckedModeBanner: false,

      // Configuración de idiomas (Calendario)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),

      // Pantalla principal al abrir la app
      home: const PantallaBienvenida(),

      // MANEJO DE RUTAS (Aquí es donde se definen los saltos entre pantallas)
      onGenerateRoute: (settings) {
        // Ruta para Selección de Rol
        if (settings.name == '/role_selection') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => RoleSelectionScreen(userData: args),
          );
        }

        // RUTA PARA VERIFICACIÓN (Esto es lo que te faltaba)
        if (settings.name == '/verification') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => VerificationScreen(
              verificationId: args['verificationId'] ?? '',
              userData: args['userData'] ?? {},
            ),
          );
        }
        return null;
      },

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
