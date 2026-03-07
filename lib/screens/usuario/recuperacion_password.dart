import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

// ==========================================================
// PANTALLA 1: SOLICITAR CÓDIGO Y VERIFICAR
// ==========================================================
class RecuperacionPasswordScreen extends StatefulWidget {
  const RecuperacionPasswordScreen({super.key});

  @override
  State<RecuperacionPasswordScreen> createState() =>
      _RecuperacionPasswordScreenState();
}

class _RecuperacionPasswordScreenState
    extends State<RecuperacionPasswordScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  final String baseUrl = "http://192.168.0.103/TransTunja";

  @override
  void dispose() {
    _userController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _validarYEnviarCodigo() async {
    final email = _userController.text.trim();
    if (email.isEmpty) {
      _mostrarAlerta("Por favor, ingrese su correo");
      return;
    }
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('$baseUrl/recuperar_password.php');
      final response = await http.post(
        url,
        body: jsonEncode({'correo': email}),
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['existe'] == true) {
        _mostrarAlerta("Código enviado con éxito a $email");
      } else {
        _mostrarAlerta(data['mensaje'] ?? "El correo no está registrado");
      }
    } catch (e) {
      _mostrarAlerta("Error de conexión. Revisa XAMPP.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmarCodigo() async {
    final email = _userController.text.trim();
    final token = _codeController.text.trim();

    if (email.isEmpty || token.isEmpty) {
      _mostrarAlerta("Complete el correo y el código");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/verificar_codigo.php');
      final response = await http.post(
        url,
        body: jsonEncode({'correo': email, 'token': token}),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (data['valido'] == true) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        // NAVEGACIÓN A LA SIGUIENTE INTERFAZ PASANDO EL CORREO
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestablecerPasswordScreen(correo: email),
          ),
        );
      } else {
        _mostrarAlerta(data['mensaje'] ?? "Código inválido");
      }
    } catch (e) {
      _mostrarAlerta("Error de conexión: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarAlerta(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 3)),
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
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
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
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInputField(
                        "Correo electrónico",
                        _userController,
                        TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 25),
                      _buildInputField(
                        "Código de verificación",
                        _codeController,
                        TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      if (_isLoading)
                        const CircularProgressIndicator(color: Colors.red)
                      else
                        TextButton(
                          onPressed: _validarYEnviarCodigo,
                          child: const Text(
                            '¿No llegó el código? Reenviar',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmarCodigo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String hint,
    TextEditingController controller,
    TextInputType type,
  ) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: hint,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

// ==========================================================
// PANTALLA 2: RESTABLECER CONTRASEÑA (LA QUE PEDISTE)
// ==========================================================
class RestablecerPasswordScreen extends StatefulWidget {
  final String correo; // Recibe el correo de la pantalla anterior
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
  bool _isUpdating = false;

  Future<void> _actualizarEnBD() async {
    String p1 = _passwordController.text.trim();
    String p2 = _confirmPasswordController.text.trim();

    if (p1.isEmpty || p2.isEmpty) {
      _mostrarAlerta("Llene ambos campos");
      return;
    }
    if (p1 != p2) {
      _mostrarAlerta("Las contraseñas no coinciden");
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.103/TransTunja/actualizar_password.php"),
        body: jsonEncode({'correo': widget.correo, 'password': p1}),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (data['actualizado'] == true) {
        _mostrarExito();
      } else {
        _mostrarAlerta(data['mensaje']);
      }
    } catch (e) {
      _mostrarAlerta("Error al conectar con el servidor");
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void _mostrarAlerta(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _mostrarExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("¡Éxito!"),
        content: const Text(
          "Contraseña actualizada. Ahora puedes iniciar sesión.",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1E6E6),
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
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
                    'crea una nueva contraseña',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
                      BoxShadow(color: Colors.black12, blurRadius: 15),
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
                        "Verificar contraseña",
                        _confirmPasswordController,
                        _obscurePassword2,
                        () => setState(
                          () => _obscurePassword2 = !_obscurePassword2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _actualizarEnBD,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isUpdating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Restablecer contraseña',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String hint,
    TextEditingController controller,
    bool obscure,
    VoidCallback toggle,
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
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: toggle,
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
