class UserModel {
  final int id_usuario;
  final String name;
  final String email;
  final String phone;
  final String? gender;
  final bool notificationsEnabled;
  final bool darkMode;

  UserModel({
    required this.id_usuario,
    required this.name,
    required this.email,
    required this.phone,
    this.gender,
    this.notificationsEnabled = true,
    this.darkMode = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Evitamos el error de 'null' usando un valor por defecto si falla
      id_usuario: json['id_usuario'] is int
          ? json['id_usuario']
          : int.parse(json['id_usuario']?.toString() ?? '0'),
      name: json['nombre'] ?? '',
      email: json['correo'] ?? '',
      phone: json['telefono'] ?? '',
      gender: json['genero'],
      notificationsEnabled:
          (json['notificaciones'] == 1 || json['notificaciones'] == true),
      darkMode: (json['modo_oscuro'] == 1 || json['modo_oscuro'] == true),
    );
  }
}
