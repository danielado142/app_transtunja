import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // Asegúrate de tener http en pubspec.yaml
import 'dart:convert'; // Para jsonEncode y jsonDecode

// --- CLIPPER PARA LA CURVA SUPERIOR ---
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.55,
      size.height * 1.25,
      size.width,
      size.height * 0.70,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RestablecerPasswordScreen extends StatefulWidget {
  // ERROR COMÚN: Asegúrate de que esta variable esté aquí para recibir el correo
  final String correo;

  const RestablecerPasswordScreen({super.key, required this.correo});

  @override
  State<RestablecerPasswordScreen> createState() =>
      _RestablecerPasswordScreenState();
}

class _RestablecerPasswordScreenState extends State<RestablecerPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- FUNCIÓN PARA VALIDAR Y ENVIAR A XAMPP ---
  Future<void> _enviarNuevaPassword() async {
    final String p1 = _passwordController.text.trim();
    final String p2 = _confirmPasswordController.text.trim();

    // 1. Validar campos vacíos
    if (p1.isEmpty || p2.isEmpty) {
      _mostrarAlerta("Por favor, llene ambos campos");
      return;
    }

    // 2. Validar longitud (Mínimo 8)
    if (p1.length < 8) {
      _mostrarAlerta("La contraseña debe tener al menos 8 caracteres");
      return;
    }

    // 3. Validar si tiene al menos un número
    if (!p1.contains(RegExp(r'[0-9]'))) {
      _mostrarAlerta("Debe incluir al menos un número");
      return;
    }

    // 4. Validar carácter especial
    final RegExp specialCharRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (!specialCharRegExp.hasMatch(p1)) {
      _mostrarAlerta("Debe incluir un carácter especial (ej: @, #, !)");
      return;
    }

    // 5. Validar que coincidan
    if (p1 != p2) {
      _mostrarAlerta("Las contraseñas no coinciden");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // REVISA TU IP: Asegúrate de que siga siendo 192.168.0.103
      final response = await http
          .post(
            Uri.parse(
              'http://192.168.0.103/TransTunja/actualizar_password.php',
            ),
            body: jsonEncode({
              'correo': widget
                  .correo, //widget.correo accede al parámetro de la clase principal
              'password': p1,
            }),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 10),
          ); // Timeout por si el servidor no responde

      final data = jsonDecode(response.body);

      if (data['actualizado'] == true) {
        _mostrarAlerta("¡Contraseña actualizada con éxito!");

        Future.delayed(const Duration(seconds: 2), () {
          // Regresa hasta la primera pantalla (Login)
          if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
        });
      } else {
        _mostrarAlerta(data['mensaje'] ?? "Error al actualizar");
      }
    } catch (e) {
      _mostrarAlerta("Error de conexión. Revisa XAMPP y tu IP.");
      print("Error detallado: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarAlerta(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1E6E6),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipPath(
                  clipper: HeaderClipper(),
                  child: Container(
                    height: 340,
                    width: double.infinity,
                    color: const Color(0xFFD32F2F),
                  ),
                ),
                const Positioned(
                  bottom: 110,
                  child: Text(
                    'Nueva contraseña',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Transform.translate(
                offset: const Offset(0, -60),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildPasswordField(
                        "Nueva contraseña",
                        _passwordController,
                        _obscurePassword1,
                        () => setState(
                          () => _obscurePassword1 = !_obscurePassword1,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildPasswordField(
                        "Confirmar contraseña",
                        _confirmPasswordController,
                        _obscurePassword2,
                        () => setState(
                          () => _obscurePassword2 = !_obscurePassword2,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFFD32F2F))
                  : ElevatedButton(
                      onPressed: _enviarNuevaPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Restablecer contraseña',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String hint,
    TextEditingController controller,
    bool obscure,
    VoidCallback onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hint, style: const TextStyle(color: Colors.black38, fontSize: 14)),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.black38,
              ),
              onPressed: onToggle,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFEEEEEE)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
