import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaAdmin extends StatefulWidget {
  static List<LatLng> puntos = [];

  const MapaAdmin({super.key});

  @override
  State<MapaAdmin> createState() => _MapaAdminState();
}

class _MapaAdminState extends State<MapaAdmin> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(5.5353, -73.3678),
        initialZoom: 14,

        onTap: (tapPosition, point) {
          setState(() {
            MapaAdmin.puntos.add(point);
          });
        },
      ),

      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: "com.example.app",
        ),

        MarkerLayer(
          markers: MapaAdmin.puntos.map((p) {
            return Marker(
              point: p,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            );
          }).toList(),
        ),

        PolylineLayer(
          polylines: [
            Polyline(
              points: MapaAdmin.puntos,
              strokeWidth: 4,
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }
}
