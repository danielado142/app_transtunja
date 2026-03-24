import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

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

      if (normalized == '1' ||
          normalized == 'true' ||
          normalized == 'activo' ||
          normalized == 'activa' ||
          normalized == 'habilitada' ||
          normalized == 'habilitado') {
        return true;
      }

      if (normalized == '0' ||
          normalized == 'false' ||
          normalized == 'inactivo' ||
          normalized == 'inactiva' ||
          normalized == 'deshabilitada' ||
          normalized == 'deshabilitado' ||
          normalized == 'no activo' ||
          normalized == 'eliminada' ||
          normalized == 'eliminado') {
        return false;
      }
    }
  }
  return true;
}

Map<String, dynamic> _unwrapMap(Map<String, dynamic> json) {
  if (json['ruta'] is Map<String, dynamic>) {
    return json['ruta'] as Map<String, dynamic>;
  }
  if (json['data'] is Map<String, dynamic>) {
    return json['data'] as Map<String, dynamic>;
  }
  return json;
}

List<Map<String, dynamic>> _unwrapList(dynamic decoded) {
  if (decoded is List) {
    return decoded.whereType<Map<String, dynamic>>().toList();
  }

  if (decoded is Map<String, dynamic>) {
    if (decoded['data'] is List) {
      return (decoded['data'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    if (decoded['rutas'] is List) {
      return (decoded['rutas'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
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
          final lng =
              item['lng'] ??
              item['longitude'] ??
              item['longitud'] ??
              item['lon'];

          if (lat == null || lng == null) return null;

          return LatLng(
            double.parse(lat.toString()),
            double.parse(lng.toString()),
          );
        }

        if (item is List && item.length >= 2) {
          return LatLng(
            double.parse(item[0].toString()),
            double.parse(item[1].toString()),
          );
        }

        return null;
      })
      .whereType<LatLng>()
      .toList();
}

List<Map<String, dynamic>> _serializePoints(List<LatLng> points) {
  return points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();
}

Map<String, dynamic> _decodeSafeResponse(
  String body, {
  required String successMessage,
}) {
  final trimmed = body.trim();

  if (trimmed.isEmpty) {
    return {'success': true, 'message': successMessage};
  }

  final decoded = jsonDecode(trimmed);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }

  return {'success': true, 'message': successMessage};
}

class EditableRouteData {
  EditableRouteData({
    required this.routeId,
    required this.nombre,
    required this.destino,
    required this.waypoints,
    required this.polylinePoints,
    this.habilitada = true,
  });

  final String routeId;
  final String nombre;
  final String destino;
  final List<LatLng> waypoints;
  final List<LatLng> polylinePoints;
  final bool habilitada;

  factory EditableRouteData.fromJson(Map<String, dynamic> json) {
    final source = _unwrapMap(json);

    final parsedWaypoints = _parsePoints(
      source['waypoints'] ??
          source['marcadores'] ??
          source['puntos'] ??
          source['points'] ??
          [],
    );

    final parsedPolyline = _parsePoints(
      source['coordenadas'] ??
          source['polyline'] ??
          source['polyline_points'] ??
          source['ruta_real'] ??
          source['ruta'] ??
          [],
    );

    return EditableRouteData(
      routeId: _pickString(source, ['id_ruta', 'route_id', 'ruta_id', 'id']),
      nombre: _pickString(source, ['nombre', 'nombre_ruta', 'ruta_nombre']),
      destino: _pickString(source, ['destino', 'destino_ruta']),
      waypoints: parsedWaypoints,
      polylinePoints: parsedPolyline.isNotEmpty
          ? parsedPolyline
          : parsedWaypoints,
      habilitada: _pickBool(source, [
        'habilitada',
        'activo',
        'activa',
        'estado',
      ]),
    );
  }
}

class RouteListItem {
  RouteListItem({
    required this.routeId,
    required this.nombre,
    required this.destino,
    required this.habilitada,
    this.fecha,
    this.coordenadas = '[]',
  });

  final String routeId;
  final String nombre;
  final String destino;
  final bool habilitada;
  final String? fecha;
  final String coordenadas;

  factory RouteListItem.fromJson(Map<String, dynamic> json) {
    return RouteListItem(
      routeId: _pickString(json, ['id_ruta', 'route_id', 'ruta_id', 'id']),
      nombre: _pickString(json, ['nombre', 'nombre_ruta', 'ruta_nombre']),
      destino: _pickString(json, ['destino', 'destino_ruta']),
      habilitada: _pickBool(json, ['habilitada', 'activo', 'activa', 'estado']),
      fecha: _pickNullableString(json, [
        'fecha_eliminacion',
        'deleted_at',
        'fecha_creacion',
        'created_at',
        'updated_at',
        'fecha',
      ]),
      coordenadas: _pickString(json, ['coordenadas', 'ruta', 'polyline']),
    );
  }
}

class RutaService {
  RutaService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static const String _guardarEndpoint = 'guardar_ruta.php';
  static const String _actualizarEndpoint = 'actualizar_ruta.php';
  static const String _obtenerEndpoint = 'obtener_ruta.php';
  static const String _listarEndpoint = 'obtener_rutas.php';
  static const String _habilitarEndpoint = 'habilitar_ruta.php';
  static const String _deshabilitarEndpoint = 'deshabilitar_ruta.php';

  Future<List<RouteListItem>> fetchRoutes() async {
    final uri = Uri.parse('$baseUrl/$_listarEndpoint');

    http.Response response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200 || response.body.trim().isEmpty) {
      response = await _client.post(
        uri,
        headers: const {'Accept': 'application/json'},
      );
    }

    if (response.statusCode != 200) {
      throw Exception('No se pudo cargar el historial de rutas.');
    }

    final body = response.body.trim();
    if (body.isEmpty) return [];

    final decoded = jsonDecode(body);
    final rawList = _unwrapList(decoded);

    return rawList
        .map((e) => RouteListItem.fromJson(e))
        .where((e) => e.routeId.isNotEmpty)
        .toList();
  }

  Future<EditableRouteData> fetchRouteById(String routeId) async {
    final uri = Uri.parse(
      '$baseUrl/$_obtenerEndpoint?id_ruta=${Uri.encodeQueryComponent(routeId)}&id=${Uri.encodeQueryComponent(routeId)}',
    );

    http.Response response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200 || response.body.trim().isEmpty) {
      response = await _client.post(
        Uri.parse('$baseUrl/$_obtenerEndpoint'),
        body: {'id_ruta': routeId, 'id': routeId},
      );
    }

    if (response.statusCode != 200) {
      throw Exception('No se pudo cargar la ruta.');
    }

    final body = response.body.trim();
    if (body.isEmpty) {
      throw Exception('El backend devolvió una respuesta vacía.');
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Formato inválido al cargar la ruta.');
    }

    return EditableRouteData.fromJson(decoded);
  }

  Future<Map<String, dynamic>> guardarRuta({
    required String routeId,
    required String nombre,
    required String destino,
    required List<LatLng> waypoints,
    required List<LatLng> polylinePoints,
  }) async {
    final payload = {
      'id_ruta': routeId,
      'id': routeId,
      'nombre': nombre.trim(),
      'destino': destino.trim(),
      'waypoints': _serializePoints(waypoints),
      'coordenadas': _serializePoints(polylinePoints),
    };

    final response = await _postWithJsonFallback(
      endpoint: _guardarEndpoint,
      payload: payload,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al guardar la ruta.');
    }

    return _decodeSafeResponse(response.body, successMessage: 'Ruta guardada');
  }

  Future<Map<String, dynamic>> updateRoute({
    required String routeId,
    required String nombre,
    required String destino,
    required List<LatLng> waypoints,
    required List<LatLng> polylinePoints,
  }) async {
    final payload = {
      'id_ruta': routeId,
      'id': routeId,
      'nombre': nombre.trim(),
      'destino': destino.trim(),
      'waypoints': _serializePoints(waypoints),
      'coordenadas': _serializePoints(polylinePoints),
    };

    final response = await _postWithJsonFallback(
      endpoint: _actualizarEndpoint,
      payload: payload,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la ruta.');
    }

    return _decodeSafeResponse(
      response.body,
      successMessage: 'Ruta actualizada',
    );
  }

  Future<Map<String, dynamic>> toggleRouteStatus({
    required String routeId,
    required bool enabled,
  }) async {
    final endpoint = enabled ? _habilitarEndpoint : _deshabilitarEndpoint;
    final uri = Uri.parse('$baseUrl/$endpoint');

    final response = await _client.post(
      uri,
      body: {'id_ruta': routeId, 'id': routeId},
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo cambiar el estado de la ruta.');
    }

    return _decodeSafeResponse(
      response.body,
      successMessage: enabled ? 'Ruta habilitada' : 'Ruta deshabilitada',
    );
  }

  Future<http.Response> _postWithJsonFallback({
    required String endpoint,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');

    final formPayload = <String, String>{};
    payload.forEach((key, value) {
      if (value is String) {
        formPayload[key] = value;
      } else {
        formPayload[key] = jsonEncode(value);
      }
    });

    return await _client.post(
      uri,
      headers: const {'Accept': 'application/json'},
      body: formPayload,
    );
  }
}
