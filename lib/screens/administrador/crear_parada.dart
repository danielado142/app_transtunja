import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:app_transtunja/config/constants.dart';

class CrearParadaPage extends StatefulWidget {
  const CrearParadaPage({super.key});

  @override
  State<CrearParadaPage> createState() => _CrearParadaPageState();
}

class _CrearParadaPageState extends State<CrearParadaPage> {
  static const Color rojoPrincipal = Color(0xFFD10000);
  static const Color grisFondo = Color(0xFFF5F5F5);
  static const LatLng tunjaCenter = LatLng(5.5353, -73.3678);

  final MapController _mapController = MapController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _idRutaCtrl = TextEditingController();

  String _diaSeleccionado = 'LUNES';
  final List<String> _diasSemana = [
    'LUNES',
    'MARTES',
    'MIÉRCOLES',
    'JUEVES',
    'VIERNES',
    'SÁBADO',
    'DOMINGO'
  ];

  LatLng? _selectedPoint;
  bool _isSaving = false;

  void _showSnack(String texto, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    setState(() => _selectedPoint = point);
    debugPrint("Punto seleccionado: ${point.latitude}, ${point.longitude}");
  }

  void _restablecer() {
    setState(() {
      _nombreCtrl.clear();
      _idRutaCtrl.clear();
      _diaSeleccionado = 'LUNES';
      _selectedPoint = null;
    });
  }

  Future<void> _procesoGuardado() async {
    // Validamos que los campos no estén vacíos
    if (_nombreCtrl.text.trim().isEmpty || _idRutaCtrl.text.trim().isEmpty) {
      _showSnack('Completa el nombre y el ID de la ruta (Ej: R4)',
          isError: true);
      return;
    }

    if (_selectedPoint == null) {
      _showSnack('Por favor, toca el mapa para ubicar la parada',
          isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/guardar_parada.php");

      // Enviamos el ID de ruta tal cual se escribe (Soportando la "R")
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({
              "nombre_parada": _nombreCtrl.text.trim(),
              "id_ruta": _idRutaCtrl.text
                  .trim()
                  .toUpperCase(), // Convertimos r4 a R4 automáticamente
              "dia_semana": _diaSeleccionado,
              "latitud": _selectedPoint!.latitude,
              "longitud": _selectedPoint!.longitude,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print("--- INICIO DE RESPUESTA DEL SERVIDOR ---");
      print("Código de estado: ${response.statusCode}");
      print("Cuerpo recibido: ${response.body}");
      print("--- FIN DE RESPUESTA DEL SERVIDOR ---");

      final res = jsonDecode(response.body);

      if (mounted) {
        if (res['status'] == 'success') {
          _showSnack('¡Parada guardada con éxito en MySQL!');
          _restablecer();
          Future.delayed(
              const Duration(seconds: 1), () => Navigator.pop(context));
        } else {
          // Si sale el error de Foreign Key, el PHP nos enviará el mensaje aquí
          _showSnack(res['message'] ?? 'Error en el servidor', isError: true);
        }
      }
    } catch (e) {
      _showSnack('Error de conexión o formato: $e', isError: true);
      debugPrint("Error crítico: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisFondo,
      appBar: AppBar(
        backgroundColor: rojoPrincipal,
        foregroundColor: Colors.white,
        title: const Text('GESTIÓN DE PARADAS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFormulario(),
          Expanded(child: _buildMapa()),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CREAR PARADA',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Complete los datos y toque el mapa para ubicar.',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          _buildLabel('Nombre de la parada'),
          TextField(
              controller: _nombreCtrl,
              decoration: _inputStyle(Icons.location_on)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('ID Ruta (Ej: R4)'),
                    TextField(
                        controller: _idRutaCtrl,
                        // ✅ CAMBIO REALIZADO: Ahora permite texto (letras y números)
                        keyboardType: TextInputType.text,
                        decoration: _inputStyle(Icons.alt_route)),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Día'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                          color: grisFondo,
                          borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _diaSeleccionado,
                          isExpanded: true,
                          items: _diasSemana
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _diaSeleccionado = val!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapa() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: tunjaCenter,
            initialZoom: 14,
            onTap: _handleMapTap,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.transtunja.app',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            if (_selectedPoint != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPoint!,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.location_on,
                        color: rojoPrincipal, size: 45),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFF8D6E63),
              fontSize: 13,
              fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _inputStyle(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.black87, size: 20),
      filled: true,
      fillColor: grisFondo,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: _restablecer,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFBDBDBD)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Limpiar',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving ? null : _procesoGuardado,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('GUARDAR PARADA',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
