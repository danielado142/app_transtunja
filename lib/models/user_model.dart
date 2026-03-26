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
    this.gender,
    this.notificationsEnabled = true,
    this.darkMode = false,
  });

  // Esto servirá para cuando conectes tu base de datos de XAMPP
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['nombre'],
      email: json['correo'],
      phone: json['telefono'],
      gender: json['genero'],
      notificationsEnabled: json['notificaciones'] == 1,
      darkMode: json['modo_oscuro'] == 1,
    );
  }
}
