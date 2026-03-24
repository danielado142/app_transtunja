import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaAdmin extends StatefulWidget {
  final List<LatLng> puntosIniciales;
  final Function(List<LatLng>) onPuntosChanged;

  const MapaAdmin({
    super.key,
    required this.puntosIniciales,
    required this.onPuntosChanged,
  });

  @override
  State<MapaAdmin> createState() => _MapaAdminState();
}

class _MapaAdminState extends State<MapaAdmin> {
  late List<LatLng> _puntos;

  @override
  void initState() {
    super.initState();
    _puntos = List<LatLng>.from(widget.puntosIniciales);
  }

  // Si los puntos cambian externamente (al cargar la ruta)
  @override
  void didUpdateWidget(MapaAdmin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.puntosIniciales != widget.puntosIniciales) {
      _puntos = List<LatLng>.from(widget.puntosIniciales);
    }
  }

  void _actualizarPadre() {
    widget.onPuntosChanged(_puntos);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter:
            _puntos.isNotEmpty ? _puntos.first : const LatLng(5.5353, -73.3678),
        initialZoom: 14,
        onTap: (tapPosition, point) {
          setState(() {
            _puntos.add(point);
          });
          _actualizarPadre();
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.transtunja.admin',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: _puntos,
              strokeWidth: 4,
              color: Colors.red,
            ),
          ],
        ),
        MarkerLayer(
          markers: _puntos.asMap().entries.map((entry) {
            int idx = entry.key;
            LatLng punto = entry.value;
            return Marker(
              point: punto,
              width: 40,
              height: 40,
              child: GestureDetector(
                onLongPress: () {
                  setState(() => _puntos.removeAt(idx));
                  _actualizarPadre();
                },
                child:
                    const Icon(Icons.location_on, color: Colors.red, size: 35),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
