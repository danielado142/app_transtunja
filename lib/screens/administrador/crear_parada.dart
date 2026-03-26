import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:app_transtunja/screens/administrador/admin_dashboard.dart';
import 'package:app_transtunja/widgets/trans_tunja_bottom_bar.dart';

class CrearParadaPage extends StatefulWidget {
  const CrearParadaPage({super.key});

  @override
  State<CrearParadaPage> createState() => _CrearParadaPageState();
}

class _CrearParadaPageState extends State<CrearParadaPage> {
  static const Color colorRojoApp = Color(0xFFD10000);
  static const Color colorFondo = Color(0xFFF6F6F7);
  static const Color colorCard = Color(0xFFFFFFFF);
  static const Color colorTextoPrincipal = Color(0xFF000000);
  static const Color colorLimpiarBg = Color(0xFFFFE5E5);
  static const Color colorLimpiarBorder = Color(0xFF8B0000);
  static const Color borderGray = Color(0xFFD9D9D9);

  static const LatLng _tunjaCenter = LatLng(5.5353, -73.3678);

  static const List<String> _diasSemana = [
    'LUNES',
    'MARTES',
    'MIERCOLES',
    'JUEVES',
    'VIERNES',
    'SABADO',
    'DOMINGO',
  ];

  static const List<String> _estados = [
    'activo',
    'inactivo',
  ];

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _rutaController = TextEditingController();
  final MapController _mapController = MapController();

  LatLng _center = _tunjaCenter;
  LatLng? _selectedPoint;
  String? _diaSemanaSeleccionado;
  String _estadoSeleccionado = 'activo';
  bool _formExpanded = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _rutaController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _irASeccionPrincipal(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboard(initialIndex: index),
      ),
      (route) => false,
    );
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
      _center = _tunjaCenter;
      _formExpanded = true;
    });

    _mapController.move(_center, 14);
  }

  void _saveStop() {
    final nombre = _nombreController.text.trim();
    final ruta = _rutaController.text.trim();

    if (nombre.isEmpty) {
      _showSnack('Ingrese el nombre de la parada', isError: true);
      return;
    }

    if (ruta.isEmpty) {
      _showSnack('Ingrese la ruta', isError: true);
      return;
    }

    if (_diaSemanaSeleccionado == null || _diaSemanaSeleccionado!.isEmpty) {
      _showSnack('Seleccione el día de la semana', isError: true);
      return;
    }

    if (_selectedPoint == null) {
      _showSnack('Seleccione un punto en el mapa', isError: true);
      return;
    }

    final nuevaParada = {
      'nombre': nombre,
      'id_ruta': ruta.toUpperCase(),
      'dia_semana': _diaSemanaSeleccionado,
      'estado': _estadoSeleccionado,
      'latitud': _selectedPoint!.latitude,
      'longitud': _selectedPoint!.longitude,
      'referencia': '',
    };

    Navigator.pop(context, nuevaParada);
  }

  InputDecoration _inputDecoration({
    required String hintText,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
      prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
      filled: true,
      fillColor: colorCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: colorRojoApp, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorRojoApp,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'CREAR PARADA',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            children: [
              _buildTopPanel(),
              const SizedBox(height: 12),
              Expanded(child: _buildMapCard()),
              const SizedBox(height: 12),
              _buildBottomButtons(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: TransTunjaBottomBar(
        currentIndex: 2,
        onTap: _irASeccionPrincipal,
      ),
    );
  }

  Widget _buildTopPanel() {
    return Container(
      decoration: BoxDecoration(
        color: colorCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                _formExpanded = !_formExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorRojoApp.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: colorRojoApp,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Datos de la parada',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: colorTextoPrincipal,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Toque para mostrar u ocultar el formulario',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _formExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 30,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _formExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  const Text(
                    'Complete la información y luego seleccione un punto en el mapa.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nombreController,
                    style: const TextStyle(
                      fontSize: 14,
                      color: colorTextoPrincipal,
                    ),
                    decoration: _inputDecoration(
                      hintText: 'Nombre de la parada',
                      icon: Icons.location_on_outlined,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _rutaController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: colorTextoPrincipal,
                    ),
                    decoration: _inputDecoration(
                      hintText: 'Ruta',
                      icon: Icons.alt_route_outlined,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _diaSemanaSeleccionado,
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: colorTextoPrincipal,
                    ),
                    decoration: _inputDecoration(
                      hintText: 'Día de la semana',
                      icon: Icons.calendar_today_outlined,
                    ),
                    items: _diasSemana
                        .map(
                          (dia) => DropdownMenuItem<String>(
                            value: dia,
                            child: Text(dia),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _diaSemanaSeleccionado = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _estadoSeleccionado,
                    isExpanded: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: colorTextoPrincipal,
                    ),
                    decoration: _inputDecoration(
                      hintText: 'Estado',
                      icon: Icons.toggle_on_outlined,
                    ),
                    items: _estados
                        .map(
                          (estado) => DropdownMenuItem<String>(
                            value: estado,
                            child: Text(estado),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _estadoSeleccionado = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      decoration: BoxDecoration(
        color: colorCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 14,
                onTap: (_, point) {
                  setState(() {
                    _selectedPoint = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.transtunja.app',
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                MarkerLayer(
                  markers: _selectedPoint == null
                      ? []
                      : [
                          Marker(
                            point: _selectedPoint!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              size: 40,
                              color: colorRojoApp,
                            ),
                          ),
                        ],
                ),
              ],
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _selectedPoint == null
                      ? 'Toque el mapa para ubicar la parada.'
                      : 'Ubicación seleccionada: '
                          '${_selectedPoint!.latitude.toStringAsFixed(6)}, '
                          '${_selectedPoint!.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: _resetForm,
              style: OutlinedButton.styleFrom(
                backgroundColor: colorLimpiarBg,
                side: const BorderSide(
                  color: colorLimpiarBorder,
                  width: 1.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Limpiar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colorLimpiarBorder,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _saveStop,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorRojoApp,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
