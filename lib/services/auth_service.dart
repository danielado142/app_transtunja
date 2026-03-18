import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:app_transtunja/config/constants.dart';
import 'package:app_transtunja/screens/usuario/role_selection_screen.dart';

class AuthService {
  final String baseUrl = ApiConfig.baseUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- LOGIN TRADICIONAL ---
  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login.php');
    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "correo": username.trim(),
              "contrasena": password.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success' || data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint("Error login: $e");
      return false;
    }
  }

  // --- REGISTRO SMS ---
  Future<void> enviarCodigoVerificacion({
    required BuildContext context,
    required Map<String, dynamic> userData,
  }) async {
    try {
      String tel = userData['telefono'].toString().trim().replaceAll(' ', '');
      String telFormateado = tel.startsWith('+') ? tel : '+57$tel';

      await _auth.verifyPhoneNumber(
        phoneNumber: telFormateado,
        verificationCompleted: (PhoneAuthCredential cred) async {
          await _auth.signInWithCredential(cred);
          await insertarUsuarioMySQL(userData);
          if (context.mounted)
            Navigator.pushReplacementNamed(context, '/mapa_pasajero');
        },
        verificationFailed: (e) => debugPrint("❌ Error SMS: ${e.code}"),
        codeSent: (id, token) {
          Navigator.pushNamed(
            context,
            '/verification',
            arguments: {'verificationId': id, 'userData': userData},
          );
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      debugPrint("Error crítico SMS: $e");
    }
  }

  Future<bool> insertarUsuarioMySQL(Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/registro.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(datos),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- GOOGLE SIGN IN (Modificado para Registro/Login) ---
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = kIsWeb
          ? GoogleSignIn(
              clientId:
                  "497369853822-0isc65qnt3kifgulabqklbdra3983mdk.apps.googleusercontent.com",
            )
          : GoogleSignIn();

      await googleSignIn.signOut(); // Limpia caché para elegir cuenta nueva
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        // 1. Sincronizamos con XAMPP (auth_google.php se encarga de ver si existe o crearlo)
        await _sincronizarConXampp(user);

        // 2. Navegación limpia
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => RoleSelectionScreen(
                userData: {
                  'nombreUsuario': user.displayName ?? "Usuario",
                  'email': user.email,
                  'google_id': user.uid,
                },
              ),
            ),
            (route) => false,
          );
        }
      }
      return userCredential;
    } catch (e) {
      debugPrint("Error Google: $e");
      return null;
    }
  }

  Future<void> _sincronizarConXampp(User user) async {
    try {
      await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth_google.php'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "nombre": user.displayName ?? "Usuario Google",
              "email": user.email,
              "google_id": user.uid,
            }),
          )
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint("Error sincronización XAMPP: $e");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
