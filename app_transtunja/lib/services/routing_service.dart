import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  RoutingService({http.Client? client, String? osrmBaseUrl})
    : _client = client ?? http.Client(),
      _osrmBaseUrl = osrmBaseUrl ?? 'https://router.project-osrm.org';

  final http.Client _client;
  final String _osrmBaseUrl;

  Future<LatLng> snapPointToRoad(LatLng point) async {
    final uri = Uri.parse(
      '$_osrmBaseUrl/nearest/v1/driving/'
      '${point.longitude},${point.latitude}?number=1',
    );

    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo ajustar el punto a la vía.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final waypoints = (data['waypoints'] as List?) ?? [];

    if (data['code'] != 'Ok' || waypoints.isEmpty) {
      throw Exception('OSRM no encontró una vía cercana.');
    }

    final location = (waypoints.first['location'] as List).cast<num>();

    return LatLng(location[1].toDouble(), location[0].toDouble());
  }

  Future<List<LatLng>> buildRoadPolyline(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return List<LatLng>.from(waypoints);

    final coords = waypoints
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');

    final uri = Uri.parse(
      '$_osrmBaseUrl/route/v1/driving/$coords'
      '?overview=full&geometries=geojson&steps=false',
    );

    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo calcular la ruta.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = (data['routes'] as List?) ?? [];

    if (data['code'] != 'Ok' || routes.isEmpty) {
      throw Exception('No hay ruta disponible entre los puntos.');
    }

    final geometry = routes.first['geometry'] as Map<String, dynamic>;
    final coordinates = (geometry['coordinates'] as List?) ?? [];

    return coordinates.map<LatLng>((coord) {
      final pair = (coord as List).cast<num>();
      return LatLng(pair[1].toDouble(), pair[0].toDouble());
    }).toList();
  }
}
