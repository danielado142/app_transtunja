import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

// --- TUS IMPORTS ---
import 'pantalla_bienvenida.dart';
// He ajustado las rutas según lo que se ve en tu explorador de archivos (image_2eb6a9.png)
import 'package:app_transtunja/screens/login/login_screen.dart';
import 'package:app_transtunja/screens/login/register_screen.dart';
import 'package:app_transtunja/screens/login/role_selection_screen.dart';
// IMPORTANTE: Verifica que dentro de este archivo la clase se llame EXACTAMENTE SmsVerificationScreen
import 'package:app_transtunja/screens/login/verification_screen.dart';

// --- OTROS IMPORTS ---
import 'package:app_transtunja/screens/conductor/home_conductor.dart';
import 'package:app_transtunja/screens/usuario/user_home_screen.dart';

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

        if (settings.name == '/role_selection') {
          return MaterialPageRoute(
            builder: (context) => RoleSelectionScreen(userData: args),
          );
        }

        if (settings.name == '/verification') {
          return MaterialPageRoute(
            builder: (context) => SmsVerificationScreen(
              verificationId: args['verificationId'] ?? '',
              userData: args, // Pasamos el mapa completo de datos
            ),
          );
        }

        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }

        if (settings.name == '/register') {
          return MaterialPageRoute(builder: (_) => const RegisterScreen());
        }

        if (settings.name == '/home_usuario') {
          return MaterialPageRoute(builder: (_) => const UserHomeScreen());
        }

        return null;
      },
    );
  }
}
