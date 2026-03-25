import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_transtunja/config/constants.dart';

class ParadaModel {
  final int? id;
  final String nombre;
  final String referencia;
  final double latitud;
  final double longitud;
  final String estado;

  const ParadaModel({
    this.id,
    required this.nombre,
    required this.referencia,
    required this.latitud,
    required this.longitud,
    this.estado = 'activo',
  });

  factory ParadaModel.fromJson(Map<String, dynamic> json) {
    return ParadaModel(
      id: json['id'] == null ? null : int.tryParse(json['id'].toString()),
      nombre: (json['nombre'] ?? '').toString(),
      referencia: (json['referencia'] ?? '').toString(),
      latitud: double.tryParse(json['latitud'].toString()) ?? 5.5353,
      longitud: double.tryParse(json['longitud'].toString()) ?? -73.3678,
      estado: (json['estado'] ?? 'activo').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'referencia': referencia,
      'latitud': latitud,
      'longitud': longitud,
      'estado': estado,
    };
  }
}

// --- SERVICIO ---
class ParadaService {
  final String baseUrl;

  ParadaService({required String baseUrl}) : baseUrl = baseUrl.trim();

  // Función corregida para evitar el error de "Origin" y "No host specified"
  Uri _buildUri(String fileName) {
    // Usamos ApiConfig.baseUrl o la baseUrl pasada al constructor
    final String domain = ApiConfig.baseUrl.trim();

    final String fullUrl =
        domain.endsWith('/') ? '$domain$fileName' : '$domain/$fileName';

    return Uri.parse(fullUrl);
  }

  // 1. OBTENER PARADAS
  Future<List<ParadaModel>> obtenerParadas() async {
    try {
      final url = _buildUri('obtener_paradas.php');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Error del servidor: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((e) => ParadaModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error de conexión al obtener: $e');
    }
  }

  // 2. GUARDAR PARADA (Modificado para enviar JSON real)
  Future<Map<String, dynamic>> guardarParada(ParadaModel parada) async {
    try {
      final url = _buildUri('guardar_parada.php');

      // IMPORTANTE: Tu PHP usa php://input, por eso enviamos jsonEncode
      final response = await http.post(
        url,
        headers: {
          'Content-Type':
              'application/json', // Notifica al servidor que va un JSON
        },
        body: jsonEncode(parada.toJson()), // Convertimos el objeto a texto JSON
      );

      if (response.statusCode != 200) {
        throw Exception('Error al guardar: ${response.statusCode}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('No se pudo guardar la parada: $e');
    }
  }

  // 3. ELIMINAR PARADA
  Future<Map<String, dynamic>> eliminarParada(int idParada) async {
    try {
      final url = _buildUri('eliminar_parada.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_parada': idParada}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar: ${response.statusCode}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error de conexión al eliminar: $e');
    }
  }
}
