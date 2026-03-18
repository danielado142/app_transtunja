import 'package:latlong2/latlong.dart';

class BusStopModel {
  final String name;
  final LatLng position;
  final bool isMain;

  const BusStopModel({
    required this.name,
    required this.position,
    this.isMain = false,
  });

  BusStopModel copyWith({String? name, LatLng? position, bool? isMain}) {
    return BusStopModel(
      name: name ?? this.name,
      position: position ?? this.position,
      isMain: isMain ?? this.isMain,
    );
  }

  factory BusStopModel.fromJson(Map<String, dynamic> json) {
    return BusStopModel(
      name: json['name'] ?? '',
      position: LatLng(
        (json['lat'] ?? 0).toDouble(),
        (json['lng'] ?? 0).toDouble(),
      ),
      isMain: json['isMain'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': position.latitude,
      'lng': position.longitude,
      'isMain': isMain,
    };
  }
}
