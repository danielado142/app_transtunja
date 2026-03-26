import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// Importante: El archivo mapa_admin.dart debe estar en la misma carpeta
import 'mapa_admin.dart';

import 'package:app_transtunja/services/routing_service.dart';
import 'package:app_transtunja/services/ruta_service.dart';
import 'package:app_transtunja/config/constants.dart';

class EditarRuta extends StatefulWidget {
  const EditarRuta(
      {super.key, required this.routeId, this.apiBaseUrl = '/transtunja'});

  final String routeId;
  final String apiBaseUrl;

  @override
  State<EditarRuta> createState() => _EditarRutaState();
}

class _EditarRutaState extends State<EditarRuta> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _destinoCtrl = TextEditingController();
  late final RutaService _rutaService;
  late final RoutingService _routingService;

  bool _isLoading = true;
  bool _isSaving = false;

  // Estas son las listas maestras que se guardarán
  List<LatLng> _waypoints = [];
  List<LatLng> _polylinePoints = [];

  @override
  void initState() {
    super.initState();
    _rutaService = RutaService(baseUrl: widget.apiBaseUrl);
    _routingService = RoutingService();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    try {
      final route = await _rutaService.fetchRouteById(widget.routeId);
      if (mounted) {
        setState(() {
          _nombreCtrl.text = route.nombre;
          _destinoCtrl.text = route.destino;
          _waypoints = List<LatLng>.from(route.waypoints);
          _polylinePoints = List<LatLng>.from(route.polylinePoints);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Error al cargar datos de la ruta', isError: true);
      }
    }
  }

  Future<void> _guardarRuta() async {
    // Validación de seguridad
    if (_waypoints.isEmpty) {
      _showSnack('Debes marcar puntos en el mapa antes de guardar',
          isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Convertimos los puntos a formato de lista para el JSON [lat, lng]
      final List<List<double>> formatoWaypoints =
          _waypoints.map((p) => [p.latitude, p.longitude]).toList();

      // 2. Si no hay polilínea calculada, usamos los mismos waypoints para que no vaya vacío
      final List<List<double>> formatoPolilinea =
          (_polylinePoints.isNotEmpty ? _polylinePoints : _waypoints)
              .map((p) => [p.latitude, p.longitude])
              .toList();

      // DEBUG: Mira esto en tu consola de VS Code para confirmar que hay datos
      print("--- INICIANDO GUARDADO ---");
      print("ID RUTA: ${widget.routeId}");
      print("PUNTOS A ENVIAR: ${formatoWaypoints.length}");

      final url = Uri.parse('${ApiConfig.baseUrl}/guardar_ruta.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_ruta': widget.routeId,
          'nombre': _nombreCtrl.text,
          'destino': _destinoCtrl.text,
          'coordenadas': formatoPolilinea,
          'waypoitns': formatoWaypoints, // Coincide con tu columna en XAMPP
        }),
      );

      print("Respuesta XAMPP: ${response.body}");

      if (mounted) {
        final res = jsonDecode(response.body);
        if (response.statusCode == 200 && res['status'] == 'success') {
          _showSnack('¡Ruta guardada exitosamente!');
          // Regresamos a la pantalla anterior avisando que hubo cambios
          Navigator.pop(context, true);
        } else {
          _showSnack('Error del servidor: ${res['message']}', isError: true);
        }
      }
    } catch (e) {
      print("ERROR DE RED: $e");
      _showSnack('Error de conexión con el servidor', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Ruta'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Formulario de texto
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nombreCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de la Ruta',
                              prefixIcon: Icon(Icons.edit_road),
                            ),
                          ),
                          TextField(
                            controller: _destinoCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Destino',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // El Mapa (Usa tu MapaAdmin)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: MapaAdmin(
                          puntosIniciales: _waypoints,
                          onPuntosChanged: (puntosNuevos) {
                            // AQUÍ SE SINCRONIZAN LOS DATOS
                            setState(() {
                              _waypoints = puntosNuevos;
                              _polylinePoints =
                                  puntosNuevos; // Sincroniza visual
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Botón de Guardar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _guardarRuta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: Text(
                        _isSaving ? 'Guardando...' : 'Guardar en Base de Datos',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
