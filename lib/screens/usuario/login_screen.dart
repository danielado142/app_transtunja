import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ Importaciones corregidas
import 'package:app_transtunja/config/constants.dart';
import 'register_screen.dart';
import 'recuperacion_password.dart';
// ✅ Asegúrate de que la ruta sea la correcta para tu proyecto
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ✅ Instancia de AuthService para usar sus métodos
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor llena todos los campos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String urlApi = '${ApiConfig.baseUrl}/login.php';

    try {
      final response = await http
          .post(
            Uri.parse(urlApi),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              // ✅ DISFRAZ COMPLETO PARA INFINITYFREE
              "User-Agent":
                  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
              "Accept-Language": "es-ES,es;q=0.9",
              "Origin": "https://transtunja-app.infinityfree.me",
              "Referer": "https://transtunja-app.infinityfree.me/",
            },
            body: jsonEncode({
              "correo": _emailController.text.trim(),
              "contrasena": _passwordController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 12));

      // Verificamos si la respuesta es JSON válido
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/role_selection',
          arguments: data['userData'],
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Error de credenciales")),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Si el error contiene "HTML", es que el bloqueo de InfinityFree persiste
      String errorMsg = e.toString();
      if (errorMsg.contains("html") || errorMsg.contains("SyntaxError")) {
        errorMsg = "El servidor gratuito bloqueó la conexión (Seguridad AES).";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $errorMsg")));
      debugPrint("Error detallado: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            // --- CONTENEDOR DE FORMULARIO ---
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 40.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(45.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico o Usuario',
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
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      border: const UnderlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // --- RECUÉRDAME ---
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (val) => setState(() => _rememberMe = val!),
                  activeColor: Colors.red,
                ),
                const Text("Recuérdame", style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 15),

            // --- BOTÓN INICIAR SESIÓN ---
            _isLoading
                ? const CircularProgressIndicator(color: Colors.red)
                : ElevatedButton(
                    onPressed: _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    child: const Text(
                      'Inicia sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            const SizedBox(height: 15),

            // --- BOTÓN GOOGLE ---
            ElevatedButton.icon(
              icon: Image.asset(
                'assets/images/google.png',
                width: 24,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.account_circle),
              ),
              label: const Text("Continuar con Google"),
              onPressed: () async {
                final userCredential = await _authService.signInWithGoogle(
                  context,
                );

                if (userCredential != null && mounted) {
                  debugPrint(
                    "Login exitoso con Google: ${userCredential.user?.email}",
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecuperacionPasswordScreen(),
                  ),
                );
              },
              child: const Text(
                "¿Olvidaste tu contraseña?",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(userData: {}),
                  ),
                );
              },
              child: const Text(
                '¿Aún no tienes cuenta? Regístrate aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
