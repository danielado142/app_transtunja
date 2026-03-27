import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// ✅ Asegúrate de que esta ruta apunte correctamente a tu servicio de rutas
import '../../services/routing_service.dart'; 

class RutaActualScreen extends StatefulWidget {
  const RutaActualScreen({super.key});

  @override
  State<RutaActualScreen> createState() => _RutaActualScreenState();
}

class _RutaActualScreenState extends State<RutaActualScreen> {
  final Color rojoPrincipal = const Color(0xFFD10000);
  final Color azulRuta = const Color(0xFF2196F3); 
  final MapController _mapController = MapController();
  final RoutingService _routingService = RoutingService();
  
  int rutaSeleccionada = 18;
  bool _cargandoRuta = true;
  List<LatLng> _puntosDibujados = [];

  // 📍 R18: Terminal -> Parque Santander -> Plaza de Bolívar
  final List<LatLng> puntosR18 = [
    const LatLng(5.51820, -73.36150), // Inicio: Terminal
    const LatLng(5.53060, -73.36250), // Paso: Parque Santander
    const LatLng(5.53280, -73.36160), // Fin: Plaza de Bolívar
  ];

  // 📍 R15: Plaza de Bolívar -> Av. Norte -> Los Muiscas
  final List<LatLng> puntosR15 = [
    const LatLng(5.53320, -73.36150), // Inicio: Centro
    const LatLng(5.54500, -73.35500), // Paso: Av. Norte
    const LatLng(5.55850, -73.34450), // Fin: Los Muiscas
  ];

  @override
  void initState() {
    super.initState();
    _trazarRuta(18); // Carga la R18 por defecto al abrir
  }

  Future<void> _trazarRuta(int numeroRuta) async {
    setState(() { 
      _cargandoRuta = true; 
      rutaSeleccionada = numeroRuta; 
    });

    List<LatLng> puntosBase = numeroRuta == 18 ? puntosR18 : puntosR15;
    
    try {
      final rutaCurva = await _routingService.buildRoadPolyline(puntosBase);
      setState(() { 
        _puntosDibujados = rutaCurva; 
        _cargandoRuta = false; 
      });

      if (_puntosDibujados.isNotEmpty) {
        // Zoom 15.2 para que se vea el trayecto claro y el Parque Santander
        _mapController.move(_puntosDibujados.first, 15.2); 
      }
    } catch (e) {
      setState(() { 
        _puntosDibujados = puntosBase; 
        _cargandoRuta = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🚏 BOTONES DE SELECCIÓN
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Expanded(child: _botonRuta("R18: Term - Centro", rutaSeleccionada == 18, 18)),
              const SizedBox(width: 8),
              Expanded(child: _botonRuta("R15: Centro - Muiscas", rutaSeleccionada == 15, 15)),
            ],
          ),
        ),

        // 🗺️ MAPA PANTALLA COMPLETA
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(5.5332, -73.3615),
                  initialZoom: 15.2,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.transtunja.app',
                  ),
                  // Línea de la ruta en Azul
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _puntosDibujados, 
                        color: azulRuta, 
                        strokeWidth: 6,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      if (_puntosDibujados.isNotEmpty) ...[
                        // PIN DE INICIO
                        Marker(
                          point: _puntosDibujados.first,
                          width: 80, height: 80,
                          child: _etiquetaMarcador("INICIO", Colors.green, Icons.location_on),
                        ),
                        // PIN DE FIN
                        Marker(
                          point: _puntosDibujados.last,
                          width: 80, height: 80,
                          child: _etiquetaMarcador("FIN", rojoPrincipal, Icons.flag_circle),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
              // Indicador de carga
              if (_cargandoRuta) 
                const Center(child: CircularProgressIndicator(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  // Widget para las etiquetas de Inicio/Fin
  Widget _etiquetaMarcador(String texto, Color color, IconData icono) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            texto,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        Icon(icono, color: color, size: 35),
      ],
    );
  }

  // Widget para los botones de arriba
  Widget _botonRuta(String texto, bool seleccionado, int id) {
    return GestureDetector(
      onTap: () => _trazarRuta(id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? rojoPrincipal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: seleccionado ? rojoPrincipal : Colors.black12),
        ),
        child: Center(
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: seleccionado ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}