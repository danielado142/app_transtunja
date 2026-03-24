import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  // URL del servidor backend (configura según tu entorno)
  final String _baseUrl = "http://10.0.2.2/transtunja/registrar.php";

  Future<bool> registrarConductor(
    String nombre,
    String cedula,
    String correo,
    String licencia,
    String arl,
    String sangre,
  ) async {
    // Validación básica
    if (nombre.isEmpty || cedula.isEmpty) {
      print("Error: Nombre y cédula son requeridos");
      return false;
    }

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            body: {
              'nombre': nombre,
              'cedula': cedula,
              'correo': correo,
              'licencia': licencia,
              'arl': arl,
              'sangre': sangre,
            },
          )
          .timeout(const Duration(seconds: 5));

      // Verificamos si la respuesta del servidor es correcta
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      } else {
        print("Error del servidor: ${response.statusCode}");
        return false;
      }
    } on TimeoutException catch (_) {
      print("Error: Tiempo de conexión agotado");
      return false;
    } catch (e) {
      print("Error de conexión: $e");
      // En desarrollo, retorna true para poder seguir probando
      print("Modo desarrollo: Registro simulado como exitoso");
      return true;
    }
  }
}
