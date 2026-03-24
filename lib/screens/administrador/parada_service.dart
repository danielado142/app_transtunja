import 'dart:convert';
import 'package:http/http.dart' as http;

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
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return ParadaModel(
      id: int.tryParse(json['id_parada'].toString()),
      nombre: (json['nombre_parada'] ?? '').toString(),
      referencia: (json['referencia'] ?? '').toString(),
      latitud: parseDouble(json['latitud']),
      longitud: parseDouble(json['longitud']),
      estado: (json['estado'] ?? 'activo').toString(),
    );
  }

  Map<String, String> toMap() {
    return {
      if (id != null) 'id_parada': id.toString(),
      'nombre_parada': nombre,
      'referencia': referencia,
      'latitud': latitud.toString(),
      'longitud': longitud.toString(),
      'estado': estado,
    };
  }
}

class ParadaService {
  final String baseUrl;

  const ParadaService({required this.baseUrl});

  Uri _buildUri(String fileName) {
    if (baseUrl.startsWith('http')) {
      return Uri.parse('$baseUrl/$fileName');
    }
    return Uri.parse('${Uri.base.origin}$baseUrl/$fileName');
  }

  Future<List<ParadaModel>> obtenerParadas() async {
    final response = await http.get(_buildUri('obtener_paradas.php'));

    if (response.statusCode != 200) {
      throw Exception('No se pudieron obtener las paradas.');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded.map((e) => ParadaModel.fromJson(e)).toList();
    }

    if (decoded is Map && decoded['data'] is List) {
      return (decoded['data'] as List)
          .map((e) => ParadaModel.fromJson(e))
          .toList();
    }

    return [];
  }

  Future<Map<String, dynamic>> guardarParada(ParadaModel parada) async {
    final response = await http.post(
      _buildUri('guardar_parada.php'),
      body: parada.toMap(),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo guardar la parada.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {'success': true};
  }

  Future<Map<String, dynamic>> eliminarParada(int idParada) async {
    final response = await http.post(
      _buildUri('eliminar_parada.php'),
      body: {'id_parada': idParada.toString()},
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo eliminar la parada.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {'success': true};
  }
}
