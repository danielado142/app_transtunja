import 'package:flutter/material.dart';

// Importaciones de tus pantallas y servicios
import 'package:app_transtunja/screens/administrador/admin_dashboard.dart';
import 'package:app_transtunja/screens/administrador/editar_ruta.dart';
import 'package:app_transtunja/screens/administrador/gestion_conductores.dart';
import 'package:app_transtunja/screens/administrador/gestion_paradas.dart';
import 'package:app_transtunja/screens/administrador/ver_ruta.dart';
import 'package:app_transtunja/services/ruta_service.dart';

enum HistorialTab { todas, activas, eliminadas }

class HistorialRutas extends StatefulWidget {
  const HistorialRutas({super.key});

  @override
  State<HistorialRutas> createState() => _HistorialRutasState();
}

class _HistorialRutasState extends State<HistorialRutas> {
  static const Color _primaryRed = Color(0xFFD10000);
  static const Color _background = Color(0xFFF6F6F7);
  static const Color _cardColor = Colors.white;

  // Instancia del servicio con la URL de Hostinger integrada internamente
  final RutaService _rutaService = RutaService();
  final TextEditingController _searchCtrl = TextEditingController();

  bool _isLoading = true;
  String? _busyRouteId; // Para mostrar loader en un item específico
  List<RouteListItem> _routes = [];

  final int _currentBottomIndex = 1;

  @override
  void initState() {
    super.initState();
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

  // Carga de datos desde Hostinger
  Future<void> _loadRoutes({bool showLoader = true}) async {
    if (showLoader) {
      setState(() => _isLoading = true);
    }

    try {
      final routes = await _rutaService.obtenerHistorialRutas();

      if (!mounted) return;

      setState(() {
        _routes = routes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Error cargando historial: $e', isError: true);
    }
  }

  // Lógica para cambiar estado Activo/Inactivo (Switch)
  Future<void> _toggleStatus(RouteListItem route) async {
    setState(() => _busyRouteId = route.routeId);

    try {
      // Llamada al PHP de Hostinger
      final response = await _rutaService.toggleRouteStatus(
        routeId: route.routeId,
        habilitar: !route.habilitada,
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        _showSnackBar(
            route.habilitada ? 'Ruta deshabilitada' : 'Ruta habilitada');
        await _loadRoutes(showLoader: false); // Recargar lista silenciosamente
      } else {
        _showSnackBar('Error: ${response['message']}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error de conexión', isError: true);
    } finally {
      if (mounted) setState(() => _busyRouteId = null);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _primaryRed : Colors.black87,
      ),
    );
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
      items = items.where((route) =>
          route.routeId.toLowerCase().contains(query) ||
          route.nombre.toLowerCase().contains(query) ||
          route.destino.toLowerCase().contains(query));
    }
    return items.toList();
  }

  // --- WIDGETS DE APOYO ---

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
          prefixIcon: const Icon(Icons.search, color: _primaryRed),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCard(RouteListItem route) {
    final bool isBusy = _busyRouteId == route.routeId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus, color: _primaryRed, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  route.nombre.isEmpty ? 'Ruta ${route.routeId}' : route.nombre,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              // El Switch conectado a la base de datos
              isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Switch(
                      value: route.habilitada,
                      activeColor: Colors.green,
                      onChanged: (val) => _toggleStatus(route),
                    ),
            ],
          ),
          const SizedBox(height: 8),
          Text('ID: ${route.routeId}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text('Destino: ${route.destino}',
              style: TextStyle(color: Colors.black54, fontSize: 13)),
          if (route.fecha != null)
            Text('Fecha: ${route.fecha}',
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => VerRuta(
                              coordenadas: ''))), // Aquí pasas tus coordenadas
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('VER'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => EditarRuta(routeId: route.routeId))),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('EDITAR'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ],
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
          title: const Text('HISTORIAL DE RUTAS',
              style: TextStyle(fontWeight: FontWeight.w800)),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Todas'),
              Tab(text: 'Activas'),
              Tab(text: 'Eliminadas')
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSearch(),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _primaryRed))
                    : TabBarView(
                        children: [
                          _buildList(HistorialTab.todas),
                          _buildList(HistorialTab.activas),
                          _buildList(HistorialTab.eliminadas),
                        ],
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildList(HistorialTab tab) {
    final filtered = _getRoutesByTab(tab);
    if (filtered.isEmpty)
      return const Center(child: Text('No se encontraron rutas'));

    return RefreshIndicator(
      onRefresh: _loadRoutes,
      child: ListView.separated(
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildCard(filtered[i]),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentBottomIndex,
      onTap: (i) => _onBottomTap(i), // Usa tu función existente para navegar
      type: BottomNavigationBarType.fixed,
      backgroundColor: _primaryRed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Admin'),
        BottomNavigationBarItem(icon: Icon(Icons.alt_route), label: 'Rutas'),
        BottomNavigationBarItem(
            icon: Icon(Icons.location_on), label: 'Paradas'),
        BottomNavigationBarItem(
            icon: Icon(Icons.drive_eta), label: 'Conductores'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }

  void _onBottomTap(int index) {
    // Tu lógica de navegación actual...
  }
}
