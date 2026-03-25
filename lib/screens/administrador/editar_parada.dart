import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
<<<<<<< HEAD
import 'package:app_transtunja/screens/administrador/parada_service.dart';
=======
import 'package:app_transtunja/services/parada_service.dart';
import 'package:app_transtunja/models/parada_model.dart';
>>>>>>> c09d5070fa997758069075726c9ad8cc0df73607

class EditarParadaPage extends StatefulWidget {
  final String apiBaseUrl;
  const EditarParadaPage({
    super.key,
    this.apiBaseUrl =
        'https://tudominio.com/transtunja', // Usa HTTPS para Hostinger
  });

  @override
  State<EditarParadaPage> createState() => _EditarParadaPageState();
}

class _EditarParadaPageState extends State<EditarParadaPage> {
<<<<<<< HEAD
  static const Color rojo = Color(0xFFD10000);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisFondo = Color(0xFFF6F6F7);
  static const Color azul = Color(0xFF2563EB);
  static const LatLng tunjaCenter = LatLng(5.5353, -73.3678);

  late final ParadaService _paradaService;
  final MapController _mapController = MapController();

  bool _isLoading = true;
=======
  late final ParadaService _paradaService;
>>>>>>> c09d5070fa997758069075726c9ad8cc0df73607
  List<ParadaModel> _paradas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _paradaService = ParadaService(baseUrl: widget.apiBaseUrl);
    _cargarParadas();
  }

<<<<<<< HEAD
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

=======
>>>>>>> c09d5070fa997758069075726c9ad8cc0df73607
  Future<void> _cargarParadas() async {
    setState(() => _isLoading = true);
    try {
      final data = await _paradaService.obtenerParadas();
<<<<<<< HEAD
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
=======
      if (mounted) setState(() => _paradas = data);
>>>>>>> c09d5070fa997758069075726c9ad8cc0df73607
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = _paradas.isNotEmpty
        ? LatLng(_paradas.first.latitud, _paradas.first.longitud)
        : tunjaCenter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GESTIÓN DE PARADAS',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : ListView.builder(
              itemCount: _paradas.length,
              itemBuilder: (context, index) {
                final p = _paradas[index];
                return ListTile(
                  title: Text(p.nombre),
                  subtitle: Text('Ruta: ${p.idRuta} - ${p.diaSemana}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Se usa p.id que ya es String en el modelo
                      final res = await _paradaService.eliminarParada(p.id);
                      if (res['success'] == true) _cargarParadas();
                    },
                  ),
                  onTap: () async {
                    final editado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalleEdicionPage(
                            parada: p, service: _paradaService),
                      ),
                    );
                    if (editado == true) _cargarParadas();
                  },
                );
              },
            ),
<<<<<<< HEAD
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
=======
>>>>>>> c09d5070fa997758069075726c9ad8cc0df73607
    );
  }
}

class DetalleEdicionPage extends StatefulWidget {
  final ParadaModel parada;
  final ParadaService service;
  const DetalleEdicionPage(
      {super.key, required this.parada, required this.service});

  @override
  State<DetalleEdicionPage> createState() => _DetalleEdicionPageState();
}

class _DetalleEdicionPageState extends State<DetalleEdicionPage> {
  late TextEditingController _nombreCtrl;
  LatLng? _point;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.parada.nombre);
    _point = LatLng(widget.parada.latitud, widget.parada.longitud);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Parada')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nombreCtrl,
              decoration:
                  const InputDecoration(labelText: 'Nombre de la parada'),
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _point!,
                initialZoom: 15,
                onTap: (_, p) => setState(() => _point = p),
              ),
              children: [
                TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                MarkerLayer(markers: [
                  Marker(
                    point: _point!,
                    child: const Icon(Icons.location_on,
                        color: Colors.red, size: 40),
                  )
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50, // FIJO: Fuera de styleFrom para evitar error
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _isSaving ? null : _guardarCambios,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ACTUALIZAR EN LA NUBE',
                        style: TextStyle(color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _guardarCambios() async {
    // Validación de datos para evitar el error de "Faltan datos"
    if (_nombreCtrl.text.trim().isEmpty) {
<<<<<<< HEAD
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
=======
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nombre es obligatorio')));
>>>>>>> c09d5070fa997758069075726c9ad8cc0df73607
      return;
    }

    setState(() => _isSaving = true);

    // Aseguramos que todo se envíe como String para el backend PHP
    final Map<String, dynamic> datos = {
      'id_parada': widget.parada.id.toString(),
      'nombre_parada': _nombreCtrl.text.trim(),
      'latitud': _point!.latitude.toString(),
      'longitud': _point!.longitude.toString(),
      'id_ruta': widget.parada.idRuta.toString(),
      'dia_semana': widget.parada.diaSemana,
    };

    try {
      final res = await widget.service.guardarParadaDirecto(datos);
      if (mounted) {
        if (res['success'] == true) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${res['message']}')));
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error de red: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
