import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// ✅ Import de tus constantes (IP de XAMPP)
import 'package:app_transtunja/config/constants.dart';

class AuthService {
  final String baseUrl = ApiConfig.baseUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- SECCIÓN 1: LOGIN TRADICIONAL (MYSQL/PHP) ---
  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login.php');
    try {
      final String cleanUser = username.trim();
      final String cleanPass = password.trim();

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"correo": cleanUser, "contrasena": cleanPass}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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

  // --- SECCIÓN 2: REGISTRO (SMS FIREBASE + MYSQL) ---
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

  // --- SECCIÓN 3: REDES SOCIALES (GOOGLE) ---

  // ✅ CORREGIDO: Eliminado 'static' y añadido (BuildContext context)
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      // 1. Configuración de Google Sign In
      final GoogleSignIn googleSignIn = kIsWeb
          ? GoogleSignIn(
              clientId:
                  "497369853822-0isc65qnt3kifgulabqklbdra3983mdk.apps.googleusercontent.com",
            )
          : GoogleSignIn();

      // 2. Iniciar flujo de Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      // 3. Obtener credenciales de Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Autenticar en Firebase
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      // 5. ✅ LOGICA DE SINCRONIZACIÓN CON MYSQL (XAMPP)
      if (user != null) {
        final url = Uri.parse('${ApiConfig.baseUrl}/auth_google.php');

        try {
          final response = await http.post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "nombre": user.displayName ?? "Usuario Google",
              "email": user.email,
              "google_id": user.uid,
              "foto": user.photoURL ?? "",
            }),
          );

          if (response.statusCode == 200) {
            debugPrint("Sincronizado con XAMPP: ${response.body}");
            // Si la base de datos responde OK, navegamos al mapa
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/mapa_pasajero',
                (route) => false,
              );
            }
          }
        } catch (e) {
          debugPrint("Error al enviar datos a XAMPP: $e");
        }
      }

      return userCredential;
    } catch (e) {
      debugPrint("Error en Google Sign-In: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error en Google: $e")));
      }
      return null;
    }
  }

  // Opcional: Implementación futura
  Future<UserCredential?> signInWithFacebook() async {
    debugPrint("Facebook no implementado aún");
    return null;
  }
}
