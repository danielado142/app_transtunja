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

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

  // --- LOGIN ---
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
      return response.statusCode == 200 &&
          jsonDecode(response.body)['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  // --- REGISTRO SMS (FIREBASE) ---
  Future<void> enviarCodigoVerificacion({
    required BuildContext context,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // Limpiamos el teléfono por si viene con espacios
      String tel = userData['telefono'].toString().trim().replaceAll(' ', '');
      String telFormateado = tel.startsWith('+') ? tel : '+57$tel';

      await _auth.verifyPhoneNumber(
        phoneNumber: telFormateado,
        verificationCompleted: (PhoneAuthCredential cred) async {
          // Algunos dispositivos Android verifican el SMS automáticamente
          await _auth.signInWithCredential(cred);

          // Registro final en MySQL tras validación automática
          await insertarUsuarioMySQL(userData);

          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/home_usuario');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("Error Firebase: ${e.message}");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error SMS: ${e.message}")),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          // ✅ Navega a la interfaz de los 6 cuadritos enviando los datos necesarios
          Navigator.pushNamed(
            context,
            '/sms_verification',
            arguments: {
              'verificationId': verificationId,
              'userData': userData,
            },
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      debugPrint("Error crítico SMS: $e");
    }
  }

  // --- INSERTAR EN MYSQL (XAMPP / HOSTINGER) ---
  // CORREGIDO: Ahora asegura que 'soloValidar' sea false para guardar realmente
  Future<bool> insertarUsuarioMySQL(Map<String, dynamic> datos) async {
    try {
      // ✅ PASO CLAVE: Sobrescribimos para que el PHP ejecute el INSERT
      datos['soloValidar'] = false;

      final response = await http
          .post(
            Uri.parse("${ApiConfig.baseUrl}/registro.php"),
            headers: _headers,
            body: jsonEncode(datos),
          )
          .timeout(const Duration(seconds: 15));

      final resBody = jsonDecode(response.body);

      if (resBody['status'] != 'success') {
        debugPrint("Error del servidor: ${resBody['message']}");
      }

      return response.statusCode == 200 &&
          (resBody['status'] == 'success' || resBody['success'] == true);
    } catch (e) {
      debugPrint("Error insertando en MySQL: $e");
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

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null && context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => RoleSelectionScreen(userData: {
              'nombreUsuario': userCredential.user!.displayName,
              'email': userCredential.user!.email,
              'google_id': userCredential.user!.uid
            }),
          ),
          (route) => false,
        );
      }
      return userCredential;
    } catch (e) {
      debugPrint("Error Google Sign In: $e");
      return null;
    }
  }

  // --- GUARDAR PARADA ---
  Future<bool> guardarParada({
    required String nombre,
    required double latitud,
    required double longitud,
    required int idRuta,
    required String dia,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/guardar_parada.php');
    try {
      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode({
              "nombre": nombre,
              "latitud": latitud,
              "longitud": longitud,
              "id_ruta": idRuta,
              "dia": dia,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("Error al guardar parada: $e");
      return false;
    }
  }

  // --- CERRAR SESIÓN ---
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
