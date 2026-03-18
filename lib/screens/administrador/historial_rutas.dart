import 'package:flutter/material.dart';
import '../../services/ruta_service.dart';
import 'ver_ruta.dart';
import 'editar_ruta.dart';

enum FiltroRutas { todas, activas, eliminadas }

class HistorialRutas extends StatefulWidget {
  const HistorialRutas({super.key});

  @override
  State<HistorialRutas> createState() => _HistorialRutasState();
}

class _HistorialRutasState extends State<HistorialRutas> {
  List<Map<String, dynamic>> rutas = [];
  bool cargando = true;
  FiltroRutas filtro = FiltroRutas.todas;

  @override
  void initState() {
    super.initState();
    cargarRutas();
  }

  Future<void> cargarRutas() async {
    setState(() {
      cargando = true;
    });

    final datos = await RutaService.obtenerRutas();

    setState(() {
      rutas = datos;
      cargando = false;
    });
  }

  bool esActiva(Map<String, dynamic> ruta) {
    final estado = (ruta['estado'] ?? 'activo').toString().trim().toLowerCase();
    return estado == 'activo';
  }

  String textoEstado(Map<String, dynamic> ruta) {
    return esActiva(ruta) ? 'Activa' : 'Eliminada';
  }

  Color colorEstado(Map<String, dynamic> ruta) {
    return esActiva(ruta) ? Colors.green : Colors.red;
  }

  List<Map<String, dynamic>> get rutasFiltradas {
    switch (filtro) {
      case FiltroRutas.activas:
        return rutas.where((r) => esActiva(r)).toList();
      case FiltroRutas.eliminadas:
        return rutas.where((r) => !esActiva(r)).toList();
      case FiltroRutas.todas:
        return rutas;
    }
  }

  Map<String, String> extraerOrigenDestino(Map<String, dynamic> ruta) {
    final nombre = (ruta['nombre'] ?? '').toString().trim();
    final destinoBd = (ruta['destino'] ?? '').toString().trim();

    if (nombre.contains(' - ')) {
      final partes = nombre.split(' - ');
      final origen = partes.first.trim();
      final destino = destinoBd.isNotEmpty ? destinoBd : partes.last.trim();

      return {'origen': origen, 'destino': destino};
    }

    return {
      'origen': 'No definido',
      'destino': destinoBd.isNotEmpty ? destinoBd : 'No definido',
    };
  }

  bool tieneCoordenadas(Map<String, dynamic> ruta) {
    final c = (ruta['coordenadas'] ?? '').toString().trim();
    return c.isNotEmpty && c.toLowerCase() != 'null' && c != '[]';
  }

  Future<void> cambiarEstado(Map<String, dynamic> ruta) async {
    final activa = esActiva(ruta);
    final idRuta = (ruta['id_ruta'] ?? '').toString();

    if (idRuta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La ruta no tiene id_ruta válido')),
      );
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          activa
              ? '¿Desea deshabilitar esta ruta?'
              : '¿Desea habilitar esta ruta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(activa ? 'Deshabilitar' : 'Habilitar'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    final resp = activa
        ? await RutaService.deshabilitarRuta(idRuta)
        : await RutaService.habilitarRuta(idRuta);

    if (resp['success'] == true) {
      await cargarRutas();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            activa
                ? 'Ruta deshabilitada correctamente'
                : 'Ruta habilitada correctamente',
          ),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resp['mensaje']?.toString() ?? 'Error al cambiar el estado',
          ),
        ),
      );
    }
  }

  Widget chipFiltro(String texto, bool activo, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: activo ? Colors.redAccent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            color: activo ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = rutasFiltradas;

    return Scaffold(
      backgroundColor: const Color(0xffefefef),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          'HISTORIAL DE RUTAS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.blueGrey,
              radius: 16,
              child: const Text(
                'AU',
                style: TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffe8e8e8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      chipFiltro('Todas', filtro == FiltroRutas.todas, () {
                        setState(() {
                          filtro = FiltroRutas.todas;
                        });
                      }),
                      const SizedBox(width: 8),
                      chipFiltro('Activas', filtro == FiltroRutas.activas, () {
                        setState(() {
                          filtro = FiltroRutas.activas;
                        });
                      }),
                      const SizedBox(width: 8),
                      chipFiltro(
                        'Eliminadas',
                        filtro == FiltroRutas.eliminadas,
                        () {
                          setState(() {
                            filtro = FiltroRutas.eliminadas;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: lista.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay rutas registradas',
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                      : ListView.builder(
                          itemCount: lista.length,
                          itemBuilder: (context, index) {
                            final ruta = lista[index];
                            final activa = esActiva(ruta);
                            final od = extraerOrigenDestino(ruta);
                            final nombre = (ruta['nombre'] ?? 'Ruta')
                                .toString();

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          nombre,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorEstado(ruta),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          textoEstado(ruta),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Código: ${(ruta['id_ruta'] ?? '').toString()}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Origen: ${od['origen']}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Destino: ${od['destino']}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  if (!activa) ...[
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Ruta deshabilitada por el administrador.',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: activa
                                                ? Colors.blue
                                                : Colors.grey,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed:
                                              activa && tieneCoordenadas(ruta)
                                              ? () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => VerRuta(
                                                        coordenadas:
                                                            (ruta['coordenadas'] ??
                                                                    '')
                                                                .toString(),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              : null,
                                          icon: const Icon(Icons.map),
                                          label: const Text('Ver Ruta'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: activa
                                                ? Colors.orange
                                                : Colors.grey,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: activa
                                              ? () async {
                                                  final actualizado =
                                                      await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              EditarRuta(
                                                                ruta: ruta,
                                                              ),
                                                        ),
                                                      );

                                                  if (actualizado == true) {
                                                    await cargarRutas();
                                                  }
                                                }
                                              : null,
                                          icon: const Icon(Icons.edit),
                                          label: const Text('Editar'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: activa
                                                ? Colors.red
                                                : Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: () => cambiarEstado(ruta),
                                          icon: Icon(
                                            activa
                                                ? Icons.block
                                                : Icons.check_circle,
                                          ),
                                          label: Text(
                                            activa
                                                ? 'Deshabilitar'
                                                : 'Habilitar',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: SizedBox(
                                      width: 150,
                                      height: 30,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        onPressed:
                                            activa && tieneCoordenadas(ruta)
                                            ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => VerRuta(
                                                      coordenadas:
                                                          (ruta['coordenadas'] ??
                                                                  '')
                                                              .toString(),
                                                    ),
                                                  ),
                                                );
                                              }
                                            : null,
                                        child: const Text(
                                          'Ver detalles...',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
