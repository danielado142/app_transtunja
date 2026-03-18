import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/ruta_service.dart';

class EditarRuta extends StatefulWidget {
  final Map<String, dynamic> ruta;

  const EditarRuta({super.key, required this.ruta});

  @override
  State<EditarRuta> createState() => _EditarRutaState();
}

class _EditarRutaState extends State<EditarRuta> {
  late TextEditingController nombreCtrl;
  late TextEditingController destinoCtrl;

  List<LatLng> puntos = [];
  List<LatLng> puntosOriginales = [];

  late String nombreOriginal;
  late String destinoOriginal;

  bool guardando = false;

  @override
  void initState() {
    super.initState();

    guardando = false;

    nombreOriginal = (widget.ruta['nombre'] ?? '').toString();
    destinoOriginal = (widget.ruta['destino'] ?? '').toString();

    nombreCtrl = TextEditingController(text: nombreOriginal);
    destinoCtrl = TextEditingController(text: destinoOriginal);

    puntos = _parsearCoordenadas((widget.ruta['coordenadas'] ?? '').toString());
    puntosOriginales = List<LatLng>.from(puntos);
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    destinoCtrl.dispose();
    super.dispose();
  }

  List<LatLng> _parsearCoordenadas(String raw) {
    final texto = raw.trim();

    if (texto.isEmpty || texto.toLowerCase() == 'null' || texto == '[]') {
      return [];
    }

    try {
      final decoded = jsonDecode(texto);
      if (decoded is List) {
        return decoded
            .whereType<List>()
            .where((e) => e.length >= 2)
            .map(
              (e) => LatLng(
                double.parse(e[0].toString()),
                double.parse(e[1].toString()),
              ),
            )
            .toList();
      }
    } catch (_) {}

    final regexLatLng = RegExp(
      r'LatLng\(latitude:\s*(-?\d+(?:\.\d+)?),\s*longitude:\s*(-?\d+(?:\.\d+)?)\)',
    );
    final matchesLatLng = regexLatLng.allMatches(texto);

    if (matchesLatLng.isNotEmpty) {
      return matchesLatLng
          .map(
            (m) => LatLng(double.parse(m.group(1)!), double.parse(m.group(2)!)),
          )
          .toList();
    }

    final regexPar = RegExp(
      r'\[\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*\]',
    );
    final matchesPar = regexPar.allMatches(texto);

    return matchesPar
        .map(
          (m) => LatLng(double.parse(m.group(1)!), double.parse(m.group(2)!)),
        )
        .toList();
  }

  String _serializarPuntos() {
    final lista = puntos.map((p) => [p.latitude, p.longitude]).toList();
    return jsonEncode(lista);
  }

  void _agregarPunto(LatLng point) {
    setState(() {
      puntos.add(point);
    });
  }

  void _eliminarPuntoCercano(LatLng point) {
    if (puntos.isEmpty) return;

    int indice = 0;
    double mejor = _distanciaCuadrada(puntos[0], point);

    for (int i = 1; i < puntos.length; i++) {
      final d = _distanciaCuadrada(puntos[i], point);
      if (d < mejor) {
        mejor = d;
        indice = i;
      }
    }

    setState(() {
      puntos.removeAt(indice);
    });
  }

  double _distanciaCuadrada(LatLng a, LatLng b) {
    final dx = a.latitude - b.latitude;
    final dy = a.longitude - b.longitude;
    return dx * dx + dy * dy;
  }

  Future<void> _mostrarDialogoExito(
    String mensaje, {
    bool cerrarPantalla = false,
  }) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 16),
              const Text(
                'Éxito',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (cerrarPantalla) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoError(String mensaje) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 16),
              const Text(
                'Error',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _restablecerRuta() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Está seguro de restablecer esta ruta?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'NO',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'SI',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmado == true) {
      setState(() {
        nombreCtrl.text = nombreOriginal;
        destinoCtrl.text = destinoOriginal;
        puntos = List<LatLng>.from(puntosOriginales);
      });

      await _mostrarDialogoExito('Se guardó exitosamente');
    }
  }

  Future<void> _guardarCambios() async {
    final idRuta = (widget.ruta['id_ruta'] ?? '').toString().trim();
    final nombre = nombreCtrl.text.trim();
    final destino = destinoCtrl.text.trim();

    if (idRuta.isEmpty) {
      await _mostrarDialogoError('La ruta no tiene id_ruta válido');
      return;
    }

    if (nombre.isEmpty || destino.isEmpty) {
      await _mostrarDialogoError('Completa nombre y destino');
      return;
    }

    if (puntos.isEmpty) {
      await _mostrarDialogoError('La ruta debe tener al menos un punto');
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      final resp = await RutaService.actualizarRuta(
        idRuta,
        nombre,
        destino,
        _serializarPuntos(),
      );

      if (!mounted) return;

      if (resp['success'] == true) {
        setState(() {
          guardando = false;
        });

        await _mostrarDialogoExito(
          'Se guardó exitosamente',
          cerrarPantalla: true,
        );
      } else {
        setState(() {
          guardando = false;
        });

        await _mostrarDialogoError(
          resp['mensaje']?.toString() ?? 'Error al actualizar la ruta',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      await _mostrarDialogoError('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final centro = puntos.isNotEmpty
        ? puntos.first
        : const LatLng(5.5353, -73.3678);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'EDITAR RUTA',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      backgroundColor: const Color(0xffefefef),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Editar Rutas',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la ruta',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: destinoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Destino',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: guardando ? null : _restablecerRuta,
                            icon: const Icon(Icons.restore, color: Colors.blue),
                            label: const Text(
                              'Restablecer',
                              style: TextStyle(color: Colors.blue),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.blueGrey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: guardando ? null : _guardarCambios,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: guardando
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save, color: Colors.white),
                            label: Text(
                              guardando ? 'Guardando...' : 'Guardar cambios',
                              style: TextStyle(
                                color: guardando ? Colors.white : Colors.white,
                                fontWeight: FontWeight.w600,
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

            const SizedBox(height: 14),

            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: centro,
                    initialZoom: 14,
                    onTap: (tapPosition, point) {
                      _agregarPunto(point);
                    },
                    onLongPress: (tapPosition, point) {
                      _eliminarPuntoCercano(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: puntos,
                          strokeWidth: 4,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: puntos
                          .map(
                            (p) => Marker(
                              point: p,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 38,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
