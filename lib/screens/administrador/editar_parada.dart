import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_transtunja/screens/administrador/parada_service.dart';

class EditarParadaPage extends StatefulWidget {
  const EditarParadaPage({super.key, this.apiBaseUrl = '/transtunja'});

  final String apiBaseUrl;

  @override
  State<EditarParadaPage> createState() => _EditarParadaPageState();
}

class _EditarParadaPageState extends State<EditarParadaPage> {
  static const Color rojo = Color(0xFFD10000);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisFondo = Color(0xFFF6F6F7);
  static const Color azul = Color(0xFF2563EB);
  static const LatLng tunjaCenter = LatLng(5.5353, -73.3678);

  late final ParadaService _paradaService;
  final MapController _mapController = MapController();

  bool _isLoading = true;
  List<ParadaModel> _paradas = [];

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

  void _showSnack(String texto, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: isError ? rojo : null),
    );
  }

  Future<void> _cargarParadas() async {
    setState(() => _isLoading = true);

    try {
      final data = await _paradaService.obtenerParadas();
      if (!mounted) return;

      setState(() {
        _paradas = data;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (_paradas.isNotEmpty) {
          _mapController.move(
            LatLng(_paradas.first.latitud, _paradas.first.longitud),
            14,
          );
        } else {
          _mapController.move(tunjaCenter, 14);
        }
      });
    } catch (e) {
      _showSnack('Error cargando paradas: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _abrirEditor(ParadaModel parada) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarParadaDetallePage(
          apiBaseUrl: widget.apiBaseUrl,
          parada: parada,
        ),
      ),
    );

    if (result == true) {
      _cargarParadas();
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
        title: const Text(
          'GESTIÓN DE PARADAS',
          style: TextStyle(
            fontFamily: 'Roboto',
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
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EDITAR PARADAS',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Seleccione una parada para modificar su información y ubicación.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
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
                    tileProvider: CancellableNetworkTileProvider(),
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
                ? const Center(child: CircularProgressIndicator(color: rojo))
                : RefreshIndicator(
                    onRefresh: _cargarParadas,
                    child: _paradas.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 160),
                              Center(
                                child: Text(
                                  'No hay paradas registradas.',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
                                                  fontFamily: 'Roboto',
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                parada.referencia.isNotEmpty
                                                    ? parada.referencia
                                                    : '${parada.latitud.toStringAsFixed(6)}, ${parada.longitud.toStringAsFixed(6)}',
                                                style: const TextStyle(
                                                  fontFamily: 'Roboto',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.edit, color: azul),
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
    );
  }
}

class EditarParadaDetallePage extends StatefulWidget {
  const EditarParadaDetallePage({
    super.key,
    required this.apiBaseUrl,
    required this.parada,
  });

  final String apiBaseUrl;
  final ParadaModel parada;

  @override
  State<EditarParadaDetallePage> createState() =>
      _EditarParadaDetallePageState();
}

class _EditarParadaDetallePageState extends State<EditarParadaDetallePage> {
  static const Color rojo = Color(0xFFD10000);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisFondo = Color(0xFFF6F6F7);
  static const Color verde = Color(0xFF16A34A);
  static const Color azul = Color(0xFF2563EB);

  final MapController _mapController = MapController();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _referenciaCtrl = TextEditingController();

  late final ParadaService _paradaService;

  LatLng? _selectedPoint;
  LatLng? _originalPoint;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _paradaService = ParadaService(baseUrl: widget.apiBaseUrl);

    _nombreCtrl.text = widget.parada.nombre;
    _referenciaCtrl.text = widget.parada.referencia;
    _selectedPoint = LatLng(widget.parada.latitud, widget.parada.longitud);
    _originalPoint = LatLng(widget.parada.latitud, widget.parada.longitud);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _referenciaCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _showSnack(String texto, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: isError ? rojo : null),
    );
  }

  void _handleMapTap(LatLng point) {
    if (_isSaving) return;

    setState(() {
      _selectedPoint = point;
    });

    _showSnack('Ubicación actualizada en el mapa.');
  }

  String? _validar() {
    if (_nombreCtrl.text.trim().isEmpty) {
      return 'El nombre de la parada es obligatorio.';
    }
    if (_selectedPoint == null) {
      return 'Debe seleccionar un punto en el mapa.';
    }
    return null;
  }

  void _restablecer() {
    setState(() {
      _nombreCtrl.text = widget.parada.nombre;
      _referenciaCtrl.text = widget.parada.referencia;
      _selectedPoint = _originalPoint;
    });

    if (_originalPoint != null) {
      _mapController.move(_originalPoint!, 15);
    }
  }

  Future<void> _guardarParada() async {
    final validation = _validar();
    if (validation != null) {
      _showSnack(validation, isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final paradaActualizada = ParadaModel(
        id: widget.parada.id,
        nombre: _nombreCtrl.text.trim(),
        referencia: _referenciaCtrl.text.trim(),
        latitud: _selectedPoint!.latitude,
        longitud: _selectedPoint!.longitude,
        estado: widget.parada.estado,
      );

      final result = await _paradaService.guardarParada(paradaActualizada);

      if (!mounted) return;

      if (result['success'] == true) {
        _showSnack('Parada actualizada correctamente.');
        Navigator.pop(context, true);
      } else {
        _showSnack(
          result['message']?.toString() ?? 'No se pudo actualizar la parada.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnack('Error actualizando parada: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmarGuardar() async {
    final confirmar = await _showActionDialog(
      context: context,
      title: 'Confirmación',
      message: '¿Desea guardar los cambios de esta parada?',
      yesText: 'Sí',
      noText: 'No',
      yesColor: verde,
      noColor: azul,
    );

    if (confirmar == true) {
      await _guardarParada();
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
        title: const Text(
          'GESTIÓN DE PARADAS',
          style: TextStyle(
            fontFamily: 'Roboto',
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
                      'EDITAR PARADA',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Modifique la información y toque el mapa para reubicar la parada.',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _nombreCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la parada',
                        labelStyle: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                        ),
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
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _referenciaCtrl,
                      decoration: InputDecoration(
                        labelText: 'Referencia',
                        labelStyle: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                        ),
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
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedPoint == null
                          ? 'Toque el mapa para ubicar la parada.'
                          : 'Ubicación: ${_selectedPoint!.latitude.toStringAsFixed(6)}, ${_selectedPoint!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
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
                    onTap: (_, point) => _handleMapTap(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.transtunja.admin',
                      tileProvider: CancellableNetworkTileProvider(),
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
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _restablecer,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: azul,
                      side: const BorderSide(color: azul),
                      backgroundColor: blanco,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Restablecer',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _confirmarGuardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verde,
                      foregroundColor: blanco,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: blanco,
                            ),
                          )
                        : const Text(
                            'Guardar',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

Future<bool?> _showActionDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String yesText,
  required String noText,
  required Color yesColor,
  required Color noColor,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: noColor,
                            side: BorderSide(color: noColor),
                          ),
                          child: Text(
                            noText,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yesColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            yesText,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
