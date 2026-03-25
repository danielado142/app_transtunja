import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  const SmsVerificationScreen({
    super.key,
    required this.verificationId,
    required this.userData,
  });

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  void _mostrarAlertaError(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title:
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- REGISTRO FINAL EN XAMPP ---
  Future<bool> _enviarAPhPMyAdmin() async {
    final String urlApi = '${ApiConfig.baseUrl}/registro.php';

    try {
      final response = await http
          .post(
            Uri.parse(urlApi),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(widget.userData),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("Respuesta XAMPP: ${response.body}");

      final data = jsonDecode(response.body);
      // Validamos que el PHP responda con éxito
      return (response.statusCode == 200 &&
          (data['status'] == 'success' || data['success'] == true));
    } catch (e) {
      debugPrint("❌ Error red PHP: $e");
      return false;
    }
  }

  Future<void> _verificarCodigo() async {
    String smsCode = _controllers.map((c) => c.text).join();
    if (smsCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código de 6 dígitos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Validar código con Firebase
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // 2. Si Firebase es exitoso, guardar en MySQL (XAMPP)
      bool guardadoExitoso = await _enviarAPhPMyAdmin();

      if (!mounted) return;

      if (guardadoExitoso) {
        // 3. Todo bien -> Ir a selección de rol o Home
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/role_selection',
          (route) => false,
          arguments: widget.userData,
        );
      } else {
        _mostrarAlertaError("Error de Base de Datos",
            "El SMS fue correcto, pero no pudimos crear tu perfil en el servidor.");
      }
    } catch (e) {
      debugPrint("Error en verificación: $e");
      if (mounted)
        _mostrarAlertaError("Código Inválido",
            "El código ingresado no es correcto o ya expiró.");
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
                  const Text("Verificación",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Text("Código enviado al +57 ${widget.userData['telefono']}"),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        6,
                        (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("Verificar",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
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
        decoration:
            const InputDecoration(counterText: "", border: InputBorder.none),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5)
            _focusNodes[index + 1].requestFocus();
          if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
        },
      ),
    );
  }
}
