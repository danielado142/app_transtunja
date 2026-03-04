import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // IP centralizada (Confirmada: 192.168.0.103)
  final String baseUrl = "http://192.168.0.103/TransTunja";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- SECCIÓN: LOGIN (MYSQL/PHP) ---

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login.php');

    try {
      final String cleanUser = username.trim();
      final String cleanPass = password.trim();

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "correo":
                  cleanUser, // Cambiado a 'correo' para coincidir con tu login.php
              "contrasena": cleanPass, // Cambiado a 'contrasena'
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Ajustado para manejar el 'status' que definimos antes
        if (data['status'] == 'success' || data['success'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error de conexión al servidor: $e");
      return false;
    }
  }

  // --- SECCIÓN: REGISTRO (SMS FIREBASE + MYSQL) ---

  Future<void> enviarCodigoVerificacion({
    required BuildContext context,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+57${userData['telefono']}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          await insertarUsuarioMySQL(userData);
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/mapa_pasajero',
              (route) => false,
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error de Firebase: ${e.message}")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.pushNamed(
            context,
            '/verification',
            arguments: {'verificationId': verificationId, 'userData': userData},
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      debugPrint("Error al enviar código: $e");
    }
  }

  Future<void> verificarCodigo({
    required BuildContext context,
    required String verificationId,
    required String smsCode,
    required Map<String, dynamic> userData,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);

      final response = await http
          .post(
            Uri.parse('$baseUrl/registro.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(userData),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/mapa_pasajero',
              (route) => false,
            );
          }
        } else {
          throw Exception(result['message'] ?? "Error en el servidor");
        }
      } else {
        throw Exception("Error de conexión (Código: ${response.statusCode})");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> insertarUsuarioMySQL(Map<String, dynamic> datos) async {
    final url = Uri.parse("$baseUrl/registro.php");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(datos),
      );
      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        return res['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error conectando a XAMPP: $e");
      return false;
    }
  }

  // --- SECCIÓN: REDES SOCIALES (GOOGLE Y FACEBOOK) ---

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = kIsWeb
          ? GoogleSignIn(
              clientId:
                  "497369853822-0isc65qnt3kifgulabqklbdra3983mdk.apps.googleusercontent.com",
            )
          : GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Error en Google Sign In: $e");
      return null;
    }
  }

  static Future<UserCredential?> signInWithFacebook() async {
    try {
      final FacebookAuthProvider facebookProvider = FacebookAuthProvider();
      // En Web usa Popup, en Móvil requiere configuración adicional de SDK
      if (kIsWeb) {
        return await FirebaseAuth.instance.signInWithPopup(facebookProvider);
      } else {
        // Nota: Para móvil se recomienda usar el paquete flutter_facebook_auth
        return await FirebaseAuth.instance.signInWithProvider(facebookProvider);
      }
    } catch (e) {
      debugPrint("Error en Facebook Sign In: $e");
      return null;
    }
  }
}
