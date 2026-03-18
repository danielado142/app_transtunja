import 'package:latlong2/latlong.dart';

class MapRouteModel {
  final String name;
  final List<LatLng> points;

  const MapRouteModel({required this.name, required this.points});

  MapRouteModel copyWith({String? name, List<LatLng>? points}) {
    return MapRouteModel(
      name: name ?? this.name,
      points: points ?? this.points,
    );
  }

  factory MapRouteModel.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] as List<dynamic>? ?? [];

    return MapRouteModel(
      name: json['name'] ?? '',
      points: rawPoints
          .map(
            (point) => LatLng(
              (point['lat'] ?? 0).toDouble(),
              (point['lng'] ?? 0).toDouble(),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'points': points
          .map((point) => {'lat': point.latitude, 'lng': point.longitude})
          .toList(),
    };
  }
}
