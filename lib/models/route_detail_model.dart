import 'route_stop_model.dart';

class RouteDetailModel {
  final String routeName;
  final String stopName;
  final String etaText;
  final String origin;
  final String destination;
  final List<RouteStopModel> stops;

  const RouteDetailModel({
    required this.routeName,
    required this.stopName,
    required this.etaText,
    required this.origin,
    required this.destination,
    required this.stops,
  });

  factory RouteDetailModel.fromBasicData({
    required String routeName,
    required String stopName,
    required String etaText,
  }) {
    final routeParts = routeName.split(' - ');
    final origin = routeParts.isNotEmpty ? routeParts.first : routeName;
    final destination = routeParts.length > 1 ? routeParts.last : '';

    return RouteDetailModel(
      routeName: routeName,
      stopName: stopName,
      etaText: etaText,
      origin: origin,
      destination: destination,
      stops: [
        const RouteStopModel(
          name: 'Centro',
          info: 'Punto de inicio',
          state: RouteStopState.start,
        ),
        RouteStopModel(
          name: stopName,
          info: 'Parada cercana',
          state: RouteStopState.current,
        ),
        const RouteStopModel(
          name: 'Parque Santander',
          info: 'Intermedia',
          state: RouteStopState.middle,
        ),
        const RouteStopModel(
          name: 'UPTC',
          info: 'Destino final',
          state: RouteStopState.end,
        ),
      ],
    );
  }
}
