import 'package:latlong2/latlong.dart';

import '../models/bus_stop_model.dart';
import '../models/destination_suggestion_model.dart';
import '../models/map_route_model.dart';
import '../models/map_summary_model.dart';
import '../models/route_model.dart';

class MapService {
  static const LatLng tunjaCenter = LatLng(5.5333, -73.3667);

  Future<LatLng> getMapCenter() async {
    return tunjaCenter;
  }

  String _normalizeRouteName(RouteModel? route) {
    if (route == null) return '';
    return route.name.toLowerCase().trim();
  }

  Future<MapRouteModel?> getRouteFor(RouteModel? route) async {
    final name = _normalizeRouteName(route);

    if (name.contains('r2') || name.contains('centro - uptc')) {
      return const MapRouteModel(
        points: [
          LatLng(5.5354, -73.3676),
          LatLng(5.5367, -73.3645),
          LatLng(5.5392, -73.3607),
          LatLng(5.5430, -73.3568),
        ],
      );
    }

    if (name.contains('r5') || name.contains('terminal - centro')) {
      return const MapRouteModel(
        points: [
          LatLng(5.5478, -73.3589),
          LatLng(5.5441, -73.3608),
          LatLng(5.5394, -73.3642),
          LatLng(5.5358, -73.3671),
        ],
      );
    }

    if (name.contains('r8') || name.contains('unicentro - hospital')) {
      return const MapRouteModel(
        points: [
          LatLng(5.5487, -73.3529),
          LatLng(5.5457, -73.3552),
          LatLng(5.5425, -73.3586),
          LatLng(5.5398, -73.3621),
        ],
      );
    }

    return const MapRouteModel(
      points: [
        LatLng(5.5333, -73.3667),
        LatLng(5.5400, -73.3600),
      ],
    );
  }

  Future<List<BusStopModel>> getBusStopsFor(RouteModel? route) async {
    final name = _normalizeRouteName(route);

    if (name.contains('r2') || name.contains('centro - uptc')) {
      return const [
        BusStopModel(
          name: 'Centro',
          position: LatLng(5.5354, -73.3676),
          isMain: true,
        ),
        BusStopModel(
          name: 'Plaza Real',
          position: LatLng(5.5367, -73.3645),
        ),
        BusStopModel(
          name: 'Parque Santander',
          position: LatLng(5.5392, -73.3607),
        ),
        BusStopModel(
          name: 'UPTC',
          position: LatLng(5.5430, -73.3568),
          isMain: true,
        ),
      ];
    }

    if (name.contains('r5') || name.contains('terminal - centro')) {
      return const [
        BusStopModel(
          name: 'Terminal',
          position: LatLng(5.5478, -73.3589),
          isMain: true,
        ),
        BusStopModel(
          name: 'Parque Santander',
          position: LatLng(5.5394, -73.3642),
        ),
        BusStopModel(
          name: 'Centro',
          position: LatLng(5.5358, -73.3671),
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

    if (name.contains('r2') || name.contains('centro - uptc')) {
      return const LatLng(5.5367, -73.3645);
    }

    if (name.contains('r5') || name.contains('terminal - centro')) {
      return const LatLng(5.5420, -73.3620);
    }

    if (name.contains('r8') || name.contains('unicentro - hospital')) {
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
