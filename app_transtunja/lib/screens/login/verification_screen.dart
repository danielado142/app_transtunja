import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// ✅ Importamos la configuración centralizada
import 'package:app_transtunja/config/constants.dart';

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 20,
        size.width,
        size.height - 40,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SmsVerificationScreen extends StatefulWidget {
  final String verificationId;
  final Map<String, dynamic> userData;
  final String? nombreUsuario; // <--- Mantenido

  const SmsVerificationScreen({
    super.key,
    required this.verificationId,
    required this.userData,
    this.nombreUsuario, // <--- Parámetro opcional
  });

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  void _mostrarAlertaError() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel, color: Colors.red, size: 35),
                  ),
                ),
                const Text(
                  "Código inválido",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Intenta nuevamente",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _enviarAPhPMyAdmin() async {
    final String urlApi = '${ApiConfig.baseUrl}/registro.php';

    try {
      final response = await http.post(
        Uri.parse(urlApi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'nombreUsuario': widget.userData['nombreUsuario']?.toString() ?? '',
          'nombres': widget.userData['nombres']?.toString() ?? '',
          'apellidos': widget.userData['apellidos']?.toString() ?? '',
          'tipoDocumento': widget.userData['tipoDocumento']?.toString() ?? 'CC',
          'identificacion': widget.userData['identificacion']?.toString() ?? '',
          'correo': widget.userData['correo']?.toString() ?? '',
          'contrasena': widget.userData['contrasena']?.toString() ?? '',
          'idRol': widget.userData['idRol']?.toString() ?? 'pasajero',
          'fechaNacimiento':
              widget.userData['fechaNacimiento']?.toString() ?? '',
          'telefono': widget.userData['telefono']?.toString() ?? '',
        }),
      );

      debugPrint("Respuesta XAMPP: ${response.body}");
    } catch (e) {
      debugPrint("❌ Error red PHP: $e");
    }
  }

  Future<void> _verificarCodigo() async {
    String smsCode = _controllers.map((c) => c.text).join();
    if (smsCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código completo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await _enviarAPhPMyAdmin();

      if (!mounted) return;

      // ✅ PASAMOS LOS DATOS CORRECTAMENTE:
      // Si el nombre no está en userData, lo agregamos antes de navegar
      final Map<String, dynamic> finalData = Map.from(widget.userData);
      if (!finalData.containsKey('nombreUsuario')) {
        finalData['nombreUsuario'] = widget.nombreUsuario ?? "Usuario";
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/role_selection',
        (route) => false,
        arguments: finalData,
      );
    } catch (e) {
      debugPrint("Error en verificación: $e");
      if (mounted) _mostrarAlertaError();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si usas Navigator.pushNamed, extraemos los argumentos aquí:
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // Buscamos el nombre en el widget o en los argumentos de la ruta
    final String saludoNombre = widget.nombreUsuario ?? 
                                 widget.userData['nombreUsuario'] ?? 
                                 args?['nombreUsuario'] ?? 
                                 "Usuario";

    return Scaffold(
      backgroundColor: const Color(0xFFF2E7E7),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopCurveClipper(),
              child: Container(height: 160, color: Colors.red),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildProfileIcon(),
                  const SizedBox(height: 30),
                  // 👋 SALUDO CON NOMBRE DINÁMICO
                  Text(
                    "¡Hola, $saludoNombre!",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Verificación",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 15),
                  Text("Código enviado al +57 ${widget.userData['telefono']}"),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      6,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _buildCodeBox(index),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.red)
                      : ElevatedButton(
                          onPressed: _verificarCodigo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 80,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Verificar",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileIcon() {
    return Container(
      height: 140,
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: const Icon(Icons.person_search, size: 100, color: Colors.black54),
    );
  }

  Widget _buildCodeBox(int index) {
    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black54),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}