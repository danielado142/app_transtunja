import 'package:flutter/material.dart';

class AsignarConductorRuta extends StatefulWidget {
  const AsignarConductorRuta({super.key});

  @override
  State<AsignarConductorRuta> createState() => _AsignarConductorRutaState();
}

class _AsignarConductorRutaState extends State<AsignarConductorRuta> {
  // =========================
  // COLORES Y ESTILOS
  // =========================
  static const Color colorRojoApp = Color(0xFFD10000);
  static const Color colorFondo = Color(0xFFF6F6F7);
  static const Color colorBlanco = Color(0xFFFFFFFF);
  static const Color colorTexto = Color(0xFF000000);

  static const TextStyle estiloTituloAppBar = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    fontFamily: 'Roboto',
  );

  static const TextStyle estiloTituloCard = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w900,
    color: colorTexto,
    fontFamily: 'Roboto',
  );

  static const TextStyle estiloSubtitulo = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.black54,
    fontFamily: 'Roboto',
  );

  static const TextStyle estiloTextoNormal = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
    fontFamily: 'Roboto',
  );

  static const TextStyle estiloEtiqueta = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: colorTexto,
    fontFamily: 'Roboto',
  );

  // =========================
  // DATOS MOCK TEMPORALES
  // Luego se reemplazan por API/BD
  // =========================
  final List<Map<String, dynamic>> conductores = [
    {
      'id_conductor': 1,
      'nombre': 'Conductor #1',
      'licencia': 'LIC001',
      'grupo_sanguineo': 'O',
      'arl': 'SURA',
      'estado': 'activo',
    },
    {
      'id_conductor': 2,
      'nombre': 'Conductor #2',
      'licencia': 'LIC002',
      'grupo_sanguineo': 'A',
      'arl': 'AXA',
      'estado': 'activo',
    },
    {
      'id_conductor': 3,
      'nombre': 'Conductor #3',
      'licencia': 'LIC003',
      'grupo_sanguineo': 'B',
      'arl': 'SURA',
      'estado': 'activo',
    },
    {
      'id_conductor': 4,
      'nombre': 'Conductor #4',
      'licencia': 'LIC004',
      'grupo_sanguineo': 'AB',
      'arl': 'COLPATRIA',
      'estado': 'activo',
    },
    {
      'id_conductor': 8,
      'nombre': 'Conductor #8',
      'licencia': 'C2-1049123',
      'grupo_sanguineo': null,
      'arl': null,
      'estado': 'activo',
    },
  ];

  final List<Map<String, dynamic>> rutas = [
    {
      'id_ruta': 1,
      'nombre': 'Ruta Centro',
      'origen': 'Terminal Norte',
      'destino': 'Plaza Central',
      'estado': 'activo',
    },
    {
      'id_ruta': 2,
      'nombre': 'Ruta Sur',
      'origen': 'Avenida Sur',
      'destino': 'Hospital Regional',
      'estado': 'activo',
    },
    {
      'id_ruta': 3,
      'nombre': 'Ruta Universitaria',
      'origen': 'Centro Histórico',
      'destino': 'Campus UPTC',
      'estado': 'activo',
    },
  ];

  Map<String, dynamic>? conductorSeleccionado;
  Map<String, dynamic>? rutaSeleccionada;

  String get fechaActual {
    final now = DateTime.now();
    final dia = now.day.toString().padLeft(2, '0');
    final mes = now.month.toString().padLeft(2, '0');
    final anio = now.year.toString();
    return '$dia/$mes/$anio';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorRojoApp,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ASIGNAR CONDUCTOR A RUTA',
          style: estiloTituloAppBar,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Conductor', style: estiloTituloCard),
                    const SizedBox(height: 4),
                    const Text(
                      'Selecciona un conductor activo para asignarlo a una ruta',
                      style: estiloSubtitulo,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: conductorSeleccionado?['id_conductor'],
                      decoration: _inputDecoration(
                        hint: 'Selecciona un conductor',
                        icon: Icons.person_outline,
                      ),
                      items: conductores.map((conductor) {
                        return DropdownMenuItem<int>(
                          value: conductor['id_conductor'] as int,
                          child: Text(
                            '${conductor['nombre']}',
                            style: estiloTextoNormal.copyWith(
                              color: colorTexto,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          conductorSeleccionado = conductores.firstWhere(
                            (c) => c['id_conductor'] == value,
                          );
                        });
                      },
                    ),
                    if (conductorSeleccionado != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.badge_outlined,
                                  color: colorRojoApp,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    conductorSeleccionado!['nombre'] ??
                                        'Conductor sin nombre',
                                    style: estiloTituloCard.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                _buildEstadoBadge(
                                  conductorSeleccionado!['estado'] ?? 'activo',
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildDato(
                              'Licencia',
                              conductorSeleccionado!['licencia'] ??
                                  'No registrada',
                            ),
                            _buildDato(
                              'Grupo sanguíneo',
                              conductorSeleccionado!['grupo_sanguineo'] ??
                                  'No registrado',
                            ),
                            _buildDato(
                              'ARL',
                              conductorSeleccionado!['arl'] ?? 'No registrada',
                            ),
                            _buildDato(
                              'ID conductor',
                              '${conductorSeleccionado!['id_conductor']}',
                            ),
                            if (conductorSeleccionado!['grupo_sanguineo'] ==
                                    null ||
                                conductorSeleccionado!['arl'] == null) ...[
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: const Text(
                                  'Este conductor tiene datos incompletos.',
                                  style: estiloTextoNormal,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ruta', style: estiloTituloCard),
                    const SizedBox(height: 4),
                    const Text(
                      'Selecciona la ruta que recibirá esta asignación',
                      style: estiloSubtitulo,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: rutaSeleccionada?['id_ruta'],
                      decoration: _inputDecoration(
                        hint: 'Selecciona una ruta',
                        icon: Icons.alt_route,
                      ),
                      items: rutas.map((ruta) {
                        return DropdownMenuItem<int>(
                          value: ruta['id_ruta'] as int,
                          child: Text(
                            '${ruta['nombre']}',
                            style: estiloTextoNormal.copyWith(
                              color: colorTexto,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          rutaSeleccionada = rutas.firstWhere(
                            (r) => r['id_ruta'] == value,
                          );
                        });
                      },
                    ),
                    if (rutaSeleccionada != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.route,
                                  color: colorRojoApp,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    rutaSeleccionada!['nombre'] ?? 'Ruta',
                                    style: estiloTituloCard.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                _buildEstadoBadge(
                                  rutaSeleccionada!['estado'] ?? 'activo',
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '${rutaSeleccionada!['origen']} → ${rutaSeleccionada!['destino']}',
                              style: estiloSubtitulo,
                            ),
                            const SizedBox(height: 10),
                            _buildDato(
                              'Origen',
                              rutaSeleccionada!['origen'] ?? 'No definido',
                            ),
                            _buildDato(
                              'Destino',
                              rutaSeleccionada!['destino'] ?? 'No definido',
                            ),
                            _buildDato(
                              'ID ruta',
                              '${rutaSeleccionada!['id_ruta']}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resumen de asignación',
                        style: estiloTituloCard),
                    const SizedBox(height: 4),
                    const Text(
                      'Verifica la información antes de guardar',
                      style: estiloSubtitulo,
                    ),
                    const SizedBox(height: 16),
                    _buildDato(
                      'Conductor',
                      conductorSeleccionado?['nombre'] ?? 'Aún no seleccionado',
                    ),
                    _buildDato(
                      'Licencia',
                      conductorSeleccionado?['licencia'] ?? 'No disponible',
                    ),
                    _buildDato(
                      'Ruta',
                      rutaSeleccionada?['nombre'] ?? 'Aún no seleccionada',
                    ),
                    _buildDato('Fecha', fechaActual),
                    _buildDato(
                      'Estado',
                      conductorSeleccionado != null && rutaSeleccionada != null
                          ? 'activo'
                          : 'pendiente',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorRojoApp,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: (conductorSeleccionado != null &&
                          rutaSeleccionada != null)
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: colorRojoApp,
                              content: Text(
                                'Asignación lista para guardar: '
                                '${conductorSeleccionado!['nombre']} → ${rutaSeleccionada!['nombre']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          );

                          // AQUÍ LUEGO VA LA CONEXIÓN A TU API / BD
                          // Enviarías:
                          // id_conductor: conductorSeleccionado!['id_conductor']
                          // id_ruta: rutaSeleccionada!['id_ruta']
                          // fecha_asignacion: DateTime.now()
                          // estado: 'activo'
                        }
                      : null,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    'Guardar asignación',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorBlanco,
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
      child: child,
    );
  }

  Widget _buildInfoContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorBlanco,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: child,
    );
  }

  Widget _buildDato(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              etiqueta,
              style: estiloEtiqueta,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoBadge(String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorRojoApp,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.black54,
        fontFamily: 'Roboto',
      ),
      prefixIcon: const Icon(
        Icons.circle,
        color: Colors.transparent,
        size: 0,
      ),
      suffixIcon: Icon(
        icon,
        color: colorRojoApp,
        size: 20,
      ),
      filled: true,
      fillColor: colorBlanco,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: colorRojoApp, width: 1.3),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black26),
      ),
    );
  }
}
