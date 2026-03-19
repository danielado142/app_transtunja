import 'package:latlong2/latlong.dart';
import '../models/bus_stop_model.dart';
import '../models/map_route_model.dart';
import '../models/map_summary_model.dart';
import '../models/destination_suggestion_model.dart';

class MapService {
  // Centro de Tunja, Boyacá
  static const LatLng tunjaCenter = LatLng(5.5333, -73.3667);

  Future<LatLng> getMapCenter() async => tunjaCenter;

  Future<MapRouteModel?> getDemoRoute() async {
    return MapRouteModel(
      points: [LatLng(5.5333, -73.3667), LatLng(5.5400, -73.3600)],
    );
  }

  Future<List<BusStopModel>> getBusStops() async {
    return [
      BusStopModel(
        name: "Plaza de Bolívar",
        position: tunjaCenter,
        isMain: true,
      ),
      BusStopModel(name: "Unicentro", position: LatLng(5.545, -73.355)),
    ];
  }

  Future<LatLng?> getBusPosition() async => LatLng(5.535, -73.365);

  Future<MapSummaryModel?> getMapSummary() async {
    return MapSummaryModel(
      routeName: "Ruta A",
      stopName: "Plaza de Bolívar",
      etaText: "5 min",
    );
  }

  Future<List<DestinationSuggestionModel>> getDestinationSuggestions() async {
    return [
      DestinationSuggestionModel(text: "Terminal de Transportes"),
      DestinationSuggestionModel(text: "Universidad UPTC"),
    ];
  }
}
