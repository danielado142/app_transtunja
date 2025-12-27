import 'package:flutter/material.dart';
import 'verification_screen.dart'; // Importamos la nueva pantalla (ruta corregida)

// Este es un "Clipper" personalizado. Su única función es darle la forma curva a la imagen.
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 50) // Empezar la curva 50px antes del final
      ..quadraticBezierTo(
        size.width / 2, // Punto de control en el centro
        size.height,      // Punto de control en la parte más baja
        size.width,       // Punto final a la derecha
        size.height - 50, // Punto final 50px antes del final
      )
      ..lineTo(size.width, 0) // Línea hasta la esquina superior derecha
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8E8E8), // Fondo rosa pálido
      body: Stack(
        children: [
          // --- Capa 1: La imagen de fondo con la forma curva ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: BottomCurveClipper(),
              child: Container(
                height: screenSize.height * 0.4, // La imagen ocupa el 40% de la pantalla
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage("assets/images/plaza_de_bolivar.png"),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // --- Capa 2: Todo el contenido que se puede desplazar ---
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenSize.height * 0.15), // Espacio superior para el título
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
                    // Formulario blanco
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, spreadRadius: 5)],
                      ),
                      child: Column(
                        children: [
                          _buildTextField('Nombres'),
                          _buildTextField('Apellidos'),
                          _buildTextField('Tipo documento'),
                          _buildTextField('N. Documento'),
                          _buildTextField('Número de Télefono'),
                          _buildTextField('Contraseña', isPassword: true),
                          _buildTextField('Confirmar contraseña', isPassword: true, isLast: true),
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
                      onPressed: () {
                        // ¡Aquí está la navegación!
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VerificationScreen()),
                        );
                      },
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
                    // --- Iconos de redes sociales corregidos con placeholders ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 40)),
                        const SizedBox(width: 20),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.mail, color: Colors.red, size: 40)), // Placeholder para Gmail
                        const SizedBox(width: 20),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.camera_alt, color: Colors.purple, size: 40)), // Placeholder para Instagram
                        const SizedBox(width: 20),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.g_mobiledata, color: Colors.green, size: 50)), // Placeholder para Google
                      ],
                    ),
                    const SizedBox(height: 30), // Espacio al final
                  ],
                ),
              ),
            ),
          ),

          // --- Capa 3: Botón de regreso ---
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

  Widget _buildTextField(String label, {bool isPassword = false, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 5 : 20.0),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
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
