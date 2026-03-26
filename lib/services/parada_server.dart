import 'dart:convert';
import 'dart:async'; // Para TimeoutException
import 'package:http/http.dart' as http;

// Importación corregida con la ruta absoluta de tu proyecto
import 'package:app_transtunja/models/parada_model.dart';

class ParadaService {
  final String baseUrl;

  // RECUERDA: Ahora la baseUrl debe ser algo como 'https://tudominio.com/api'
  ParadaService({required this.baseUrl});

  // --- MÉTODO PARA LISTAR ---
  Future<List<ParadaModel>> obtenerParadas() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/obtener_paradas.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (response.body.startsWith('[')) {
          List data = json.decode(response.body);
          return data.map((item) => ParadaModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error obtenerParadas: $e");
      return [];
    }
  }

  // --- MÉTODO PARA ELIMINAR ---
  Future<Map<String, dynamic>> eliminarParada(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/eliminar_parada.php'),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {'id_parada': id},
      ).timeout(const Duration(seconds: 10));

      return json.decode(response.body);
    } catch (e) {
      print("Error eliminarParada: $e");
      return {"success": false, "message": "Error de conexión"};
    }
  }

  // --- MÉTODO PARA GUARDAR (NUEVO / EDICIÓN) ---
  Future<Map<String, dynamic>> guardarParadaDirecto(
      Map<String, dynamic> datos) async {
    try {
      // Usamos editar_parada.php para que procese los cambios
      final response = await http.post(
        Uri.parse('$baseUrl/editar_parada.php'),
        body: datos,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'Error en el servidor: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
