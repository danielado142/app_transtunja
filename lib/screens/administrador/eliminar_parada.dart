import 'package:flutter/material.dart';
import 'package:app_transtunja/services/parada_service.dart';

class EliminarParadaPage extends StatefulWidget {
  const EliminarParadaPage({super.key, this.apiBaseUrl = '/transtunja'});

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
  int? _deletingId;
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
    } catch (e) {
      _showSnack('Error cargando paradas: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _seleccionarYConfirmar(ParadaModel parada) async {
    setState(() {
      _selectedParada = parada;
    });

    final confirmar = await _showDeleteDialog(
      context: context,
      nombreParada: parada.nombre,
    );

    if (confirmar == true) {
      await _eliminarParada(parada);
    }
  }

  Future<void> _eliminarParada(ParadaModel parada) async {
    if (parada.id == null) {
      _showSnack('La parada no tiene un id válido.', isError: true);
      return;
    }

    setState(() {
      _deletingId = parada.id;
    });

    try {
      final result = await _paradaService.eliminarParada(parada.id!);

      if (!mounted) return;

      if (result['success'] == true) {
        _showSnack('Parada eliminada correctamente.');
        setState(() {
          _paradas.removeWhere((p) => p.id == parada.id);
          if (_selectedParada?.id == parada.id) {
            _selectedParada = null;
          }
        });
      } else {
        _showSnack(
          result['message']?.toString() ?? 'No se pudo eliminar la parada.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnack('Error eliminando parada: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _deletingId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            color: Colors.white,
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
                  'ELIMINAR PARADAS',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Seleccione una parada para eliminarla.',
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
                              final isSelected =
                                  _selectedParada?.id == parada.id;
                              final isDeleting = _deletingId == parada.id;

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: isDeleting
                                      ? null
                                      : () => _seleccionarYConfirmar(parada),
                                  child: Card(
                                    color: blanco,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: isSelected
                                            ? rojo
                                            : Colors.black12,
                                        width: isSelected ? 1.4 : 1,
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
                                          isDeleting
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2.4,
                                                        color: rojo,
                                                      ),
                                                )
                                              : const Icon(
                                                  Icons.delete_outline,
                                                  color: rojo,
                                                ),
                                        ],
                                      ),
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

Future<bool?> _showDeleteDialog({
  required BuildContext context,
  required String nombreParada,
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
                  const Text(
                    'CONFIRMACIÓN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '¿Está seguro de eliminar esta parada?\n$nombreParada',
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
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFD10000),
                            elevation: 0,
                            side: const BorderSide(color: Colors.black12),
                          ),
                          child: const Text(
                            'Sí',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD10000),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'No',
                            style: TextStyle(
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
