import 'package:flutter/material.dart';
import 'package:app_transtunja/screens/administrador/admin_dashboard.dart';
import 'package:app_transtunja/screens/administrador/parada_service.dart';
import 'package:app_transtunja/models/parada_model.dart';
import 'package:app_transtunja/widgets/trans_tunja_bottom_bar.dart';

class EliminarParadaPage extends StatefulWidget {
  const EliminarParadaPage({
    super.key,
    this.apiBaseUrl = 'http://10.0.2.2/transtunja',
  });

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
  String? _deletingId;
  List<ParadaModel> _paradas = [];

  @override
  void initState() {
    super.initState();
    _paradaService = ParadaService(baseUrl: widget.apiBaseUrl);
    _cargarParadas();
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
        backgroundColor: isError ? rojo : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
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
    } catch (e) {
      _showSnack('Error al cargar paradas: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _eliminarParada(ParadaModel parada) async {
    final paradaId = parada.id.toString();

    setState(() => _deletingId = paradaId);

    try {
      final result = await _paradaService.eliminarParada(paradaId);

      if (!mounted) return;

      if (result['success'] == true || result['status'] == 'success') {
        _showSnack('Parada eliminada correctamente.');
        setState(() {
          _paradas.removeWhere((p) => p.id.toString() == paradaId);
        });
      } else {
        _showSnack(
          result['message']?.toString() ?? 'Error al eliminar',
          isError: true,
        );
      }
    } catch (e) {
      _showSnack('Error de red: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _deletingId = null);
      }
    }
  }

  Future<bool?> _confirmarDialog(String nombre) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Deseas eliminar la parada: $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: rojo),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: blanco),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisFondo,
      appBar: AppBar(
        backgroundColor: rojo,
        title: const Text(
          'ELIMINAR PARADAS',
          style: TextStyle(
            color: blanco,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: blanco),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: rojo),
            )
          : RefreshIndicator(
              onRefresh: _cargarParadas,
              child: _paradas.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 220),
                        Center(
                          child: Text('No hay paradas para mostrar'),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _paradas.length,
                      itemBuilder: (context, index) {
                        final parada = _paradas[index];
                        final paradaId = parada.id.toString();
                        final isDeleting = _deletingId == paradaId;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.location_on, color: rojo),
                            title: Text(
                              parada.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('ID Ruta: ${parada.idRuta}'),
                            trailing: isDeleting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      color: rojo,
                                    ),
                                    onPressed: () async {
                                      final confirmar =
                                          await _confirmarDialog(parada.nombre);
                                      if (confirmar == true) {
                                        await _eliminarParada(parada);
                                      }
                                    },
                                  ),
                          ),
                        );
                      },
                    ),
            ),
      bottomNavigationBar: TransTunjaBottomBar(
        currentIndex: 2,
        onTap: _irASeccionPrincipal,
      ),
    );
  }
}
