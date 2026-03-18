import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RutaService {
  static const String baseUrl = "http://localhost/transtunja/";

  static Future<List<Map<String, dynamic>>> obtenerRutas() async {
    try {
      final url = Uri.parse("${baseUrl}obtener_rutas.php");
      final response = await http.get(url).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .map<Map<String, dynamic>>(
                (e) => Map<String, dynamic>.from(e as Map),
              )
              .toList();
        }
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> guardarRuta(
    String idRuta,
    String nombre,
    String destino,
    String coordenadas,
  ) async {
    return _post("guardar_ruta.php", {
      "id_ruta": idRuta,
      "nombre": nombre,
      "destino": destino,
      "coordenadas": coordenadas,
    });
  }

  static Future<Map<String, dynamic>> actualizarRuta(
    String idRuta,
    String nombre,
    String destino,
    String coordenadas,
  ) async {
    return _post("actualizar_ruta.php", {
      "id_ruta": idRuta,
      "nombre": nombre,
      "destino": destino,
      "coordenadas": coordenadas,
    });
  }

  static Future<Map<String, dynamic>> deshabilitarRuta(String idRuta) async {
    return _post("deshabilitar_ruta.php", {"id_ruta": idRuta});
  }

  static Future<Map<String, dynamic>> habilitarRuta(String idRuta) async {
    return _post("habilitar_ruta.php", {"id_ruta": idRuta});
  }

  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, String> body,
  ) async {
    try {
      final url = Uri.parse("$baseUrl$endpoint");

      final response = await http
          .post(url, body: body)
          .timeout(const Duration(seconds: 12));

      return _decodeMap(response.body);
    } on TimeoutException {
      return {
        "success": false,
        "mensaje": "El servidor tardó demasiado en responder",
      };
    } catch (e) {
      return {"success": false, "mensaje": "Error de conexión: $e"};
    }
  }

  static Map<String, dynamic> _decodeMap(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    return {"success": false, "mensaje": "Respuesta inválida del servidor"};
  }
}
