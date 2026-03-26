import 'package:flutter/material.dart';
// 1. IMPORTANTE: Asegúrate de que la ruta sea la correcta según tu proyecto
import 'package:app_transtunja/screens/conductor/home_conductor.dart';

class DriverVerificationScreen extends StatefulWidget {
  // 👈 Agregamos esto para recibir el correo de quien sea que esté entrando
  final String correoLogin; 

  const DriverVerificationScreen({super.key, this.correoLogin = "conductor@mail.com"});

  @override
  State<DriverVerificationScreen> createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState extends State<DriverVerificationScreen> {
  final String _codigoCorrecto = "654321";
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var node in _focusNodes) node.dispose();
    for (var controller in _controllers) controller.dispose();
    super.dispose();
  }

  void _validarCodigo() {
    String codigoIngresado = "";
    for (var controller in _controllers) {
      codigoIngresado +=
          controller.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    }

    if (codigoIngresado == _codigoCorrecto) {
      _mostrarExito();
    } else {
      _mostrarError();
    }
  }

  void _mostrarExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDF2F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.directions_car, color: Colors.green, size: 80),
            const SizedBox(height: 25),
            const Text(
              '¡Código Correcto!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Acceso como Conductor.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Colors.black54),
            ),
            const SizedBox(height: 15),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                // 2. NAVEGACIÓN HACIA EL HOME
                Navigator.pop(context);

                // 🔥 AQUÍ ESTÁ EL CAMBIO CLAVE:
                // Usamos widget.correoLogin para que el Home sepa a quién buscar en el hosting
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeConductor(
                      nombreConductor: "Cargando...", // Se actualizará solo con el saludo
                      correoConductor: widget.correoLogin, 
                    ),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "Aceptar",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFC0392B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Código de conductor incorrecto."),
          backgroundColor: Colors.red),
    );
    for (var c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text("Verificación Conductor"),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text('Seguridad Conductor',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => _buildOtpBox(index))),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _validarCodigo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Verificar',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
            counterText: '',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (value.length == 1 && index == 5) {
            _validarCodigo();
          }
        },
      ),
    );
  }
}