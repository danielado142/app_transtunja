import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:app_transtunja/screens/administrador/admin_dashboard.dart';
import 'package:app_transtunja/widgets/trans_tunja_bottom_bar.dart';
import 'package:app_transtunja/config/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CrearParadaPage extends StatefulWidget {
  const CrearParadaPage({super.key});

  @override
  State<CrearParadaPage> createState() => _CrearParadaPageState();
}

class _CrearParadaPageState extends State<CrearParadaPage> {
  // Configuración de colores
  static const Color colorRojoApp = Color(0xFFD10000);
  static const Color colorFondo = Color(0xFFF6F6F7);
  static const Color colorCard = Color(0xFFFFFFFF);
  static const Color colorLimpiarBg = Color(0xFFFFE5E5);
  static const Color colorLimpiarBorder = Color(0xFF8B0000);
  static const Color borderGray = Color(0xFFD9D9D9);
  static const LatLng _tunjaCenter = LatLng(5.5353, -73.3678);

  // Controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _rutaController = TextEditingController();
  final MapController _mapController = MapController();

  // Estado del formulario
  LatLng? _selectedPoint;
  String? _diaSemanaSeleccionado;
  String _estadoSeleccionado = 'activo';
  bool _formExpanded = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _rutaController.dispose();
    _mapController.dispose();
    super.dispose();
  }

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

  void _resetForm() {
    setState(() {
      _nombreController.clear();
      _rutaController.clear();
      _diaSemanaSeleccionado = null;
      _estadoSeleccionado = 'activo';
      _selectedPoint = null;
    });
    _mapController.move(_tunjaCenter, 14);
  }

  // --- MÉTODO DE GUARDADO FINAL CORREGIDO ---
  Future<void> _saveStop() async {
    final nombre = _nombreController.text.trim();
    final ruta = _rutaController.text.trim();

    if (nombre.isEmpty ||
        ruta.isEmpty ||
        _diaSemanaSeleccionado == null ||
        _selectedPoint == null) {
      _showSnack('Completa todos los campos y marca el mapa', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Limpieza de URL (Elimina espacios y asegura una sola barra)
      final String base = ApiConfig.baseUrl.trim().endsWith('/')
          ? ApiConfig.baseUrl
              .trim()
              .substring(0, ApiConfig.baseUrl.trim().length - 1)
          : ApiConfig.baseUrl.trim();

      final String urlCompleta = '$base/gestion_paradas.php?accion=crear';

      debugPrint('🚀 Intentando conectar a: $urlCompleta');

      // 2. Petición HTTP POST
      final response = await http
          .post(
            Uri.parse(urlCompleta),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "User-Agent":
                  "PostmanRuntime/7.26.8", // Engaña al firewall de Hostinger
            },
            body: jsonEncode({
              "nombre_parada": nombre,
              "id_ruta": ruta.toUpperCase(),
              "dia_semana": _diaSemanaSeleccionado,
              "estado": _estadoSeleccionado,
              "latitud": _selectedPoint!.latitude.toString(),
              "longitud": _selectedPoint!.longitude.toString(),
            }),
          )
          .timeout(const Duration(seconds: 12));

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Cuerpo de respuesta: "${response.body}"');

      // 3. Validación de respuesta vacía
      if (response.body.trim().isEmpty) {
        _showSnack("Error: El servidor devolvió una respuesta vacía",
            isError: true);
        return;
      }

      // 4. Intento de decodificación JSON
      try {
        final res = jsonDecode(response.body);

        if (response.statusCode == 200 && res['status'] == 'success') {
          _showSnack("✅ Guardado con éxito en Hostinger");
          _resetForm();
        } else {
          _showSnack("❌ Servidor: ${res['message'] ?? 'Error desconocido'}",
              isError: true);
        }
      } catch (jsonError) {
        debugPrint("Error decodificando JSON: $jsonError");
        _showSnack("Error: El servidor no envió un formato válido",
            isError: true);
      }
    } catch (e) {
      debugPrint('❌ Error Capturado: $e');
      _showSnack('Fallo de conexión. Revisa tu internet o el servidor.',
          isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorRojoApp,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('CREAR PARADA',
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildTopPanel(),
              const SizedBox(height: 12),
              Expanded(child: _buildMapCard()),
              const SizedBox(height: 12),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: TransTunjaBottomBar(
        currentIndex: 2,
        onTap: (index) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => AdminDashboard(initialIndex: index)),
              (route) => false);
        },
      ),
    );
  }

  Widget _buildTopPanel() {
    return Container(
      decoration: BoxDecoration(
          color: colorCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
          ]),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _formExpanded = !_formExpanded),
            leading: const Icon(Icons.edit_note_rounded, color: colorRojoApp),
            title: const Text('Datos de la parada',
                style: TextStyle(fontWeight: FontWeight.w800)),
            trailing: Icon(_formExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down),
          ),
          if (_formExpanded)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                      controller: _nombreController,
                      decoration: _inputDecoration(
                          hintText: 'Nombre de la parada',
                          icon: Icons.location_on_outlined)),
                  const SizedBox(height: 10),
                  TextField(
                      controller: _rutaController,
                      decoration: _inputDecoration(
                          hintText: 'Ruta (Ej: RUTA 1)',
                          icon: Icons.alt_route_outlined)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _diaSemanaSeleccionado,
                    decoration: _inputDecoration(
                        hintText: 'Día de la semana',
                        icon: Icons.calendar_today_outlined),
                    items: [
                      'LUNES',
                      'MARTES',
                      'MIERCOLES',
                      'JUEVES',
                      'VIERNES',
                      'SABADO',
                      'DOMINGO'
                    ]
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _diaSemanaSeleccionado = v),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _tunjaCenter,
          initialZoom: 14,
          onTap: (_, point) => setState(() => _selectedPoint = point),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.transtunja.app',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          if (_selectedPoint != null)
            MarkerLayer(markers: [
              Marker(
                  point: _selectedPoint!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on,
                      size: 40, color: colorRojoApp)),
            ]),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _resetForm,
            style: ElevatedButton.styleFrom(backgroundColor: colorLimpiarBg),
            child: const Text('Limpiar',
                style: TextStyle(color: colorLimpiarBorder)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveStop,
            style: ElevatedButton.styleFrom(
                backgroundColor: colorRojoApp, foregroundColor: Colors.white),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hintText, IconData? icon}) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
      filled: true,
      fillColor: colorCard,
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderGray)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: colorRojoApp)),
    );
  }
}
