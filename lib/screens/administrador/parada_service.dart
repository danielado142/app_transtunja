import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_transtunja/models/parada_model.dart';

class ParadaService {
  final String baseUrl;

  ParadaService({required this.baseUrl});

  Future<List<ParadaModel>> obtenerParadas() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/obtener_paradas.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Error HTTP ${response.statusCode}');
      }

      final dynamic decoded = json.decode(response.body);

      final List<dynamic> data = decoded is List
          ? decoded
          : (decoded['data'] ?? decoded['paradas'] ?? []);

      return data
          .map((item) => ParadaModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    } catch (e) {
      print('Error obtenerParadas: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> eliminarParada(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/eliminar_parada.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {'id_parada': id},
      ).timeout(const Duration(seconds: 15));

      if (response.body.isNotEmpty) {
        return Map<String, dynamic>.from(json.decode(response.body));
      }

      return {
        'success': false,
        'message': 'El servidor devolvió una respuesta vacía',
      };
    } catch (e) {
      print('Error eliminarParada: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  Future<Map<String, dynamic>> guardarParadaDirecto(
    Map<String, dynamic> datos,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/guardar_parada.php'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(datos),
          )
          .timeout(const Duration(seconds: 15));

      print('RESPUESTA SERVIDOR: ${response.body}');

      if (response.body.isNotEmpty) {
        return Map<String, dynamic>.from(json.decode(response.body));
      }

      return {
        'success': false,
        'message': 'El servidor devolvió una respuesta vacía',
      };
    } catch (e) {
      print('Error en guardarParadaDirecto: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}
