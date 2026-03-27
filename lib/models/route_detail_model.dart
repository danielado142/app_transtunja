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
      origin: "Terminal", 
      destination: "UPTC", 
      stopName: stopName,
      etaText: etaText,
      
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
