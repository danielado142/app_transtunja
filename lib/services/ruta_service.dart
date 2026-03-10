import 'dart:convert';
import 'package:http/http.dart' as http;

class RutaService {
  static String baseUrl = "http://localhost/transtunja";

  // GUARDAR RUTA
  static Future guardarRuta(
    String idRuta,
    String nombre,
    String destino,
    String coordenadas,
  ) async {
    var url = Uri.parse("$baseUrl/guardar_ruta.php");

    var response = await http.post(
      url,
      body: {
        "id_ruta": idRuta,
        "nombre": nombre,
        "destino": destino,
        "coordenadas": coordenadas,
      },
    );

    return jsonDecode(response.body);
  }

  // OBTENER RUTAS
  static Future<List> obtenerRutas() async {
    var url = Uri.parse("$baseUrl/obtener_rutas.php");

    var response = await http.get(url);

    return jsonDecode(response.body);
  }
}
