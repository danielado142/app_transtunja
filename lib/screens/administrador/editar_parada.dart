import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_transtunja/services/parada_service.dart';
import 'package:app_transtunja/models/parada_model.dart';

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
  late final ParadaService _paradaService;
  List<ParadaModel> _paradas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _paradaService = ParadaService(baseUrl: widget.apiBaseUrl);
    _cargarParadas();
  }

  Future<void> _cargarParadas() async {
    setState(() => _isLoading = true);
    try {
      final data = await _paradaService.obtenerParadas();
      if (mounted) setState(() => _paradas = data);
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nombre es obligatorio')));
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
