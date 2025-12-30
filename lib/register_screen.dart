import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _fechaNacimientoController.dispose();
    _passwordController.dispose();
    _rolController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _enviarDatos() async {
    if (_nombresController.text.isEmpty ||
        _apellidosController.text.isEmpty ||
        _documentoController.text.isEmpty ||
        _telefonoController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _fechaNacimientoController.text.isEmpty ||
        _rolController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    const String domain = kIsWeb ? 'localhost' : '10.0.2.2';
    final url = Uri.parse('http://$domain/transtunja_api/registro.php');

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'nombre': _nombresController.text,
          'apellido': _apellidosController.text,
          'documento': _documentoController.text,
          'telefono': _telefonoController.text,
          'email': _emailController.text,
          'fecha_nacimiento': _fechaNacimientoController.text,
          'rol': _rolController.text,
          'password': _passwordController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VerificationScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error de registro: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error del servidor: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo conectar al servidor: $e')),
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
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: BottomCurveClipper(),
              child: Container(
                height: screenSize.height * 0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage("assets/images/plaza_de_bolivar.png"),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenSize.height * 0.15),
                    const Text(
                      'Crea tu cuenta en segundos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 10.0, color: Colors.black)],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, spreadRadius: 5)],
                      ),
                      child: Column(
                        children: [
                          _buildTextField('Nombres', controller: _nombresController),
                          _buildTextField('Apellidos', controller: _apellidosController),
                          _buildTextField('Tipo documento'),
                          _buildTextField('N. Documento', controller: _documentoController),
                          _buildTextField('Número de Télefono', controller: _telefonoController),
                          _buildTextField('Correo electrónico', controller: _emailController),
                          _buildTextField('Fecha de nacimiento', controller: _fechaNacimientoController, hint: 'YYYY-MM-DD'),
                          // --- ORDEN CORREGIDO ---
                          _buildTextField('Contraseña', controller: _passwordController, isPassword: true),
                          _buildTextField('Confirmar contraseña', controller: _confirmPasswordController, isPassword: true),
                          _buildTextField('Rol', controller: _rolController, hint: 'admin, conductor, o usuario', isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Al registrarte aceptas nuestros Términos y Condiciones',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _enviarDatos,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      ),
                      child: const Text('Regístrate', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    const SizedBox(height: 20),
                    const Text('O regístrate con', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 40)),
                        const SizedBox(width: 20),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.mail, color: Colors.red, size: 40)),
                        const SizedBox(width: 20),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.camera_alt, color: Colors.purple, size: 40)),
                        const SizedBox(width: 20),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.g_mobiledata, color: Colors.green, size: 50)),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 25,
            left: 5,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {TextEditingController? controller, bool isPassword = false, bool isLast = false, String? hint}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 5 : 20.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.only(bottom: 10),
          isDense: true,
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 0.5)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.5)),
        ),
      ),
    );
  }
}
