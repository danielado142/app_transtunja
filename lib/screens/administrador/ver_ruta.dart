import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class VerRuta extends StatefulWidget {
  final String coordenadas;

  const VerRuta({super.key, required this.coordenadas});

  @override
  State<VerRuta> createState() => _VerRutaState();
}

class _VerRutaState extends State<VerRuta> {
  List<LatLng> puntos = [];

  @override
  void initState() {
    super.initState();
    cargarRuta();
  }

  void cargarRuta() {
    try {
      if (widget.coordenadas.isEmpty) return;

      List datos = jsonDecode(widget.coordenadas);

      puntos = datos.map<LatLng>((p) {
        return LatLng(p[0], p[1]);
      }).toList();
    } catch (e) {
      print("Error leyendo coordenadas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng centroMapa = puntos.isNotEmpty
        ? puntos.first
        : const LatLng(5.5353, -73.3678);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "VER RUTA",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: FlutterMap(
        options: MapOptions(initialCenter: centroMapa, initialZoom: 14),

        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.example.app",
          ),

          // Línea de la ruta
          PolylineLayer(
            polylines: [
              Polyline(points: puntos, strokeWidth: 5, color: Colors.blue),
            ],
          ),

          // Marcadores
          MarkerLayer(
            markers: puntos.map((p) {
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
        ],
      ),
    );
  }
}
