import 'package:flutter/material.dart';
// Esta es la ruta a tu pantalla de login organizada
import 'package:app_transtunja/screens/usuario/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TransTunja',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Aquí conectamos con tu pantalla de Login
      home: const LoginScreen(),
    );
  }
}
