import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

import 'package:app_transtunja/services/routing_service.dart';

class VerRuta extends StatefulWidget {
  final String coordenadas;

  const VerRuta({super.key, required this.coordenadas});

  @override
  State<VerRuta> createState() => _VerRutaState();
}

class _VerRutaState extends State<VerRuta> {
  final MapController _mapController = MapController();
  late final RoutingService _routingService;

  List<LatLng> puntosControl = [];
  List<LatLng> rutaReal = [];
  bool cargando = true;

  static const LatLng _tunjaCenter = LatLng(5.5353, -73.3678);

  @override
  void initState() {
    super.initState();
    _routingService = RoutingService();
    puntosControl = _parsearCoordenadas(widget.coordenadas);
    _cargarRuta();
  }

  List<LatLng> _parsearCoordenadas(String raw) {
    final texto = raw.trim();

    if (texto.isEmpty || texto.toLowerCase() == 'null' || texto == '[]') {
      return [];
    }

    try {
      final decoded = jsonDecode(texto);

      if (decoded is List) {
        return decoded
            .map<LatLng?>((item) {
              if (item is Map<String, dynamic>) {
                final lat = item['lat'] ?? item['latitude'] ?? item['latitud'];
                final lng =
                    item['lng'] ??
                    item['longitude'] ??
                    item['longitud'] ??
                    item['lon'];

                if (lat == null || lng == null) return null;

                return LatLng(
                  double.parse(lat.toString()),
                  double.parse(lng.toString()),
                );
              }

              if (item is List && item.length >= 2) {
                return LatLng(
                  double.parse(item[0].toString()),
                  double.parse(item[1].toString()),
                );
              }

              return null;
            })
            .whereType<LatLng>()
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

  Future<void> _cargarRuta() async {
    if (puntosControl.length < 2) {
      setState(() {
        rutaReal = List<LatLng>.from(puntosControl);
        cargando = false;
      });
      return;
    }

    try {
      final trazado = await _routingService.buildRoadPolyline(puntosControl);

      if (!mounted) return;

      setState(() {
        rutaReal = trazado.isNotEmpty
            ? trazado
            : List<LatLng>.from(puntosControl);
        cargando = false;
      });

      if (puntosControl.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(puntosControl.first, 14.5);
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        rutaReal = List<LatLng>.from(puntosControl);
        cargando = false;
      });
    }
  }

  Widget _markerWidget(int index) {
    final isFirst = index == 0;
    final isLast = index == puntosControl.length - 1;

    IconData icon = Icons.location_on;
    Color color = Colors.red;

    if (isFirst) {
      icon = Icons.play_circle_fill;
      color = Colors.green;
    } else if (isLast) {
      icon = Icons.flag_circle;
      color = Colors.blue;
    }

    return Icon(icon, color: color, size: 36);
  }

  @override
  Widget build(BuildContext context) {
    final centro = puntosControl.isNotEmpty
        ? puntosControl.first
        : _tunjaCenter;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: const Text(
          'VER RUTA',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : puntosControl.isEmpty
          ? const Center(child: Text('Esta ruta no tiene coordenadas válidas'))
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: centro, initialZoom: 14.5),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.transtunja.admin',
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                if (rutaReal.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: rutaReal,
                        strokeWidth: 5,
                        color: Colors.red,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: List.generate(puntosControl.length, (index) {
                    return Marker(
                      point: puntosControl[index],
                      width: 40,
                      height: 40,
                      child: _markerWidget(index),
                    );
                  }),
                ),
              ],
            ),
    );
  }
}
