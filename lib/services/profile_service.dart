import '../models/user_model.dart';

class ProfileService {
  static UserModel _currentUser = UserModel(
    name: 'Usuario TransTunja',
    email: 'usuario@email.com',
    phone: '',
    gender: 'Prefiero no decirlo',
    notificationsEnabled: true,
    darkMode: false,
  );

  Future<UserModel> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _currentUser;
  }

  Future<UserModel> updateUserProfile({
    required String name,
    required String email,
    required String phone,
    required String? gender,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _currentUser = _currentUser.copyWith(
      name: name,
      email: email,
      phone: phone,
      gender: gender,
    );

    return _currentUser;
  }

  Future<UserModel> updatePreferences({
    bool? notificationsEnabled,
    bool? darkMode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    _currentUser = _currentUser.copyWith(
      notificationsEnabled: notificationsEnabled,
      darkMode: darkMode,
    );

    return _currentUser;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 250));
  }
}
