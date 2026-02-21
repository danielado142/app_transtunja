import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart'; // Agregado para verificar inicialización
import 'package:firebase_auth/firebase_auth.dart';
import 'verification_screen.dart';

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 50)
      ..quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rolController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _navegarAVerificacion(String vId) {
    Navigator.pushNamed(
      context,
      '/verification',
      arguments: {
        'verificationId': vId,
        'userData': {
          'nombre': _nombresController.text,
          'apellido': _apellidosController.text,
          'documento': _documentoController.text,
          'telefono': "+57${_telefonoController.text.trim()}",
          'email': _emailController.text,
          'fecha_nacimiento': _fechaNacimientoController.text,
          'rol': _rolController.text,
          'password': _passwordController.text,
        },
      },
    );
  }

  // FUNCIÓN CORREGIDA: Primero MySQL, luego Firebase
  Future<void> _enviarDatos() async {
    if (_nombresController.text.isEmpty || _telefonoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete los campos principales')),
      );
      return;
    }

    String numeroCompleto = "+57${_telefonoController.text.trim()}";

    // Configuración de URL según plataforma
    final String domain = kIsWeb ? 'localhost' : '192.168.1.48';
    final url = Uri.parse('http://$domain/TransTunja/registro.php');

    try {
      // 1. Guardado en Base de Datos MySQL (XAMPP)
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'nombre': _nombresController.text,
          'apellido': _apellidosController.text,
          'documento': _documentoController.text,
          'telefono': numeroCompleto,
          'email': _emailController.text,
          'fecha_nacimiento': _fechaNacimientoController.text,
          'rol': _rolController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // 2. Si el PHP responde éxito, procedemos con Firebase
        if (responseData['status'] == 'success') {

          if (Firebase.apps.isEmpty) {
            throw Exception("Firebase no está inicializado. Revisa main.dart");
          }

          await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: numeroCompleto,
            verificationCompleted: (PhoneAuthCredential credential) async {
              await FirebaseAuth.instance.signInWithCredential(credential);
              _navegarAVerificacion("");
            },
            verificationFailed: (FirebaseAuthException e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error Firebase: ${e.message}')),
              );
            },
            codeSent: (String verificationId, int? resendToken) {
              // 3. Salto a la interfaz de verificación al enviar el SMS
              _navegarAVerificacion(verificationId);
            },
            codeAutoRetrievalTimeout: (String verificationId) {},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error PHP: ${responseData['message']}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF8E8E8),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: ClipPath(
              clipper: BottomCurveClipper(),
              child: Container(
                height: screenSize.height * 0.3,
                color: Colors.red,
              ),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  SizedBox(height: screenSize.height * 0.1),
                  const Text('Registro', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        _buildTextField('Nombres', _nombresController),
                        _buildTextField('Apellidos', _apellidosController),
                        _buildTextField('N. Documento', _documentoController),
                        _buildTextField('Teléfono', _telefonoController, hint: 'Ej: 3123251106'),
                        _buildTextField('Email', _emailController),
                        _buildTextField('Fecha Nacimiento (YYYY-MM-DD)', _fechaNacimientoController),
                        _buildTextField('Contraseña', _passwordController, isPassword: true),
                        _buildTextField('Confirmar Contraseña', _confirmPasswordController, isPassword: true),
                        _buildTextField('Rol (admin/conductor/usuario)', _rolController, isLast: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _enviarDatos,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
                    child: const Text('Regístrate', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false, bool isLast = false, String? hint}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 15),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(labelText: label, hintText: hint, isDense: true),
      ),
    );
  }
}