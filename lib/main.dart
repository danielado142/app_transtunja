import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

// --- TUS IMPORTS ---
import 'pantalla_bienvenida.dart';
import 'package:app_transtunja/screens/login/login_screen.dart';
import 'package:app_transtunja/screens/login/register_screen.dart';
import 'package:app_transtunja/screens/login/role_selection_screen.dart';
import 'package:app_transtunja/screens/login/verification_screen.dart'; 

// --- OTROS IMPORTS ---
import 'package:app_transtunja/screens/conductor/home_conductor.dart';
import 'package:app_transtunja/screens/usuario/user_home_screen.dart';
import 'package:app_transtunja/screens/administrador/login_admin.dart';

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
        final args = settings.arguments as Map<String, dynamic>? ?? {};

        switch (settings.name) {
          case '/sms_verification':
            return MaterialPageRoute(
              builder: (context) => SmsVerificationScreen(
                verificationId: args['verificationId'] ?? '',
                userData: args['userData'] ?? {},
              ),
            );

          case '/role_selection':
            return MaterialPageRoute(
              builder: (context) => RoleSelectionScreen(userData: args),
            );

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/register':
            // ✅ Corregido: Agregamos userData vacío para evitar errores de constructor
            return MaterialPageRoute(builder: (_) => const RegisterScreen(userData: {}));

          // ✅ NUEVO: Agregamos la ruta del conductor para que conecte con el login
          case '/home_conductor':
            return MaterialPageRoute(
              builder: (context) => HomeConductor(userData: args),
            );

          case '/home_usuario':
            return MaterialPageRoute(builder: (_) => const UserHomeScreen());

          case '/login_admin':
            return MaterialPageRoute(builder: (_) => const LoginAdmin());

          default:
            return MaterialPageRoute(
                builder: (_) => const PantallaBienvenida());
        }
      },
    );
  }
}