import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';

import 'map_screen.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- 1. FUNCIÓN PARA REDES SOCIALES (GOOGLE/FACEBOOK) ---
  Future<void> _handleSocialSignIn(UserCredential? userCredential) async {
    if (userCredential?.user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicio de sesión social cancelado o fallido.')),
      );
      return;
    }

    final email = userCredential!.user!.email;
    if (email == null) return;

    if (!mounted) return;
    const String domain = kIsWeb ? 'localhost' : '10.0.2.2';
    final url = Uri.parse('http://$domain/TransTunja/get_user_role.php?email=$email');

    try {
      final response = await http.get(url, headers: {"Accept": "application/json"});
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {

          // Lógica inclusiva (Acepta pasajera, conductora, etc)
          String rol = responseData['rol'].toString().toLowerCase().trim();
          String routeName;

          if (rol.contains('pasajer')) {
            routeName = '/home_pasajero';
          } else if (rol.contains('conductor')) {
            routeName = '/home_conductor';
          } else if (rol.contains('administrador')) {
            routeName = '/home_admin';
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Rol "$rol" no reconocido.')),
            );
            return;
          }
          Navigator.pushReplacementNamed(context, routeName);
        }
      }
    } catch (e) {
      print('Error social login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E8E8),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // LOGO CORREGIDO
              Image.asset(
                'assets/images/logo.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.directions_bus, size: 100, color: Colors.red),
              ),
              const SizedBox(height: 30),

              // Campos de texto
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  children: [
                    TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Correo')),
                    const SizedBox(height: 20),
                    TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- 2. BOTÓN DE INICIO MANUAL CORREGIDO ---
              ElevatedButton(
                onPressed: () async {
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();

                  if (email.isEmpty || password.isEmpty) return;

                  const String domain = kIsWeb ? 'localhost' : '10.0.2.2';
                  final url = Uri.parse('http://$domain/TransTunja/login_manual.php');

                  try {
                    final response = await http.post(url, body: {'email': email, 'password': password});
                    if (response.statusCode == 200) {
                      final data = jsonDecode(response.body);
                      if (data['success'] == true) {

                        // Lógica inclusiva aquí también
                        String rolRecibido = data['rol'].toString().toLowerCase().trim();
                        String routeName;

                        if (rolRecibido.contains('pasajer')) {
                          routeName = '/home_pasajero';
                        } else if (rolRecibido.contains('conductor')) {
                          routeName = '/home_conductor';
                        } else if (rolRecibido.contains('administrador')) {
                          routeName = '/home_admin';
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Rol desconocido: $rolRecibido")),
                          );
                          return;
                        }
                        Navigator.pushReplacementNamed(context, routeName);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error de conexión")));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                ),
                child: const Text('Inicia sesión', style: TextStyle(color: Colors.white)),
              ),
              // ... resto de los botones sociales y registro ...
              const SizedBox(height: 30),
              const Text('O inicia sesión con'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () async {
                        final userCredential = await AuthService.signInWithFacebook();
                        await _handleSocialSignIn(userCredential);
                      },
                      icon: const Icon(Icons.facebook, color: Colors.blue, size: 40)
                  ),
                  const SizedBox(width: 30),
                  IconButton(
                      onPressed: () async {
                        final userCredential = await AuthService.signInWithGoogle();
                        await _handleSocialSignIn(userCredential);
                      },
                      icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 50)
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text.rich(
                TextSpan(
                  text: '¿Aún no tienes cuenta? ',
                  children: [
                    TextSpan(
                      text: 'Regístrate aquí',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}