import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import 'package:app_transtunja/config/constants.dart';

class ProfileService {
  // Definimos la base URL sacándola de tus constantes
  final String _baseUrl = ApiConfig.baseUrl;

  /// Obtiene el perfil del usuario (Simulado por ahora)
  Future<UserModel> getUserProfile() async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id_usuario: 1,
      name: "Usuario de Tunja",
      email: "usuario@ejemplo.com",
      phone: "3232499640",
      gender: "Femenino",
      notificationsEnabled: true,
      darkMode: false,
    );
  }

  /// ACTUALIZACIÓN REAL: Conecta con el PHP y envía los datos
  Future<UserModel> updateUserProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String gender,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/update_profile.php'),
        body: {
          'id_usuario': userId,
          'nombreCompleto': name,
          'correo': email,
          'telefono': phone,
          'genero': gender,
        },
      );

      print("Respuesta servidor: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData['success'] == true) {
          return UserModel(
            id_usuario: int.parse(userId),
            name: name,
            email: email,
            phone: phone,
            gender: gender,
            notificationsEnabled: true,
            darkMode: false,
          );
        } else {
          throw Exception(decodedData['message'] ?? 'Error en el servidor');
        }
      } else {
        throw Exception('Error de conexión: Código ${response.statusCode}');
      }
    } catch (e) {
      print("Error detallado: $e");
      throw Exception(
          "Error de conexión: Verifica tu internet o el archivo PHP.");
    }
  }

  Future<UserModel> updatePreferences({
    bool? notificationsEnabled,
    bool? darkMode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return UserModel(
      id_usuario: 1,
      name: "Usuario de Tunja",
      email: "usuario@ejemplo.com",
      phone: "300 123 4567",
      notificationsEnabled: notificationsEnabled ?? true,
      darkMode: darkMode ?? false,
    );
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
