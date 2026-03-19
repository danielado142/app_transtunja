import 'package:latlong2/latlong.dart';

import '../models/bus_stop_model.dart';
import '../models/destination_suggestion_model.dart';
import '../models/map_route_model.dart';
import '../models/map_summary_model.dart';
import '../repositories/map_repository.dart';

class MapService {
  static const LatLng tunjaCenter = MapRepository.tunjaCenter;

  final MapRepository _repository = MapRepository();

  Future<LatLng> getMapCenter() {
    return _repository.getMapCenter();
  }

  Future<MapRouteModel> getDemoRoute() {
    return _repository.getDemoRoute();
  }

  Future<List<BusStopModel>> getBusStops() {
    return _repository.getBusStops();
  }

  Future<LatLng> getBusPosition() {
    return _repository.getBusPosition();
  }

  Future<MapSummaryModel> getMapSummary() {
    return _repository.getMapSummary();
  }

  Future<List<DestinationSuggestionModel>> getDestinationSuggestions() {
    return _repository.getDestinationSuggestions();
  }
}
