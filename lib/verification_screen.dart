import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(size.width * 0.5, size.height + 20, size.width, size.height - 40)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class VerificationScreen extends StatefulWidget {
  final String verificationId;
  final Map<String, dynamic> userData;

  const VerificationScreen({
    super.key,
    required this.verificationId,
    required this.userData,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  // ÚNICA FUNCIÓN DE ENVÍO A MYSQL
  Future<void> _enviarAPhPMyAdmin() async {
    debugPrint("🚀 Enviando datos completos a MySQL...");
    const String urlApi = 'http://192.168.0.102/TRANSTUNJA/registro.php';

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
          'fechaNacimiento': widget.userData['fechaNacimiento']?.toString() ?? '',
          'telefono': widget.userData['telefono']?.toString() ?? '',
        }),
      );

      debugPrint("📄 Respuesta del servidor: ${response.body}");

      if (response.statusCode == 200) {
        final respuestaJson = json.decode(response.body);
        if (respuestaJson['status'] == 'success') {
          debugPrint("✅ Guardado exitoso en la BD");
        } else {
          debugPrint("❌ Error PHP: ${respuestaJson['message']}");
        }
      }
    } catch (e) {
      debugPrint("❌ ERROR DE RED HACIA PHP: $e");
    }
  }

  // FUNCIÓN PRINCIPAL DEL BOTÓN "VERIFICAR"
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
      // 1. Validar SMS con Firebase
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint("✅ Firebase validado correctamente");

      // 2. Si Firebase dio OK, GUARDAR EN MYSQL
      await _enviarAPhPMyAdmin();

      if (!mounted) return;

      // 3. Navegar al éxito
      Navigator.pushNamedAndRemoveUntil(
          context, '/role_selection', (route) => false,
          arguments: widget.userData
      );

    } catch (e) {
      debugPrint("❌ Error en validación Firebase: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código SMS inválido o error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E7E7),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
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
                  Container(
                    height: 140, width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: const Icon(Icons.person_search, size: 100, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  const Text("Verificación", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Text("Código enviado al +57 ${widget.userData['telefono']}"),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: _buildCodeBox(index),
                    )),
                  ),
                  const SizedBox(height: 50),
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.red)
                      : ElevatedButton(
                    onPressed: _verificarCodigo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Verificar", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBox(int index) {
    return Container(
      width: 40, height: 50,
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
        decoration: const InputDecoration(counterText: "", border: InputBorder.none),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
          if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
        },
      ),
    );
  }
}