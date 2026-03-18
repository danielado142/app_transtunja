import 'package:latlong2/latlong.dart';

import '../models/bus_stop_model.dart';
import '../models/destination_suggestion_model.dart';
import '../models/map_route_model.dart';
import '../models/map_summary_model.dart';

class MapService {
  static const LatLng tunjaCenter = LatLng(5.5353, -73.3678);

  Future<LatLng> getMapCenter() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return tunjaCenter;
  }

  Future<MapRouteModel> getDemoRoute() async {
    await Future.delayed(const Duration(milliseconds: 200));

    return const MapRouteModel(
      name: 'Centro - UPTC',
      points: [
        LatLng(5.5353, -73.3678),
        LatLng(5.5364, -73.3666),
        LatLng(5.5376, -73.3654),
        LatLng(5.5388, -73.3642),
        LatLng(5.5398, -73.3633),
      ],
    );
  }

  Future<List<BusStopModel>> getBusStops() async {
    await Future.delayed(const Duration(milliseconds: 200));

    return const [
      BusStopModel(
        name: 'Plaza Real',
        position: LatLng(5.5353, -73.3678),
        isMain: true,
      ),
      BusStopModel(
        name: 'Parque Santander',
        position: LatLng(5.5376, -73.3654),
      ),
      BusStopModel(name: 'UPTC', position: LatLng(5.5398, -73.3633)),
    ];
  }

  Future<LatLng> getBusPosition() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const LatLng(5.5388, -73.3642);
  }

  Future<MapSummaryModel> getMapSummary() async {
    await Future.delayed(const Duration(milliseconds: 180));

    return const MapSummaryModel(
      stopName: 'Plaza Real',
      etaText: '4 min',
      routeName: 'Centro - UPTC',
    );
  }

  Future<List<DestinationSuggestionModel>> getDestinationSuggestions() async {
    await Future.delayed(const Duration(milliseconds: 180));

    return const [
      DestinationSuggestionModel(
        text: 'UPTC (Universidad Pedagógica y Tecnológica)',
      ),
      DestinationSuggestionModel(text: 'Terminal de Transportes de Tunja'),
      DestinationSuggestionModel(text: 'Centro Comercial Unicentro'),
    ];
  }
}
