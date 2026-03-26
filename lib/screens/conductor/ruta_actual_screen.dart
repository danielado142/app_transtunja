import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RutaActualScreen extends StatefulWidget {
  const RutaActualScreen({super.key});

  @override
  State<RutaActualScreen> createState() => _RutaActualScreenState();
}

class _RutaActualScreenState extends State<RutaActualScreen> {
  // 🎨 PALETA DE COLORES OFICIAL
  final Color rojoPrincipal = const Color(0xFFD10000);
  final Color fondoGris = const Color(0xFFF6F6F7);

  int rutaSeleccionada = 18;

  // 🔴 R18 (Coordenadas Tunja)
  final List<LatLng> rutaR18 = [
    LatLng(5.5447, -73.3570),
    LatLng(5.5480, -73.3530),
    LatLng(5.5520, -73.3500),
    LatLng(5.5560, -73.3460),
  ];

  // 🔵 R15 (Coordenadas Tunja)
  final List<LatLng> rutaR15 = [
    LatLng(5.5447, -73.3570),
    LatLng(5.5400, -73.3600),
    LatLng(5.5370, -73.3650),
    LatLng(5.5330, -73.3700),
  ];

  @override
  Widget build(BuildContext context) {
    List<LatLng> rutaActual = rutaSeleccionada == 18 ? rutaR18 : rutaR15;

    return Container(
      color: fondoGris, // ⚪ Fondo Gris claro #F6F6F7
      child: Column(
        children: [
          const SizedBox(height: 10),

          // 🚏 BOTONES DE RUTA (Diseño corregido)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => rutaSeleccionada = 18),
                    child: _botonRuta("Ruta R18", rutaSeleccionada == 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => rutaSeleccionada = 15),
                    child: _botonRuta("Ruta R15", rutaSeleccionada == 15),
                  ),
                ),
              ],
            ),
          ),

          // 🗺️ MAPA (Con bordes suaves y sombra)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FlutterMap(
                    options: const MapOptions(
                      initialCenter: LatLng(5.5447, -73.3570),
                      initialZoom: 14.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.transtunja.app', // ✅ Evita el bloqueo del mapa
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: rutaActual,
                            color: rojoPrincipal, // 🔴 Rojo #D10000
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
                            child: Icon(
                              Icons.location_on,
                              color: rojoPrincipal,
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
          ),
        ],
      ),
    );
  }

  // 🔥 BOTÓN SEGÚN TU GUÍA DE ESTILOS
  Widget _botonRuta(String texto, bool seleccionado) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: seleccionado ? rojoPrincipal : Colors.white,
        borderRadius: BorderRadius.circular(15), // Bordes suaves
        border: Border.all(
          color: seleccionado ? rojoPrincipal : Colors.black12, 
          width: 1.5
        ),
        boxShadow: seleccionado 
          ? [BoxShadow(color: rojoPrincipal.withOpacity(0.3), blurRadius: 8)]
          : null,
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: seleccionado ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w800, // 🟦 Peso w800 para etiquetas
          fontSize: 14,
        ),
      ),
    );
  }
}