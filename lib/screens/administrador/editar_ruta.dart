import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// Importante: Asegúrate de que las rutas de importación sean correctas para tu proyecto
import 'mapa_admin.dart';
import 'package:app_transtunja/services/routing_service.dart';
import 'package:app_transtunja/services/ruta_service.dart';
import 'package:app_transtunja/config/constants.dart';

class EditarRuta extends StatefulWidget {
  const EditarRuta({super.key, required this.routeId});

  final String routeId;

  @override
  State<EditarRuta> createState() => _EditarRutaState();
}

class _EditarRutaState extends State<EditarRuta> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _destinoCtrl = TextEditingController();

  // Usamos el Service de forma directa
  final RutaService _rutaService = RutaService();
  final RoutingService _routingService = RoutingService();

  bool _isLoading = true;
  bool _isSaving = false;

  List<LatLng> _waypoints = [];
  List<LatLng> _polylinePoints = [];

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    try {
      // Llamamos a la función para obtener los datos de la ruta específica
      final response = await http.get(Uri.parse(
          '${ApiConfig.baseUrl}/obtener_ruta_detalle.php?id_ruta=${widget.routeId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            _nombreCtrl.text = data['nombre'] ?? '';
            _destinoCtrl.text = data['destino'] ?? '';

            // Decodificar Coordenadas (Polilínea)
            if (data['coordenadas'] != null) {
              var coords = jsonDecode(data['coordenadas']) as List;
              _polylinePoints = coords.map((e) => LatLng(e[0], e[1])).toList();
            }

            // Decodificar Waypoints
            if (data['waypoitns'] != null) {
              var ways = jsonDecode(data['waypoitns']) as List;
              _waypoints = ways.map((e) => LatLng(e[0], e[1])).toList();
            }

            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error cargando ruta: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Error al conectar con el servidor', isError: true);
      }
    }
  }

  Future<void> _guardarRuta() async {
    if (_waypoints.isEmpty) {
      _showSnack('Debes marcar puntos en el mapa antes de guardar',
          isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final List<List<double>> formatoWaypoints =
          _waypoints.map((p) => [p.latitude, p.longitude]).toList();

      final List<List<double>> formatoPolilinea =
          (_polylinePoints.isNotEmpty ? _polylinePoints : _waypoints)
              .map((p) => [p.latitude, p.longitude])
              .toList();

      final url = Uri.parse('${ApiConfig.baseUrl}/guardar_ruta.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_ruta': widget.routeId,
          'nombre': _nombreCtrl.text,
          'destino': _destinoCtrl.text,
          'coordenadas':
              jsonEncode(formatoPolilinea), // Enviar como String JSON
          'waypoitns': jsonEncode(formatoWaypoints), // Enviar como String JSON
        }),
      );

      if (mounted) {
        final res = jsonDecode(response.body);
        if (response.statusCode == 200 && res['status'] == 'success') {
          _showSnack('¡Ruta actualizada con éxito!');
          Navigator.pop(context, true);
        } else {
          _showSnack('Error: ${res['message']}', isError: true);
        }
      }
    } catch (e) {
      _showSnack('Error de conexión', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : Colors.green,
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nombreCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Nombre'),
                          ),
                          TextField(
                            controller: _destinoCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Destino'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: MapaAdmin(
                    puntosIniciales: _waypoints,
                    onPuntosChanged: (puntos) {
                      setState(() {
                        _waypoints = puntos;
                        _polylinePoints = puntos;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _guardarRuta,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      icon: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.save, color: Colors.white),
                      label: Text(
                          _isSaving ? 'Guardando...' : 'Actualizar Ruta',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
