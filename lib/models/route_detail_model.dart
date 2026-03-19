import 'route_stop_model.dart';

class RouteDetailModel {
  final String routeName;
  final String origin;
  final String destination;
  final String stopName;
  final String etaText;
  final List<RouteStopModel> stops;

  RouteDetailModel({
    required this.routeName,
    required this.origin,
    required this.destination,
    required this.stopName,
    required this.etaText,
    required this.stops,
  });

  // Este es el constructor que pide tu pantalla
  factory RouteDetailModel.fromBasicData({
    required String routeName,
    required String stopName,
    required String etaText,
  }) {
    return RouteDetailModel(
      routeName: routeName,
      origin: "Terminal", // Datos de ejemplo
      destination: "UPTC", // Datos de ejemplo
      stopName: stopName,
      etaText: etaText,
      // Generamos una lista de paradas de ejemplo para que no se vea vacío
      stops: [
        RouteStopModel(
          name: "Terminal",
          info: "Punto de salida",
          state: RouteStopState.start,
        ),
        RouteStopModel(
          name: stopName,
          info: "Tu ubicación",
          state: RouteStopState.current,
        ),
        RouteStopModel(
          name: "Campus Universitario",
          info: "Destino final",
          state: RouteStopState.end,
        ),
      ],
    );
  }
}
