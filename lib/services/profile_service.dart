import '../models/user_model.dart';

class ProfileService {
  Future<UserModel> getUserProfile() async {
    await Future.delayed(const Duration(seconds: 1)); // Simula red
    return UserModel(
      name: "Usuario de Tunja",
      email: "usuario@ejemplo.com",
      phone: "300 123 4567",
      gender: "Masculino",
    );
  }

  Future<UserModel> updateUserProfile({
    required String name,
    required String email,
    required String phone,
    required String gender,
  }) async {
    // Aquí irá tu conexión a XAMPP luego
    return UserModel(name: name, email: email, phone: phone, gender: gender);
  }

  Future<UserModel> updatePreferences({
    bool? notificationsEnabled,
    bool? darkMode,
  }) async {
    return UserModel(
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
