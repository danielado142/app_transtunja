import 'package:flutter/material.dart';

class HistorialPQRS extends StatefulWidget {
  const HistorialPQRS({super.key});

  @override
  State<HistorialPQRS> createState() => _HistorialPQRSState();
}

class _HistorialPQRSState extends State<HistorialPQRS> {
  // =========================
  // COLORES SEGÚN TUS NORMAS
  // =========================
  static const Color colorRojoApp = Color(0xFFD10000);
  static const Color colorFondo = Color(0xFFF6F6F7);
  static const Color colorBlanco = Color(0xFFFFFFFF);
  static const Color colorTexto = Color(0xFF000000);

  // =========================
  // TIPOGRAFÍA SEGÚN TUS NORMAS
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
  final List<Map<String, dynamic>> pqrs = [
    {
      'usuario': 'Juan Pérez',
      'tipo': 'Queja',
      'descripcion': 'Retraso frecuente en la ruta principal.',
      'fecha': DateTime(2024, 5, 22),
      'estado': 'Pendiente',
    },
    {
      'usuario': 'Ana Gepota',
      'tipo': 'Reporte',
      'descripcion': 'Mal estado de un vehículo en servicio.',
      'fecha': DateTime(2024, 5, 15),
      'estado': 'En revisión',
    },
    {
      'usuario': 'Ana García',
      'tipo': 'Queja',
      'descripcion': 'El conductor no realizó la parada solicitada.',
      'fecha': DateTime(2024, 5, 14),
      'estado': 'Pendiente',
    },
    {
      'usuario': 'Luis Ramírez',
      'tipo': 'Reporte',
      'descripcion': 'Paradero sin señalización visible.',
      'fecha': DateTime.now().subtract(const Duration(days: 3)),
      'estado': 'Resuelto',
    },
  ];

  String textoBusqueda = '';
  String filtroActual = 'todos';
  int currentIndex = 3;

  List<Map<String, dynamic>> get pqrsFiltradas {
    List<Map<String, dynamic>> lista = pqrs.where((item) {
      final usuario = item['usuario'].toString().toLowerCase();
      final tipo = item['tipo'].toString().toLowerCase();
      final descripcion = item['descripcion'].toString().toLowerCase();
      final query = textoBusqueda.toLowerCase().trim();

      final coincideBusqueda = query.isEmpty ||
          usuario.contains(query) ||
          tipo.contains(query) ||
          descripcion.contains(query);

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

  String formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    return '$anio-$mes-$dia';
  }

  Color colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return colorRojoApp;
      case 'en revisión':
        return Colors.black54;
      case 'resuelto':
        return Colors.black45;
      default:
        return Colors.black45;
    }
  }

  IconData iconoTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'queja':
        return Icons.report_problem_outlined;
      case 'reporte':
        return Icons.description_outlined;
      default:
        return Icons.info_outline;
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
                'Detalle PQRS',
                style: estiloTituloCard,
              ),
              const SizedBox(height: 16),
              _buildDatoDetalle('Usuario', item['usuario']),
              _buildDatoDetalle('Tipo', item['tipo']),
              _buildDatoDetalle('Fecha', formatearFecha(item['fecha'])),
              _buildDatoDetalle('Estado', item['estado']),
              _buildDatoDetalle('Descripción', item['descripcion']),
            ],
          ),
        );
      },
    );
  }

  void limpiarHistorial() {
    setState(() {
      textoBusqueda = '';
      filtroActual = 'todos';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: colorRojoApp,
        content: Text(
          'Filtros limpiados correctamente',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = pqrsFiltradas;

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorRojoApp,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'HISTORIAL PQRS',
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
                      'Busca por usuario, tipo o descripción',
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
              Expanded(
                child: lista.isEmpty
                    ? _buildCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.inbox_outlined,
                              size: 42,
                              color: Colors.black54,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'No hay reportes o quejas para mostrar',
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
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: colorRojoApp.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black12,
                                    ),
                                  ),
                                  child: Icon(
                                    iconoTipo(item['tipo']),
                                    color: colorRojoApp,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['usuario'],
                                        style: estiloTituloCard.copyWith(
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['tipo'],
                                        style: estiloSubtitulo,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item['descripcion'],
                                        style: estiloTextoNormal,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: limpiarHistorial,
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
                    'Limpiar historial',
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
