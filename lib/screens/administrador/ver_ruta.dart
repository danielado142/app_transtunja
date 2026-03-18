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
    puntos = parsearCoordenadas(widget.coordenadas);
  }

  List<LatLng> parsearCoordenadas(String raw) {
    final texto = raw.trim();

    if (texto.isEmpty || texto.toLowerCase() == 'null' || texto == '[]') {
      return [];
    }

    try {
      final decoded = jsonDecode(texto);
      if (decoded is List) {
        return decoded
            .whereType<List>()
            .where((e) => e.length >= 2)
            .map(
              (e) => LatLng(
                double.parse(e[0].toString()),
                double.parse(e[1].toString()),
              ),
            )
            .toList();
      }
    } catch (_) {}

    final regexLatLng = RegExp(
      r'LatLng\(latitude:\s*(-?\d+(?:\.\d+)?),\s*longitude:\s*(-?\d+(?:\.\d+)?)\)',
    );
    final matchesLatLng = regexLatLng.allMatches(texto);

    if (matchesLatLng.isNotEmpty) {
      return matchesLatLng
          .map(
            (m) => LatLng(double.parse(m.group(1)!), double.parse(m.group(2)!)),
          )
          .toList();
    }

    final regexPar = RegExp(
      r'\[\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*\]',
    );
    final matchesPar = regexPar.allMatches(texto);

    return matchesPar
        .map(
          (m) => LatLng(double.parse(m.group(1)!), double.parse(m.group(2)!)),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final centro = puntos.isNotEmpty
        ? puntos.first
        : const LatLng(5.5353, -73.3678);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'VER RUTA',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: puntos.isEmpty
          ? const Center(child: Text('Esta ruta no tiene coordenadas válidas'))
          : FlutterMap(
              options: MapOptions(initialCenter: centro, initialZoom: 14),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: puntos,
                      strokeWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: puntos
                      .map(
                        (p) => Marker(
                          point: p,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
    );
  }
}
