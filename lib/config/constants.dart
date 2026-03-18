// lib/config/constants.dart
class ApiConfig {
  // La IP que cambia según tu red actual
  static const String _ip = '192.168.0.102';

  // El nombre de tu carpeta en htdocs (XAMPP)
  static const String _folder = 'TransTunja';

  // La URL completa armada automáticamente
  static const String baseUrl = 'http://$_ip/$_folder';
}
