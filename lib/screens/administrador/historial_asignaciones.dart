import 'package:flutter/material.dart';

class HistorialAsignaciones extends StatefulWidget {
  const HistorialAsignaciones({super.key});

  @override
  State<HistorialAsignaciones> createState() => _HistorialAsignacionesState();
}

class _HistorialAsignacionesState extends State<HistorialAsignaciones> {
  // =========================
  // COLORES
  // =========================
  static const Color colorRojoApp = Color(0xFFD10000);
  static const Color colorFondo = Color(0xFFF6F6F7);
  static const Color colorBlanco = Color(0xFFFFFFFF);
  static const Color colorTexto = Color(0xFF000000);

  // =========================
  // TIPOGRAFÍA
  // =========================
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

  static const TextStyle estiloBadge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: colorTexto,
    fontFamily: 'Roboto',
  );

  // =========================
  // DATOS TEMPORALES
  // =========================
  final List<Map<String, dynamic>> historialAsignaciones = [
    {
      'conductor': 'Juan Pérez',
      'licencia': 'LIC001',
      'ruta': 'Ruta 101 - Centro Histórico',
      'fecha': DateTime(2024, 5, 22),
      'estado': 'activa',
    },
    {
      'conductor': 'Ana Gómez',
      'licencia': 'LIC002',
      'ruta': 'Ruta 205 - Suburbios Norte',
      'fecha': DateTime(2024, 5, 21),
      'estado': 'finalizada',
    },
    {
      'conductor': 'Luis Fernández',
      'licencia': 'LIC003',
      'ruta': 'Ruta 203 - Parque Industrial',
      'fecha': DateTime(2024, 5, 20),
      'estado': 'activa',
    },
    {
      'conductor': 'Marta Díaz',
      'licencia': 'LIC004',
      'ruta': 'Ruta 404 - Zona Comercial',
      'fecha': DateTime(2024, 5, 19),
      'estado': 'cancelada',
    },
    {
      'conductor': 'Carlos Ruiz',
      'licencia': 'LIC005',
      'ruta': 'Ruta 110 - Terminal Norte',
      'fecha': DateTime.now().subtract(const Duration(days: 3)),
      'estado': 'activa',
    },
    {
      'conductor': 'Paula Torres',
      'licencia': 'LIC006',
      'ruta': 'Ruta 301 - Universidad',
      'fecha': DateTime.now().subtract(const Duration(days: 12)),
      'estado': 'reasignada',
    },
  ];

  String filtroActual = 'todos';
  String textoBusqueda = '';
  int currentIndex = 3;

  List<Map<String, dynamic>> get historialFiltrado {
    List<Map<String, dynamic>> lista = historialAsignaciones.where((item) {
      final conductor = item['conductor'].toString().toLowerCase();
      final licencia = item['licencia'].toString().toLowerCase();
      final ruta = item['ruta'].toString().toLowerCase();
      final query = textoBusqueda.toLowerCase().trim();

      final coincideBusqueda = query.isEmpty ||
          conductor.contains(query) ||
          licencia.contains(query) ||
          ruta.contains(query);

      final fecha = item['fecha'] as DateTime;
      final ahora = DateTime.now();

      bool coincideFiltro = true;

      if (filtroActual == 'semana') {
        coincideFiltro = ahora.difference(fecha).inDays <= 7;
      } else if (filtroActual == 'mes') {
        coincideFiltro = ahora.difference(fecha).inDays <= 30;
      }

      return coincideBusqueda && coincideFiltro;
    }).toList();

    lista.sort((a, b) {
      final fechaA = a['fecha'] as DateTime;
      final fechaB = b['fecha'] as DateTime;
      return fechaB.compareTo(fechaA);
    });

    return lista;
  }

  int get totalRegistros => historialFiltrado.length;

  int get totalActivas => historialFiltrado
      .where((item) => item['estado'].toString().toLowerCase() == 'activa')
      .length;

  int get totalMes => historialAsignaciones.where((item) {
        final fecha = item['fecha'] as DateTime;
        return DateTime.now().difference(fecha).inDays <= 30;
      }).length;

  String formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    return '$dia/$mes/$anio';
  }

  Color colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'activa':
        return colorRojoApp;
      case 'finalizada':
        return Colors.black54;
      case 'reasignada':
        return Colors.black45;
      case 'cancelada':
        return Colors.black38;
      default:
        return Colors.black45;
    }
  }

  void mostrarDetalle(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorBlanco,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              const Text(
                'Detalle de asignación',
                style: estiloTituloCard,
              ),
              const SizedBox(height: 16),
              _buildDatoDetalle('Conductor', item['conductor']),
              _buildDatoDetalle('Licencia', item['licencia']),
              _buildDatoDetalle('Ruta', item['ruta']),
              _buildDatoDetalle('Fecha', formatearFecha(item['fecha'])),
              _buildDatoDetalle('Estado', item['estado']),
            ],
          ),
        );
      },
    );
  }

  void limpiarHistorialVisual() {
    setState(() {
      textoBusqueda = '';
      filtroActual = 'todos';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: colorRojoApp,
        content: Text(
          'Filtros limpiados correctamente',
          style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
        ),
      ),
    );
  }

  void exportarHistorial() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: colorRojoApp,
        content: Text(
          'Función de exportación pendiente de conexión',
          style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = historialFiltrado;

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorRojoApp,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'HISTORIAL DE ASIGNACIONES',
          style: estiloTituloAppBar,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Text(
                'AU',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filtros', style: estiloTituloCard),
                    const SizedBox(height: 4),
                    const Text(
                      'Busca por conductor, ruta o licencia',
                      style: estiloSubtitulo,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          textoBusqueda = value;
                        });
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        color: colorTexto,
                        fontFamily: 'Roboto',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontFamily: 'Roboto',
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black54,
                        ),
                        filled: true,
                        fillColor: colorBlanco,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: colorRojoApp,
                            width: 1.2,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildFiltroChip(
                          texto: 'Todos',
                          valor: 'todos',
                        ),
                        _buildFiltroChip(
                          texto: 'Última semana',
                          valor: 'semana',
                        ),
                        _buildFiltroChip(
                          texto: 'Último mes',
                          valor: 'mes',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniResumen(
                      titulo: 'Total',
                      valor: '$totalRegistros',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMiniResumen(
                      titulo: 'Activas',
                      valor: '$totalActivas',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMiniResumen(
                      titulo: 'Este mes',
                      valor: '$totalMes',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: lista.isEmpty
                    ? _buildCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.history_toggle_off,
                              size: 42,
                              color: Colors.black54,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No hay asignaciones para mostrar',
                              style: estiloTituloCard,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Prueba con otro filtro o búsqueda',
                              style: estiloTextoNormal,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: lista.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = lista[index];

                          return _buildCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: colorFondo,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: colorRojoApp,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['conductor'],
                                        style: estiloTituloCard.copyWith(
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['ruta'],
                                        style: estiloSubtitulo,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Licencia: ${item['licencia']}',
                                        style: estiloTextoNormal,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Fecha: ${formatearFecha(item['fecha'])}',
                                        style: estiloTextoNormal,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          _buildBadgeEstado(item['estado']),
                                          const SizedBox(width: 10),
                                          TextButton(
                                            onPressed: () {
                                              mostrarDetalle(item);
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: colorRojoApp,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 6,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                side: const BorderSide(
                                                  color: Colors.black12,
                                                ),
                                              ),
                                            ),
                                            child: const Text(
                                              'Ver detalle',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: exportarHistorial,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorRojoApp,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.file_download_outlined),
                        label: const Text(
                          'Exportar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: limpiarHistorialVisual,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorTexto,
                          backgroundColor: colorBlanco,
                          side: const BorderSide(color: Colors.black12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.cleaning_services_outlined),
                        label: const Text(
                          'Limpiar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Roboto',
                          ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          // Aquí conectas tus pantallas reales:
          // 0 -> Admin
          // 1 -> Vehículos / Rutas
          // 2 -> Paradas
          // 3 -> Conductores
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorRojoApp,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          fontFamily: 'Roboto',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          fontFamily: 'Roboto',
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            label: 'Admin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alt_route),
            label: 'Vehículos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'Paradas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus_outlined),
            label: 'Conductores',
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
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

  Widget _buildMiniResumen({
    required String titulo,
    required String valor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: colorBlanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            titulo,
            style: estiloSubtitulo,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: colorTexto,
              fontFamily: 'Roboto',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroChip({
    required String texto,
    required String valor,
  }) {
    final bool activo = filtroActual == valor;

    return InkWell(
      onTap: () {
        setState(() {
          filtroActual = valor;
        });
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: activo ? colorRojoApp : colorBlanco,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: activo ? colorRojoApp : Colors.black12,
          ),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: activo ? Colors.white : colorTexto,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeEstado(String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorEstado(estado),
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

  Widget _buildDatoDetalle(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: colorTexto,
                fontFamily: 'Roboto',
              ),
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
}
