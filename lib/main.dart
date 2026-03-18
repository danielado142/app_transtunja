import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

// --- TUS IMPORTS ---
import 'pantalla_bienvenida.dart';
import 'package:app_transtunja/screens/usuario/login_screen.dart';
import 'package:app_transtunja/screens/usuario/register_screen.dart';
import 'package:app_transtunja/screens/usuario/role_selection_screen.dart';
import 'package:app_transtunja/screens/usuario/verification_screen.dart';

// --- IMPORTS DE TU COMPAÑERA ---
import 'package:app_transtunja/screens/conductor/home_conductor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint("✅ Firebase conectado");
  } catch (e) {
    debugPrint("❌ Error Firebase: $e");
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
      supportedLocales: const [Locale('es', 'ES')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const PantallaBienvenida(),
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>? ?? {};

        if (settings.name == '/role_selection') {
          return MaterialPageRoute(
            builder: (_) => RoleSelectionScreen(userData: args),
          );
        }
        if (settings.name == '/verification') {
          return MaterialPageRoute(
            builder: (_) => SmsVerificationScreen(
              verificationId: args['verificationId'] ?? '',
              userData: args['userData'] ?? {},
            ),
          );
        }
        if (settings.name == '/home_conductor') {
          return MaterialPageRoute(
            builder: (_) =>
                HomeConductor(nombreConductor: args['nombre'] ?? "Conductor"),
          );
        }
        if (settings.name == '/login')
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        if (settings.name == '/register')
          return MaterialPageRoute(builder: (_) => const RegisterScreen());

        return null;
      },
    );
  }
}
