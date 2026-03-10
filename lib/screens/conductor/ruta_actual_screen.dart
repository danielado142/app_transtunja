import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RutaActualScreen extends StatelessWidget {
  const RutaActualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        /// SALUDO (pequeño)
        const Padding(
          padding: EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Hola conductor 👋",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        /// RUTAS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [

              _rutaButton("R18", true),
              const SizedBox(width: 10),
              _rutaButton("R5", false),

            ],
          ),
        ),

        const SizedBox(height: 10),

        /// MAPA (PROTAGONISTA)
        Expanded(
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(5.5447, -73.3570),
              initialZoom: 14,
            ),
            children: [

              TileLayer(
                urlTemplate:
                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.app',
              ),

              PolylineLayer(
                polylines: [
                  Polyline(
                    points: const [
                      LatLng(5.5447, -73.3570),
                      LatLng(5.5500, -73.3500),
                      LatLng(5.5550, -73.3450),
                    ],
                    color: Colors.blue,
                    strokeWidth: 5,
                  ),
                ],
              ),

            ],
          ),
        ),
      ],
    );
  }

  static Widget _rutaButton(String texto, bool activo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: activo ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: activo ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}