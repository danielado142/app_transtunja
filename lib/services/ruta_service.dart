import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// --- FUNCIONES DE UTILIDAD PARA EL MAPEO DE DATOS ---

String _pickString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return '';
}

String? _pickNullableString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return null;
}

bool _pickBool(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      if (['1', 'true', 'activo', 'activa', 'habilitada', 'habilitado']
          .contains(normalized)) return true;
      if ([
        '0',
        'false',
        'inactivo',
        'inactiva',
        'deshabilitada',
        'deshabilitado',
        'eliminado'
      ].contains(normalized)) return false;
    }
  }
  return true;
}

Map<String, dynamic> _unwrapMap(Map<String, dynamic> json) {
  if (json['ruta'] is Map<String, dynamic>)
    return json['ruta'] as Map<String, dynamic>;
  if (json['data'] is Map<String, dynamic>)
    return json['data'] as Map<String, dynamic>;
  return json;
}

List<Map<String, dynamic>> _unwrapList(dynamic decoded) {
  if (decoded is List)
    return decoded.whereType<Map<String, dynamic>>().toList();
  if (decoded is Map<String, dynamic>) {
    if (decoded['routes'] is List)
      return (decoded['routes'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    if (decoded['data'] is List)
      return (decoded['data'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
  }
  return [];
}

List<LatLng> _parsePoints(dynamic raw) {
  dynamic value = raw;
  if (value == null) return [];
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return [];
    try {
      value = jsonDecode(trimmed);
    } catch (_) {
      return [];
    }
  }
  if (value is! List) return [];
  return value
      .map<LatLng?>((item) {
        if (item is Map<String, dynamic>) {
          final lat = item['lat'] ?? item['latitude'] ?? item['latitud'];
          final lng = item['lng'] ??
              item['longitude'] ??
              item['longitud'] ??
              item['lon'];
          if (lat == null || lng == null) return null;
          return LatLng(
              double.parse(lat.toString()), double.parse(lng.toString()));
        }
        if (item is List && item.length >= 2) {
          return LatLng(double.parse(item[0].toString()),
              double.parse(item[1].toString()));
        }
        return null;
      })
      .whereType<LatLng>()
      .toList();
}

List<Map<String, dynamic>> _serializePoints(List<LatLng> points) {
  return points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();
}

// --- MODELOS DE DATOS ---

class EditableRouteData {
  final String routeId;
  final String nombre;
  final String destino;
  final List<LatLng> waypoints;
  final List<LatLng> polylinePoints;
  final bool habilitada;

  EditableRouteData({
    required this.routeId,
    required this.nombre,
    required this.destino,
    required this.waypoints,
    required this.polylinePoints,
    this.habilitada = true,
  });

  factory EditableRouteData.fromJson(Map<String, dynamic> json) {
    final source = _unwrapMap(json);
    final parsedWaypoints =
        _parsePoints(source['waypoints'] ?? source['marcadores'] ?? []);
    final parsedPolyline =
        _parsePoints(source['coordenadas'] ?? source['ruta'] ?? []);

    return EditableRouteData(
      routeId: _pickString(source, ['id_ruta', 'route_id', 'id']),
      nombre: _pickString(source, ['nombre', 'nombre_ruta']),
      destino: _pickString(source, ['destino']),
      waypoints: parsedWaypoints,
      polylinePoints:
          parsedPolyline.isNotEmpty ? parsedPolyline : parsedWaypoints,
      habilitada: _pickBool(source, ['habilitada', 'estado', 'activo']),
    );
  }
}

class RouteListItem {
  final String routeId;
  final String nombre;
  final String destino;
  final bool habilitada;
  final String? fecha;

  RouteListItem({
    required this.routeId,
    required this.nombre,
    required this.destino,
    required this.habilitada,
    this.fecha,
  });

  factory RouteListItem.fromJson(Map<String, dynamic> json) {
    return RouteListItem(
      routeId: _pickString(json, ['routeId', 'id_ruta', 'id']),
      nombre: _pickString(json, ['nombre', 'nombre_ruta']),
      destino: _pickString(json, ['destino']),
      habilitada: _pickBool(json, ['habilitada', 'estado', 'activo']),
      fecha: _pickNullableString(json, ['fecha', 'fecha_creacion']),
    );
  }
}

// --- CLASE SERVICIO PRINCIPAL ---

class RutaService {
  final String baseUrl =
      "https://springgreen-ferret-866521.hostingersite.com/TransTunja/api";
  final http.Client _client = http.Client();

  // Obtener historial completo (usado en historial_rutas.dart)
  Future<List<RouteListItem>> obtenerHistorialRutas() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/obtener_rutas.php'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final rawList = _unwrapList(decoded);
        return rawList.map((e) => RouteListItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error en obtenerHistorialRutas: $e");
      return [];
    }
  }

  // Guardar una nueva ruta
  Future<Map<String, dynamic>> guardarRuta({
    required String routeId,
    required String nombre,
    required String destino,
    required List<LatLng> waypoints,
    required List<LatLng> polylinePoints,
  }) async {
    final payload = {
      'id_ruta': routeId,
      'nombre': nombre.trim(),
      'destino': destino.trim(),
      'waypoints': jsonEncode(_serializePoints(waypoints)),
      'coordenadas': jsonEncode(_serializePoints(polylinePoints)),
    };

    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/guardar_ruta.php'),
        body: payload,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // Habilitar o deshabilitar ruta (Toggle)
  Future<Map<String, dynamic>> toggleRouteStatus({
    required String routeId,
    required bool habilitar,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/toggle_ruta.php'),
        body: {
          'id_ruta': routeId,
          'estado': habilitar ? 'activo' : 'inactivo',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
