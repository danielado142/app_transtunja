class UserModel {
  final String name;
  final String email;
  final String phone;
  final String? gender;
  final bool notificationsEnabled;
  final bool darkMode;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.notificationsEnabled,
    required this.darkMode,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? gender,
    bool? notificationsEnabled,
    bool? darkMode,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'],
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      darkMode: json['darkMode'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'notificationsEnabled': notificationsEnabled,
      'darkMode': darkMode,
    };
  }
}
