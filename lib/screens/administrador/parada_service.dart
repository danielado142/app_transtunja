import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parada_model.dart';

class ParadaService {
  final String baseUrl;

  ParadaService({required this.baseUrl});

  // --- MÉTODO PARA LISTAR ---
  Future<List<ParadaModel>> obtenerParadas() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/obtener_paradas.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((item) => ParadaModel.fromJson(item)).toList();
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
      );
      return json.decode(response.body);
    } catch (e) {
      print("Error eliminarParada: $e");
      return {"success": false};
    }
  }

  // --- MÉTODO PARA GUARDAR (CORREGIDO Y UNIFICADO) ---
  // Este método recibe el mapa con nombre_parada, id_ruta y dia_semana
  Future<Map<String, dynamic>> guardarParadaDirecto(
      Map<String, dynamic> datos) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/guardar_parada.php'),
            headers: {
              "Content-Type":
                  "application/json", // Indica al servidor que enviamos JSON
              "Accept": "application/json",
            },
            body: json.encode(datos), // Convierte el mapa de Dart a String JSON
          )
          .timeout(const Duration(seconds: 15));

      // Importante para depurar en la consola de VS Code
      print("RESPUESTA SERVIDOR: ${response.body}");

      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      } else {
        return {
          "status": "error",
          "message": "El servidor devolvió una respuesta vacía"
        };
      }
    } catch (e) {
      print("Error en guardarParadaDirecto: $e");
      return {"status": "error", "message": "Error de conexión: $e"};
    }
  }
}
