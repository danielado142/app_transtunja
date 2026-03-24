import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:app_transtunja/config/constants.dart';
import 'package:app_transtunja/screens/login/role_selection_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = kIsWeb
      ? GoogleSignIn(
          clientId:
              "497369853822-0isc65qnt3kifgulabqklbdra3983mdk.apps.googleusercontent.com",
        )
      : GoogleSignIn();

  // ✅ Headers limpios para Clever Cloud (Sin bloqueos de InfinityFree)
  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  // --- LOGIN TRADICIONAL ---
  Future<bool> login(String username, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/login.php');
    try {
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode({
              "correo": username.trim(),
              "contrasena": password.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error login: $e");
      return false;
    }
  }

  // --- REGISTRO SMS (FIREBASE) ---
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
          // Al completar SMS, insertamos en MySQL de la nube
          await insertarUsuarioMySQL(userData);
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/mapa_pasajero');
          }
        },
        verificationFailed: (e) {
          debugPrint("❌ Error SMS Firebase: ${e.code}");
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error SMS: ${e.message}")));
          }
        },
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

  // --- INSERTAR EN MYSQL (CLEVER CLOUD) ---
  Future<bool> insertarUsuarioMySQL(Map<String, dynamic> datos) async {
    try {
      final response = await http
          .post(
            Uri.parse("${ApiConfig.baseUrl}/registro.php"),
            headers: _headers,
            body: jsonEncode(datos),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error MySQL: $e");
      return false;
    }
  }

  // --- GOOGLE SIGN IN ---
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

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
        await _sincronizarConServidor(user);

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

  Future<void> _sincronizarConServidor(User user) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth_google.php'),
        headers: _headers,
        body: jsonEncode({
          "nombre": user.displayName ?? "Usuario Google",
          "email": user.email,
          "google_id": user.uid,
        }),
      );
    } catch (e) {
      debugPrint("Error sincronización: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
