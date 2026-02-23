import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // IP centralizada
  final String baseUrl = "http://192.168.90.54/TransTunja";

  // --- SECCIÓN: LOGIN (MYSQL/PHP) ---

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login.php');

    try {
      // Usamos .trim() para evitar espacios accidentales que causan fallos de login
      final String cleanUser = username.trim();
      final String cleanPass = password.trim();

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": cleanUser, // Puede ser nombreUsuario o correo
          "password": cleanPass,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // El servidor debe responder con 'success' true/false
        if (data['success'] == true) {
          print("Login exitoso: ${data['message']}");
          return true;
        } else {
          print("Fallo de login: ${data['message']}");
          return false;
        }
      }
      return false;
    } catch (e) {
      print("Error de conexión al servidor: $e");
      return false;
    }
  }

  // --- SECCIÓN: REGISTRO EN BASE DE DATOS (MYSQL/PHP) ---

  Future<void> enviarCodigoVerificacion({
    required BuildContext context,
    required Map<String, dynamic> userData,
  }) async {
    final url = Uri.parse('$baseUrl/registro.php');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'nombre': userData['username'],
          'documento': userData['documento'],
          'apellido': userData['apellidos'],
          'password': userData['password'],
          'telefono': userData['telefono'],
          'email': userData['email'],
          'fecha_nacimiento': userData['fechaNacimiento'],
          'rol': userData['rol'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' || data['success'] == true) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("¡Registro exitoso en TransTunja!")),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${data['message'] ?? 'No se pudo registrar'}")),
          );
        }
      }
    } catch (e) {
      print("Error de vinculación con la base de datos: $e");
    }
  }

  // --- SECCIÓN: REDES SOCIALES (GOOGLE) ---

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = kIsWeb
          ? GoogleSignIn(clientId: "497369853822-0isc65qnt3kifgulabqklbdra3983mdk.apps.googleusercontent.com")
          : GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Error en Google Sign In: $e");
      return null;
    }
  }

  // --- SECCIÓN: REDES SOCIALES (FACEBOOK) ---

  static Future<UserCredential?> signInWithFacebook() async {
    try {
      final FacebookAuthProvider facebookProvider = FacebookAuthProvider();
      return await FirebaseAuth.instance.signInWithPopup(facebookProvider);
    } catch (e) {
      print("Error en Facebook Sign In: $e");
      return null;
    }
  }
}