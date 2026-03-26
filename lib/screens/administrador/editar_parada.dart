import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_transtunja/screens/administrador/admin_dashboard.dart';
import 'package:app_transtunja/screens/administrador/parada_service.dart';
import 'package:app_transtunja/models/parada_model.dart';
import 'package:app_transtunja/widgets/trans_tunja_bottom_bar.dart';

class EditarParadaPage extends StatefulWidget {
  final String apiBaseUrl;

  const EditarParadaPage({
    super.key,
    this.apiBaseUrl =
        'https://springgreen-ferret-866521.hostingersite.com/TransTunja/api',
  });

  @override
  State<EditarParadaPage> createState() => _EditarParadaPageState();
}

class _EditarParadaPageState extends State<EditarParadaPage> {
  static const Color rojo = Color(0xFFD10000);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisFondo = Color(0xFFF6F6F7);
  static const LatLng tunjaCenter = LatLng(5.5353, -73.3678);

  late final ParadaService _paradaService;
  final MapController _mapController = MapController();

  List<ParadaModel> _paradas = [];
  bool _isLoading = true;
  String? _loadErrorMessage;

  @override
  void initState() {
    super.initState();
    _paradaService = ParadaService(baseUrl: widget.apiBaseUrl);
    _cargarParadas();
  }

  @override
  void dispose() {
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

  Future<void> _cargarParadas() async {
    setState(() {
      _isLoading = true;
      _loadErrorMessage = null;
    });

    try {
      final data = await _paradaService.obtenerParadas();
      if (!mounted) return;

      setState(() {
        _paradas = data;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final center = _paradas.isNotEmpty
            ? LatLng(_paradas.first.latitud, _paradas.first.longitud)
            : tunjaCenter;
        _mapController.move(center, 14);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _paradas = [];
        _loadErrorMessage =
            'No se pudieron cargar las paradas.\nVerifica la conexión o el servicio.';
      });

      _showSnack('Error al cargar paradas: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _abrirEditor(ParadaModel parada) async {
    final editado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleEdicionPage(
          parada: parada,
          service: _paradaService,
        ),
      ),
    );

    if (editado == true) {
      await _cargarParadas();
    }
  }

  Future<void> _eliminarParada(ParadaModel parada) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar parada'),
          content: Text('¿Deseas eliminar la parada "${parada.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: rojo),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      final res = await _paradaService.eliminarParada(parada.id.toString());
      final ok = res['success'] == true || res['status'] == 'success';

      if (ok) {
        _showSnack('Parada eliminada correctamente');
        await _cargarParadas();
      } else {
        _showSnack(
          'No se pudo eliminar: ${res['message'] ?? 'Error desconocido'}',
          isError: true,
        );
      }
    } catch (e) {
      _showSnack('Error al eliminar: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = _paradas.isNotEmpty
        ? LatLng(_paradas.first.latitud, _paradas.first.longitud)
        : tunjaCenter;

    return Scaffold(
      backgroundColor: grisFondo,
      appBar: AppBar(
        backgroundColor: rojo,
        elevation: 0,
        iconTheme: const IconThemeData(color: blanco),
        title: const Text(
          'GESTIÓN DE PARADAS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: blanco,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: blanco,
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EDITAR PARADAS',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Seleccione una parada para modificar su información y ubicación.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 320,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            decoration: BoxDecoration(
              color: blanco,
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
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.transtunja.admin',
                  ),
                  if (_paradas.isNotEmpty)
                    MarkerLayer(
                      markers: _paradas.map((parada) {
                        return Marker(
                          point: LatLng(parada.latitud, parada.longitud),
                          width: 54,
                          height: 54,
                          child: GestureDetector(
                            onTap: () => _abrirEditor(parada),
                            child: const _ParadaPinIcon(size: 52),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: rojo),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarParadas,
                    child: _loadErrorMessage != null
                        ? ListView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            children: [
                              const SizedBox(height: 40),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: blanco,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.cloud_off,
                                      color: rojo,
                                      size: 42,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _loadErrorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      height: 48,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _cargarParadas,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: rojo,
                                          foregroundColor: blanco,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: const Text(
                                          'Reintentar',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : _paradas.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 160),
                                  Center(
                                    child: Text(
                                      'No hay paradas registradas.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 20),
                                itemCount: _paradas.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, index) {
                                  final parada = _paradas[index];

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => _abrirEditor(parada),
                                    child: Card(
                                      color: blanco,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: const BorderSide(
                                          color: Colors.black12,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Row(
                                          children: [
                                            const _ParadaPinIcon(size: 46),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    parada.nombre,
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Ruta: ${parada.idRuta} · ${parada.diaSemana}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: 'Eliminar',
                                              onPressed: () =>
                                                  _eliminarParada(parada),
                                              icon: const Icon(
                                                Icons.delete,
                                                color: rojo,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.edit,
                                              color: rojo,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: TransTunjaBottomBar(
        currentIndex: 2,
        onTap: _irASeccionPrincipal,
      ),
    );
  }
}

class DetalleEdicionPage extends StatefulWidget {
  final ParadaModel parada;
  final ParadaService service;

  const DetalleEdicionPage({
    super.key,
    required this.parada,
    required this.service,
  });

  @override
  State<DetalleEdicionPage> createState() => _DetalleEdicionPageState();
}

class _DetalleEdicionPageState extends State<DetalleEdicionPage> {
  static const Color rojo = Color(0xFFD10000);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisFondo = Color(0xFFF6F6F7);
  static const Color colorLimpiarBg = Color(0xFFFFE5E5);
  static const Color colorLimpiarBorder = Color(0xFF8B0000);

  final MapController _mapController = MapController();
  late final TextEditingController _nombreCtrl;

  late LatLng _originalPoint;
  LatLng? _selectedPoint;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.parada.nombre);
    _originalPoint = LatLng(widget.parada.latitud, widget.parada.longitud);
    _selectedPoint = _originalPoint;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
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

  void _restablecer() {
    setState(() {
      _nombreCtrl.text = widget.parada.nombre;
      _selectedPoint = _originalPoint;
    });

    _mapController.move(_originalPoint, 15);
  }

  Future<void> _guardarParada() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      _showSnack('El nombre de la parada es obligatorio.', isError: true);
      return;
    }

    if (_selectedPoint == null) {
      _showSnack('Debe seleccionar un punto en el mapa.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final Map<String, dynamic> datos = {
      'id_parada': widget.parada.id.toString(),
      'nombre_parada': _nombreCtrl.text.trim(),
      'latitud': _selectedPoint!.latitude.toString(),
      'longitud': _selectedPoint!.longitude.toString(),
      'id_ruta': widget.parada.idRuta.toString(),
      'dia_semana': widget.parada.diaSemana.toString(),
    };

    try {
      final res = await widget.service.guardarParadaDirecto(datos);

      if (!mounted) return;

      if (res['success'] == true || res['status'] == 'success') {
        _showSnack('Parada actualizada correctamente');
        Navigator.pop(context, true);
      } else {
        _showSnack(
          'Error: ${res['message'] ?? 'No se pudo actualizar la parada'}',
          isError: true,
        );
      }
    } catch (e) {
      _showSnack('Error de red: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = _selectedPoint ?? const LatLng(5.5353, -73.3678);

    return Scaffold(
      backgroundColor: grisFondo,
      appBar: AppBar(
        backgroundColor: rojo,
        elevation: 0,
        iconTheme: const IconThemeData(color: blanco),
        title: const Text(
          'EDITAR PARADA',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: blanco,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              color: blanco,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.black12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DATOS DE LA PARADA',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Modifique la información y toque el mapa para reubicar la parada.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _nombreCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la parada',
                        filled: true,
                        fillColor: grisFondo,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: rojo, width: 1.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedPoint == null
                          ? 'Toque el mapa para ubicar la parada.'
                          : 'Ubicación: ${_selectedPoint!.latitude.toStringAsFixed(6)}, ${_selectedPoint!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: mapCenter,
                    initialZoom: 15,
                    onTap: (_, point) {
                      setState(() {
                        _selectedPoint = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.transtunja.admin',
                    ),
                    if (_selectedPoint != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPoint!,
                            width: 54,
                            height: 54,
                            child: const _ParadaPinIcon(size: 52),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _restablecer,
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
                        'Restablecer',
                        style: TextStyle(
                          fontSize: 12,
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
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _guardarParada,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: rojo,
                        foregroundColor: blanco,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: blanco,
                              ),
                            )
                          : const Text(
                              'Guardar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: TransTunjaBottomBar(
        currentIndex: 2,
        onTap: _irASeccionPrincipal,
      ),
    );
  }
}

class _ParadaPinIcon extends StatelessWidget {
  const _ParadaPinIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size + 6,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Icon(Icons.location_on, size: size, color: const Color(0xFFD10000)),
          Positioned(
            top: size * 0.22,
            child: Container(
              width: size * 0.32,
              height: size * 0.32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                'P',
                style: TextStyle(
                  fontSize: size * 0.16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
