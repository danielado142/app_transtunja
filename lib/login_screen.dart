import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'register_screen.dart';
// 1. IMPORTANTE: El nombre del servicio ahora es más genérico
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E8E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
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
                        labelText: 'Correo electrónico',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        suffixIcon: Icon(Icons.visibility_off),
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Lógica de inicio de sesión manual (sin cambios)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                ),
                child: const Text('Inicia sesión', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 30),
              const Text('O inicia sesión con'),
              const SizedBox(height: 20),

              // --- BOTONES DE REDES SOCIALES ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 2. BOTÓN DE FACEBOOK ACTUALIZADO
                  IconButton(
                      onPressed: () async {
                        // Llamamos al nuevo servicio de Facebook
                        final userCredential = await AuthService.signInWithFacebook();

                        if (userCredential != null && mounted) {
                          // Si funciona, vamos al mapa
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MapScreen()),
                          );
                        } else {
                          // Si falla o cancela
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Inicio de sesión con Facebook cancelado o fallido')),
                          );
                        }
                      },
                      icon: const Icon(Icons.facebook, color: Colors.blue, size: 40)
                  ),
                  const SizedBox(width: 30),

                  // 3. BOTÓN DE GOOGLE CORREGIDO (usa AuthService)
                  IconButton(
                      onPressed: () async {
                        // Llamamos al servicio de Google desde la clase genérica
                        final userCredential = await AuthService.signInWithGoogle();

                        if (userCredential != null && mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MapScreen()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Inicio de sesión con Google cancelado')),
                          );
                        }
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
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
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
