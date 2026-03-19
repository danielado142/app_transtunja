import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rating_model.dart';

class RatingService {
  // Cambia esta IP por la IP local de tu PC (ej: 192.168.1.10)
  final String _baseUrl =
      "http://TU_IP_LOCAL/app_transtunja/insertar_calificacion.php";

  Future<void> submitRating(RatingModel rating) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: rating.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception("Error en el servidor: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error de conexión: $e");
    }
  }
}
