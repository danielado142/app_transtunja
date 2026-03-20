import 'package:flutter/material.dart';

import 'package:app_transtunja/screens/administrador/editar_ruta.dart';
import 'package:app_transtunja/screens/administrador/ver_ruta.dart';
import 'package:app_transtunja/services/ruta_service.dart';

class HistorialRutas extends StatefulWidget {
  // Ajustado para que el valor por defecto funcione correctamente en el constructor
  const HistorialRutas({super.key, this.apiBaseUrl = '/transtunja'});

  final String apiBaseUrl;

  @override
  State<HistorialRutas> createState() => _HistorialRutasState();
}

class _HistorialRutasState extends State<HistorialRutas> {
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
      setState(() {});
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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<RouteListItem> get _filteredRoutes {
    final query = _searchCtrl.text.trim().toLowerCase();

    if (query.isEmpty) return _routes;

    return _routes.where((route) {
      return route.routeId.toLowerCase().contains(query) ||
          route.nombre.toLowerCase().contains(query) ||
          route.destino.toLowerCase().contains(query);
    }).toList();
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
                (!route.habilitada
                    ? 'Ruta habilitada correctamente'
                    : 'Ruta deshabilitada correctamente'),
          ),
        ),
      );

      await _loadRoutes(showLoader: false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cambiar el estado: $e'),
          backgroundColor: Colors.red,
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
    return TextField(
      controller: _searchCtrl,
      decoration: const InputDecoration(
        labelText: 'Buscar por ID, nombre o destino',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCard(RouteListItem route) {
    final isBusy = _busyRouteId == route.routeId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      route.nombre.isEmpty ? 'Sin nombre' : route.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${route.destino.isEmpty ? 'Sin destino' : route.destino}\nID: ${route.routeId}',
                    ),
                    isThreeLine: true,
                  ),
                ),
                Chip(label: Text(route.habilitada ? 'Activa' : 'Inactiva')),
              ],
            ),
            if (route.fecha != null && route.fecha!.trim().isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fecha: ${route.fecha}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openView(route),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Ver'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openEdit(route),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isBusy ? null : () => _toggleStatus(route),
                style: ElevatedButton.styleFrom(
                  backgroundColor: route.habilitada
                      ? Colors.orange
                      : Colors.green,
                  foregroundColor: Colors.white,
                ),
                icon: isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(route.habilitada ? Icons.block : Icons.check_circle),
                label: Text(route.habilitada ? 'Deshabilitar' : 'Habilitar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final routes = _filteredRoutes;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (routes.isEmpty) {
      return const Center(child: Text('No hay rutas disponibles.'));
    }

    return RefreshIndicator(
      onRefresh: _loadRoutes,
      child: ListView.separated(
        itemCount: routes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) => _buildCard(routes[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de rutas')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildSearch(),
            const SizedBox(height: 12),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }
}
