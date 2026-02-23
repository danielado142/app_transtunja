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

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE NAVEGACIÓN FLEXIBLE (CORREGIDA) ---
  void _navegarSegunRol(dynamic rolValue) {
    if (!mounted) return;

    // Limpiamos el valor recibido para evitar errores de espacios o tipos
    String rolStr = rolValue.toString().trim();
    print("DEBUG: Rol detectado en sistema: '$rolStr'");

    // Si el rol es "1" o "0", lo enviamos al mapa de pasajero para evitar bloqueos
    if (rolStr == "1" || rolStr == "0") {
      Navigator.pushReplacementNamed(context, '/mapa_pasajero');
    }
    else if (rolStr == "2") {
      Navigator.pushReplacementNamed(context, '/home_conductor');
    }
    else if (rolStr == "3") {
      Navigator.pushReplacementNamed(context, '/home_admin');
    }
    else {
      // Si llega cualquier otro valor (como "administrador" antes de la corrección)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Acceso restringido. Rol: $rolStr")),
      );
    }
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
    const String domain = kIsWeb ? 'localhost' : '192.168.90.54';
    final url = Uri.parse('http://$domain/TransTunja/login.php');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": email, "social_login": true}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _navegarSegunRol(data['rol']);
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
      backgroundColor: const Color(0xFFF1E6E6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 100),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(45.0),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Correo electrónico o Usuario', border: UnderlineInputBorder()),
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
            Row(
              children: [
                Checkbox(value: _rememberMe, onChanged: (val) => setState(() => _rememberMe = val!), activeColor: Colors.red),
                const Text("Recuerdame", style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () async {
                String user = _emailController.text.trim();
                String pass = _passwordController.text.trim();

                if (user.isNotEmpty && pass.isNotEmpty) {
                  const String domain = kIsWeb ? 'localhost' : '192.168.90.54';
                  final url = Uri.parse("http://$domain/TransTunja/login.php");

                  try {
                    final response = await http.post(
                      url,
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({"username": user, "password": pass}),
                    ).timeout(const Duration(seconds: 10));

                    if (response.statusCode == 200) {
                      final data = jsonDecode(response.body);
                      if (data['success'] == true) {
                        _navegarSegunRol(data['rol']);
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Usuario o contraseña incorrectos")),
                        );
                      }
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Por favor llena todos los campos")));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
              ),
              child: const Text('Inicia sesión', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () {},
              child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            const Text('O inicia sesión con'),
            const SizedBox(height: 20),
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

  Widget _buildSocialIcon(String assetPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Image.asset(assetPath, height: 45, width: 45, fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 40)),
    );
  }
}