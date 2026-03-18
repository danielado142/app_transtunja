import '../models/user_model.dart';
import '../repositories/profile_repository.dart';

class ProfileService {
  final ProfileRepository _repository = ProfileRepository();

  Future<UserModel> getUserProfile() {
    return _repository.getUserProfile();
  }

  Future<UserModel> updateUserProfile({
    required String name,
    required String email,
    required String phone,
    required String? gender,
  }) {
    return _repository.updateUserProfile(
      name: name,
      email: email,
      phone: phone,
      gender: gender,
    );
  }

  Future<UserModel> updatePreferences({
    bool? notificationsEnabled,
    bool? darkMode,
  }) {
    return _repository.updatePreferences(
      notificationsEnabled: notificationsEnabled,
      darkMode: darkMode,
    );
  }

  Future<void> logout() {
    return _repository.logout();
  }
}
