import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  // --- LOGIN TRADICIONAL (MYSQL) ---
  Future<void> _iniciarSesion() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor llena todos los campos")),
      );
      return;
    }

    const String urlApi = 'http://192.168.0.102/TRANSTUNJA/login.php';

    try {
      final response = await http.post(
        Uri.parse(urlApi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "correo": _emailController.text.trim(),
          "contrasena": _passwordController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        debugPrint("✅ Bienvenido: ${data['userData']['nombreUsuario']}");

        if (!mounted) return;

        Navigator.pushReplacementNamed(
            context,
            '/role_selection',
            arguments: data['userData']
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Error de credenciales")),
        );
      }
    } catch (e) {
      debugPrint("❌ Error en Login: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
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
                    decoration: const InputDecoration(
                        labelText: 'Correo electrónico o Usuario',
                        border: UnderlineInputBorder()
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
            Row(
              children: [
                Checkbox(
                    value: _rememberMe,
                    onChanged: (val) => setState(() => _rememberMe = val!),
                    activeColor: Colors.red
                ),
                const Text("Recuérdame", style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: _iniciarSesion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
              ),
              child: const Text(
                  'Inicia sesión',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () {},
              child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            const Text('O inicia sesión con'),
            const SizedBox(height: 20),

            // --- SECCIÓN DE REDES SOCIALES INTEGRADA ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón Facebook
                _buildSocialIcon('assets/images/facebook.png', () async {
                  UserCredential? user = await AuthService.signInWithFacebook();
                  if (user != null && mounted) {
                    Navigator.pushReplacementNamed(
                        context,
                        '/role_selection',
                        arguments: {
                          'nombreUsuario': user.user?.displayName,
                          'correo': user.user?.email
                        }
                    );
                  }
                }),
                const SizedBox(width: 40),
                // Botón Google
                _buildSocialIcon('assets/images/google.png', () async {
                  UserCredential? user = await AuthService.signInWithGoogle();
                  if (user != null && mounted) {
                    Navigator.pushReplacementNamed(
                        context,
                        '/role_selection',
                        arguments: {
                          'nombreUsuario': user.user?.displayName,
                          'correo': user.user?.email
                        }
                    );
                  }
                }),
              ],
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen(userData: {}))
                ),
                child: const Text(
                  '¿Aún no tienes cuenta? Regístrate aquí.',
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