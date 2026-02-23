import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';

import 'register_screen.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variables para nuevas funcionalidades
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSocialSignIn(UserCredential? userCredential) async {
    if (userCredential == null || userCredential.user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión cancelado o fallido'))
      );
      return;
    }

    final email = userCredential.user?.email;
    // IP configurada para tu red local
    const String domain = kIsWeb ? 'localhost' : '192.168.0.103';
    final url = Uri.parse('http://$domain/TransTunja/get_user_role.php?correo=$email');

    try {
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final String rol = data['idRol'].toString().toLowerCase();
          String routeName;
          if (rol.contains('pasajero') || rol == '1') routeName = '/home_pasajero';
          else if (rol.contains('conductor') || rol == '2') routeName = '/home_conductor';
          else if (rol.contains('admin') || rol == '3') routeName = '/home_admin';
          else return;

          if (!mounted) return;
          Navigator.pushReplacementNamed(context, routeName);
        } else {
          if (!mounted) return;
          Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen(userData: {'email': email})));
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1E6E6), // Color de fondo según imagen
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 100),
            // Contenedor principal con bordes redondeados y sombra
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5), // Color gris claro de la caja
                borderRadius: BorderRadius.circular(45.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: const UnderlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // Checkbox Recuérdame
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (val) => setState(() => _rememberMe = val!),
                  activeColor: Colors.red,
                ),
                const Text("Recuerdame", style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 15),
            // Botón Inicia Sesión
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
              ),
              child: const Text('Inicia sesión', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            // ¿Olvidaste tu contraseña?
            TextButton(
              onPressed: () {},
              child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            const Text('O inicia sesión con'),
            const SizedBox(height: 20),
            // Iconos sociales reales
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon('assets/images/facebook.png', () async {
                  final cred = await AuthService.signInWithFacebook();
                  await _handleSocialSignIn(cred);
                }),
                const SizedBox(width: 40),
                _buildSocialIcon('assets/images/google.png', () async {
                  final cred = await AuthService.signInWithGoogle();
                  await _handleSocialSignIn(cred);
                }),
              ],
            ),
            const SizedBox(height: 40),
            // Texto para ir al registro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen(userData: {}))),
                child: const Text(
                  '¿Aún no tienes cuenta? Regístrate aquí".',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para botones sociales con tus imágenes reales
  Widget _buildSocialIcon(String assetPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Image.asset(
        assetPath,
        height: 45,
        width: 45,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 40),
      ),
    );
  }
}