import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaAdmin extends StatefulWidget {
  const MapaAdmin({super.key});

  // ESTA lista sí se puede leer desde CrearRuta como MapaAdmin.puntos
  static List<LatLng> puntos = [];

  static void limpiarPuntos() {
    puntos.clear();
  }

  @override
  State<MapaAdmin> createState() => _MapaAdminState();
}

class _MapaAdminState extends State<MapaAdmin> {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(5.5353, -73.3678),
        initialZoom: 14,
        onTap: (tapPosition, point) {
          setState(() {
            MapaAdmin.puntos.add(point);
          });
        },
        onLongPress: (tapPosition, point) {
          if (MapaAdmin.puntos.isNotEmpty) {
            setState(() {
              MapaAdmin.puntos.removeLast();
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: MapaAdmin.puntos,
              strokeWidth: 4,
              color: Colors.red,
            ),
          ],
        ),
        MarkerLayer(
          markers: MapaAdmin.puntos.map((punto) {
            return Marker(
              point: punto,
              width: 40,
              height: 40,
              child: const Icon(Icons.location_on, color: Colors.red, size: 35),
            );
          }).toList(),
        ),
      ],
    );
  }
}
