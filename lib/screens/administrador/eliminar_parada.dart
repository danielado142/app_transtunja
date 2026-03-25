import 'package:flutter/material.dart';
import 'package:app_transtunja/services/parada_service.dart';
import 'package:app_transtunja/models/parada_model.dart';

class EliminarParadaPage extends StatefulWidget {
  const EliminarParadaPage(
      {super.key,
      this.apiBaseUrl =
          'http://10.0.2.2/transtunja'}); // URL típica para emulador vs XAMPP

  final String apiBaseUrl;

  @override
  State<EliminarParadaPage> createState() => _EliminarParadaPageState();
}

class _EliminarParadaPageState extends State<EliminarParadaPage> {
  static const Color rojo = Color(0xFFD10000);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisFondo = Color(0xFFF6F6F7);

  late final ParadaService _paradaService;
  bool _isLoading = true;
  String? _deletingId; // CORREGIDO: Antes era int?, ahora es String?
  List<ParadaModel> _paradas = [];
  ParadaModel? _selectedParada;

  @override
  void initState() {
    super.initState();
    _paradaService = ParadaService(baseUrl: widget.apiBaseUrl);
    _cargarParadas();
  }

  void _showSnack(String texto, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: isError ? rojo : Colors.green,
      ),
    );
  }

  Future<void> _cargarParadas() async {
    setState(() => _isLoading = true);
    try {
      final data = await _paradaService.obtenerParadas();
      if (mounted) setState(() => _paradas = data);
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminarParada(ParadaModel parada) async {
    setState(() => _deletingId = parada.id);

    try {
      final result = await _paradaService.eliminarParada(parada.id);
      if (mounted) {
        if (result['success'] == true || result['status'] == 'success') {
          _showSnack('Parada eliminada correctamente.');
          setState(() {
            _paradas.removeWhere((p) => p.id == parada.id);
            _selectedParada = null;
          });
        } else {
          _showSnack(result['message'] ?? 'Error al eliminar', isError: true);
        }
      }
    } catch (e) {
      _showSnack('Error de red: $e', isError: true);
    } finally {
      if (mounted) setState(() => _deletingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisFondo,
      appBar: AppBar(
        backgroundColor: rojo,
        title: const Text('ELIMINAR PARADAS',
            style: TextStyle(color: blanco, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: blanco),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: rojo))
          : RefreshIndicator(
              onRefresh: _cargarParadas,
              child: _paradas.isEmpty
                  ? const Center(child: Text('No hay paradas para mostrar'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _paradas.length,
                      itemBuilder: (context, index) {
                        final parada = _paradas[index];
                        final isDeleting = _deletingId == parada.id;

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            leading: const Icon(Icons.location_on, color: rojo),
                            title: Text(parada.nombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text('ID Ruta: ${parada.idRuta}'),
                            trailing: isDeleting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : IconButton(
                                    icon: const Icon(Icons.delete_forever,
                                        color: rojo),
                                    onPressed: () async {
                                      bool? confirmar = await _confirmarDialog(
                                          context, parada.nombre);
                                      if (confirmar == true)
                                        _eliminarParada(parada);
                                    },
                                  ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Future<bool?> _confirmarDialog(BuildContext context, String nombre) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Deseas eliminar la parada: $nombre?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: rojo),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ELIMINAR', style: TextStyle(color: blanco)),
          ),
        ],
      ),
    );
  }
}
