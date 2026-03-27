import 'package:latlong2/latlong.dart';

import '../models/bus_stop_model.dart';
import '../models/destination_suggestion_model.dart';
import '../models/map_route_model.dart';
import '../models/map_summary_model.dart';
import '../models/route_model.dart';
import 'routing_service.dart';

class MapService {
  static const LatLng tunjaCenter = LatLng(5.5333, -73.3667);

  final RoutingService _routingService = RoutingService();

  Future<LatLng> getMapCenter() async {
    return tunjaCenter;
  }

  String _normalizeRouteName(RouteModel? route) {
    if (route == null) return '';
    return route.name.toLowerCase().trim();
  }

  Future<MapRouteModel?> getRouteFor(RouteModel? route) async {
    final name = _normalizeRouteName(route);

    List<LatLng> basePoints = [];

    // 🔥 R2 (Centro → Muiscas REAL)
    if (name.contains('r2') || name.contains('centro - muiscas')) {
      basePoints = const [
        LatLng(5.53320, -73.36150), // Plaza de Bolívar
        LatLng(5.54500, -73.35500), // Punto intermedio (mejora precisión)
        LatLng(5.55850, -73.34450), // Los Muiscas
      ];
    }

    // 🔥 R5 (Terminal → Centro REAL)
    else if (name.contains('r5') || name.contains('terminal - centro')) {
      basePoints = const [
        LatLng(5.51820, -73.36150), // Terminal
        LatLng(5.53060, -73.36250), // Parque Santander
        LatLng(5.53280, -73.36160), // Plaza de Bolívar
      ];
    }

    // 🔥 R8 (se mantiene pero mejorada)
    else if (name.contains('r8') || name.contains('unicentro - hospital')) {
      basePoints = const [
        LatLng(5.5487, -73.3529),
        LatLng(5.5457, -73.3552),
        LatLng(5.5398, -73.3621),
      ];
    }

    // 🔥 Default
    else {
      basePoints = const [
        LatLng(5.5333, -73.3667),
        LatLng(5.5400, -73.3600),
      ];
    }

    try {
      // 🚀 RUTA REAL POR CARRETERAS
      final routePoints = await _routingService.buildRoadPolyline(basePoints);

      return MapRouteModel(points: routePoints);
    } catch (e) {
      // ⚠️ fallback si falla OSRM
      return MapRouteModel(points: basePoints);
    }
  }

  Future<List<BusStopModel>> getBusStopsFor(RouteModel? route) async {
    final name = _normalizeRouteName(route);

    // 🔥 R2 actualizado
    if (name.contains('r2') || name.contains('centro - muiscas')) {
      return const [
        BusStopModel(
          name: 'Plaza de Bolívar',
          position: LatLng(5.53320, -73.36150),
          isMain: true,
        ),
        BusStopModel(
          name: 'Los Muiscas',
          position: LatLng(5.55850, -73.34450),
          isMain: true,
        ),
      ];
    }

    // 🔥 R5 actualizado
    if (name.contains('r5') || name.contains('terminal - centro')) {
      return const [
        BusStopModel(
          name: 'Terminal',
          position: LatLng(5.51820, -73.36150),
          isMain: true,
        ),
        BusStopModel(
          name: 'Parque Santander',
          position: LatLng(5.53060, -73.36250),
        ),
        BusStopModel(
          name: 'Plaza de Bolívar',
          position: LatLng(5.53280, -73.36160),
          isMain: true,
        ),
      ];
    }

    if (name.contains('r8') || name.contains('unicentro - hospital')) {
      return const [
        BusStopModel(
          name: 'Unicentro',
          position: LatLng(5.5487, -73.3529),
          isMain: true,
        ),
        BusStopModel(
          name: 'Avenida Norte',
          position: LatLng(5.5457, -73.3552),
        ),
        BusStopModel(
          name: 'Hospital',
          position: LatLng(5.5398, -73.3621),
          isMain: true,
        ),
      ];
    }

    return const [
      BusStopModel(
        name: 'Plaza de Bolívar',
        position: tunjaCenter,
        isMain: true,
      ),
    ];
  }

  Future<LatLng?> getBusPositionFor(RouteModel? route) async {
    final name = _normalizeRouteName(route);

    if (name.contains('r2')) {
      return const LatLng(5.54000, -73.35500);
    }

    if (name.contains('r5')) {
      return const LatLng(5.53060, -73.36250);
    }

    if (name.contains('r8')) {
      return const LatLng(5.5457, -73.3552);
    }

    return const LatLng(5.5350, -73.3650);
  }

  Future<MapSummaryModel?> getMapSummaryFor(RouteModel? route) async {
    if (route != null) {
      return MapSummaryModel(
        routeName: route.name,
        stopName: route.stop,
        etaText: route.eta,
      );
    }

    return MapSummaryModel(
      routeName: 'Ruta A',
      stopName: 'Plaza de Bolívar',
      etaText: '5 min',
    );
  }

  Future<List<DestinationSuggestionModel>> getDestinationSuggestions() async {
    return const [
      DestinationSuggestionModel(text: 'Terminal de Transportes'),
      DestinationSuggestionModel(text: 'Universidad UPTC'),
      DestinationSuggestionModel(text: 'Hospital Regional'),
      DestinationSuggestionModel(text: 'Unicentro'),
    ];
  }
}
