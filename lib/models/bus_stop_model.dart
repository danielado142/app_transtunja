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
}
