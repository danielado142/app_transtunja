import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

// Imports de tus pantallas
import 'pantalla_bienvenida.dart';
import 'package:app_transtunja/screens/usuario/login_screen.dart';
import 'package:app_transtunja/screens/usuario/register_screen.dart';
import 'package:app_transtunja/screens/usuario/role_selection_screen.dart';
// Asegúrate de que este archivo contenga la clase SmsVerificationScreen
import 'package:app_transtunja/screens/usuario/verification_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint("✅ Firebase conectado con éxito");
  } catch (e) {
    debugPrint("❌ Error conectando Firebase: $e");
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
      home: const PantallaBienvenida(),
      onGenerateRoute: (settings) {
        // Ruta para Selección de Rol
        if (settings.name == '/role_selection') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => RoleSelectionScreen(userData: args),
          );
        }

        // CORRECCIÓN AQUÍ: Cambiamos VerificationScreen por SmsVerificationScreen
        if (settings.name == '/verification') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => SmsVerificationScreen(
              // <--- NOMBRE ACTUALIZADO
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
