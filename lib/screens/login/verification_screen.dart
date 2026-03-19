import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_transtunja/config/constants.dart';
// IMPORTANTE: Esta es la conexión con el archivo de tu compañera
import 'package:app_transtunja/screens/conductor/home_conductor.dart';

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
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  bool _isLoading = false;

  void _mostrarAlertaExito() {
    print("DEBUG: ABRIENDO DIALOGO");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Código Correcto", textAlign: TextAlign.center),
          content: const Text(
            "Acceso validado. Presiona aceptar para entrar al panel de conductor.",
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  print(">>> NAVEGANDO A INTERFAZ CONDUCTOR <<<");

                  // 1. Cerramos la alerta
                  Navigator.of(dialogContext).pop();

                  // 2. Navegamos a HomeConductor usando MaterialPageRoute
                  // Esto asegura que entres a la interfaz que me pasaste
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeConductor(
                        nombreConductor:
                            widget.userData['nombres'] ?? 'Conductor',
                      ),
                    ),
                    (route) =>
                        false, // No permite volver atrás a la verificación
                  );
                },
                child: const Text(
                  "ACEPTAR",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verificarCodigo() async {
    String smsCode = _controllers.map((c) => c.text).join();
    if (smsCode.length < 6) return;
    setState(() => _isLoading = true);

    try {
      // Verificación con Firebase
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Guardar en tu base de datos XAMPP
      try {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/registro.php'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(widget.userData),
        );
      } catch (e) {
        print("Error XAMPP: $e");
      }

      if (!mounted) return;
      _mostrarAlertaExito();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código incorrecto o expirado")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verificación de Seguridad"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.vibration, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Ingresa los 6 dígitos enviados",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _controllers[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      counterText: "",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && index < 5)
                        FocusScope.of(context).nextFocus();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.red)
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _verificarCodigo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        "VERIFICAR",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
