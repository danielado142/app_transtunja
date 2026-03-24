import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RutaActualScreen extends StatefulWidget {
  const RutaActualScreen({super.key});

  @override
  State<RutaActualScreen> createState() => _RutaActualScreenState();
}

class _RutaActualScreenState extends State<RutaActualScreen> {

  int rutaSeleccionada = 18;

  // 🔴 R18
  final List<LatLng> rutaR18 = [
    LatLng(5.5447, -73.3570),
    LatLng(5.5480, -73.3530),
    LatLng(5.5520, -73.3500),
    LatLng(5.5560, -73.3460),
  ];

  // 🔵 R15
  final List<LatLng> rutaR15 = [
    LatLng(5.5447, -73.3570),
    LatLng(5.5400, -73.3600),
    LatLng(5.5370, -73.3650),
    LatLng(5.5330, -73.3700),
  ];

  @override
  Widget build(BuildContext context) {

    List<LatLng> rutaActual =
        rutaSeleccionada == 18 ? rutaR18 : rutaR15;

    return Column(
      children: [

        // 👋 SALUDO
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
          child: Row(
            children: const [

              CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.directions_bus, color: Colors.white),
              ),

              SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hola Conductor",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Selecciona tu ruta",
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              )
            ],
          ),
        ),

        // 🚏 BOTONES DE RUTA
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      rutaSeleccionada = 18;
                    });
                  },
                  child: _botonRuta("R18", rutaSeleccionada == 18),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      rutaSeleccionada = 15;
                    });
                  },
                  child: _botonRuta("R15", rutaSeleccionada == 15),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // 🗺️ MAPA
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),

              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(5.5447, -73.3570),
                  initialZoom: 14.5,
                ),

                children: [

                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  ),

                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: rutaActual,
                        color: Colors.red,
                        strokeWidth: 6,
                      ),
                    ],
                  ),

                  MarkerLayer(
                    markers: rutaActual.map((punto) {
                      return Marker(
                        point: punto,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 35,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  // 🔥 BOTÓN BONITO
  Widget _botonRuta(String texto, bool seleccionado) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(vertical: 8), // 👈 más pequeño
    decoration: BoxDecoration(
      color: seleccionado ? Colors.red : Colors.white,
      borderRadius: BorderRadius.circular(18), // 👈 más fino
      border: Border.all(color: Colors.red, width: 1),
    ),
    child: Text(
      texto,
      style: TextStyle(
        color: seleccionado ? Colors.white : Colors.red,
        fontWeight: FontWeight.w600,
        fontSize: 14, // 👈 más pequeño
      ),
    ),
  );
}
}