import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Custom Clipper para la curva roja superior del diseño
class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 50)
      ..quadraticBezierTo(size.width * 0.5, size.height + 20, size.width, size.height - 50)
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
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // AJUSTE LÓGICO MENOR: Se usan 6 controladores para los 6 campos de texto
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  // LÓGICA PRINCIPAL SIN CAMBIOS: Solo cambia cómo se obtiene el código
  Future<void> _verificarCodigo() async {
    // Se unen los 6 dígitos de los campos de texto
    String smsCode = _controllers.map((c) => c.text).join();

    if (smsCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa el código completo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // La lógica de Firebase se mantiene intacta
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Teléfono verificado con éxito!')),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (route) => false, arguments: widget.userData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código incorrecto o expirado: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E8E8),
      // CORRECCIÓN: Se elimina el AppBar para usar un botón personalizado en el Stack
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: TopCurveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                color: Colors.red,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/verificacion_icon.png', // Asegúrate que esta imagen exista
                    height: 120,
                    errorBuilder: (_, __, ___) => const Icon(Icons.phonelink_lock, size: 100, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Verificación de código",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Te enviamos un código de 6 dígitos al\nnúmero +${widget.userData['telefono'] ?? ''}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) => _buildCodeBox(index)),
                  ),
                  const SizedBox(height: 40),
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
                  TextButton(
                    onPressed: () { /* Lógica para reenviar código */ },
                    child: const Text("Reenviar código", style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ),
          // CORRECCIÓN: Se añade el botón de retroceso personalizado
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

  // Widget para cada caja del código de verificación
  Widget _buildCodeBox(int index) {
    return SizedBox(
      width: 45,
      height: 50,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 2)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
