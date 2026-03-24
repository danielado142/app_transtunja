import 'package:flutter/material.dart';

import 'package:app_transtunja/screens/administrador/editar_ruta.dart';
import 'package:app_transtunja/screens/administrador/ver_ruta.dart';
import 'package:app_transtunja/services/ruta_service.dart';

enum HistorialTab { todas, activas, eliminadas }

class HistorialRutas extends StatefulWidget {
  const HistorialRutas({
    super.key,
    this.apiBaseUrl = 'http://10.0.2.2/app_transtunja/services',
  });

  final String apiBaseUrl;

  @override
  State<HistorialRutas> createState() => _HistorialRutasState();
}

class _HistorialRutasState extends State<HistorialRutas> {
  static const Color _primaryRed = Color(0xFFD10000);
  static const Color _background = Color(0xFFF6F6F7);
  static const Color _cardColor = Colors.white;

  late final RutaService _rutaService;
  final TextEditingController _searchCtrl = TextEditingController();

  bool _isLoading = true;
  String? _busyRouteId;
  List<RouteListItem> _routes = [];

  @override
  void initState() {
    super.initState();
    _rutaService = RutaService(baseUrl: widget.apiBaseUrl);
    _loadRoutes();

    _searchCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRoutes({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final routes = await _rutaService.fetchRoutes();

      if (!mounted) return;

      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cargando historial: $e'),
          backgroundColor: _primaryRed,
        ),
      );
    }
  }

  List<RouteListItem> _getRoutesByTab(HistorialTab tab) {
    final query = _searchCtrl.text.trim().toLowerCase();

    Iterable<RouteListItem> items = _routes;

    switch (tab) {
      case HistorialTab.todas:
        break;
      case HistorialTab.activas:
        items = items.where((r) => r.habilitada);
        break;
      case HistorialTab.eliminadas:
        items = items.where((r) => !r.habilitada);
        break;
    }

    if (query.isNotEmpty) {
      items = items.where((route) {
        return route.routeId.toLowerCase().contains(query) ||
            route.nombre.toLowerCase().contains(query) ||
            route.destino.toLowerCase().contains(query);
      });
    }

    return items.toList();
  }

  Future<void> _toggleStatus(RouteListItem route) async {
    setState(() {
      _busyRouteId = route.routeId;
    });

    try {
      final response = await _rutaService.toggleRouteStatus(
        routeId: route.routeId,
        enabled: !route.habilitada,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ??
                (route.habilitada
                    ? 'Ruta deshabilitada correctamente'
                    : 'Ruta habilitada correctamente'),
          ),
          backgroundColor: Colors.black87,
        ),
      );

      await _loadRoutes(showLoader: false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cambiar el estado: $e'),
          backgroundColor: _primaryRed,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _busyRouteId = null;
      });
    }
  }

  Future<void> _openEdit(RouteListItem route) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditarRuta(routeId: route.routeId)),
    );

    if (result == true) {
      await _loadRoutes(showLoader: false);
    }
  }

  void _openView(RouteListItem route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerRuta(coordenadas: route.coordenadas),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Buscar por ID, nombre o destino',
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.54),
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: _primaryRed),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool habilitada) {
    final Color bg = habilitada
        ? const Color(0xFF5FBF2A)
        : const Color(0xFFE74C3C);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        habilitada ? 'Activa' : 'Eliminada',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required IconData icon,
    Color foregroundColor = Colors.white,
  }) {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(RouteListItem route) {
    final bool isBusy = _busyRouteId == route.routeId;
    final String nombre = route.nombre.trim().isEmpty
        ? 'Ruta sin nombre'
        : route.nombre.trim();
    final String destino = route.destino.trim().isEmpty
        ? 'Sin destino'
        : route.destino.trim();
    final String fecha = route.fecha?.trim().isNotEmpty == true
        ? route.fecha!.trim()
        : 'Sin fecha';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
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
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
              _buildStatusBadge(route.habilitada),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            route.habilitada ? 'Creada: $fecha' : 'Eliminada: $fecha',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black.withOpacity(0.54),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ID: ${route.routeId}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.54),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Destino: $destino',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.54),
            ),
          ),
          if (!route.habilitada) ...[
            const SizedBox(height: 14),
            Text(
              'Ruta eliminada por el administrador.',
              style: TextStyle(
                fontSize: 14,
                color: _primaryRed.withOpacity(0.85),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  text: 'Ver',
                  onPressed: () => _openView(route),
                  backgroundColor: Colors.blue,
                  icon: Icons.visibility_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  text: 'Editar',
                  onPressed: () => _openEdit(route),
                  backgroundColor: Colors.black87,
                  icon: Icons.edit_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isBusy ? null : () => _toggleStatus(route),
              icon: isBusy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      route.habilitada
                          ? Icons.block_outlined
                          : Icons.check_circle_outline,
                    ),
              label: Text(
                route.habilitada ? 'Deshabilitar ruta' : 'Habilitar ruta',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryRed,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _primaryRed.withOpacity(0.7),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return RefreshIndicator(
      onRefresh: _loadRoutes,
      color: _primaryRed,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.alt_route, size: 56, color: Colors.black26),
          const SizedBox(height: 14),
          Center(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(HistorialTab tab) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primaryRed));
    }

    final routes = _getRoutesByTab(tab);

    if (routes.isEmpty) {
      switch (tab) {
        case HistorialTab.todas:
          return _buildEmptyState('No hay rutas registradas.');
        case HistorialTab.activas:
          return _buildEmptyState('No hay rutas activas.');
        case HistorialTab.eliminadas:
          return _buildEmptyState('No hay rutas eliminadas.');
      }
    }

    return RefreshIndicator(
      onRefresh: _loadRoutes,
      color: _primaryRed,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: routes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, index) => _buildCard(routes[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _primaryRed,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'HISTORIAL DE RUTAS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blueGrey,
                child: Text(
                  'AU',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(78),
            child: Container(
              width: double.infinity,
              color: _primaryRed,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black12),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: _primaryRed.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                  tabs: const [
                    Tab(text: 'Todas'),
                    Tab(text: 'Activas'),
                    Tab(text: 'Eliminadas'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(
            children: [
              _buildSearch(),
              const SizedBox(height: 14),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTabContent(HistorialTab.todas),
                    _buildTabContent(HistorialTab.activas),
                    _buildTabContent(HistorialTab.eliminadas),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
