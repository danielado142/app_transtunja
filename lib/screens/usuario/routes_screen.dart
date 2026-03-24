import 'package:flutter/material.dart';

import '../../models/route_model.dart';
import '../../services/route_service.dart';
import 'route_detail_screen.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  static const red = Color(0xFFD10000);

  final RouteService _routeService = RouteService();
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _filters = const [
    "Todas",
    "Centro",
    "UPTC",
    "Terminal",
    "Unicentro",
  ];

  List<RouteModel> _routes = [];
  String _selectedFilter = "Todas";
  String _query = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final routes = await _routeService.getRoutes();

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
          content: Text("Error al cargar rutas: $e"),
        ),
      );
    }
  }

  List<RouteModel> get _filteredRoutes {
    final list = _selectedFilter == "Todas"
        ? _routes
        : _routes.where((r) => r.tag == _selectedFilter).toList();

    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return list;

    return list.where((r) {
      return r.name.toLowerCase().contains(q) ||
          r.stop.toLowerCase().contains(q) ||
          r.tag.toLowerCase().contains(q) ||
          r.extra.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRoutes;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      appBar: AppBar(
        backgroundColor: red,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Rutas",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _loadRoutes,
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Encuentra tu ruta y revisa sus detalles.",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 10,
                                    color: Colors.black12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (v) => setState(() => _query = v),
                                decoration: InputDecoration(
                                  hintText: "Buscar ruta o parada...",
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: _query.isEmpty
                                      ? null
                                      : IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            _searchCtrl.clear();
                                            setState(() => _query = "");
                                          },
                                        ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 54,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, i) {
                            final f = _filters[i];
                            final selected = f == _selectedFilter;

                            return Center(
                              child: ChoiceChip(
                                label: Text(
                                  f,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: selected ? red : Colors.black87,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                selected: selected,
                                onSelected: (_) =>
                                    setState(() => _selectedFilter = f),
                                selectedColor: red.withOpacity(0.12),
                                backgroundColor: Colors.white,
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: selected ? red : Colors.black26,
                                  ),
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                showCheckmark: true,
                                checkmarkColor: red,
                              ),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemCount: _filters.length,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                        child: Text(
                          "Resultados: ${filtered.length}",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (filtered.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyRoutesState(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final route = filtered[index];
                              return _RouteCard(route: route);
                            },
                            childCount: filtered.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  static const red = Color(0xFFD10000);

  final RouteModel route;

  const _RouteCard({
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final parts = route.name.split(' - ');
    final origin = parts.isNotEmpty ? parts.first : route.name;
    final destination = parts.length > 1 ? parts.last : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.directions_bus, color: red),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      destination.isEmpty ? origin : '$origin  →  $destination',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  route.eta,
                  style: const TextStyle(
                    color: red,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniBadge(
                icon: Icons.check_circle_outline,
                text: route.status,
                color: red,
              ),
              if (route.extra.isNotEmpty)
                _MiniBadge(
                  icon: Icons.info_outline,
                  text: route.extra,
                  color: Colors.black87,
                  light: true,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Próxima parada: ${route.stop}",
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RouteDetailScreen(
                      routeName: route.name,
                      stopName: route.stop,
                      etaText: route.eta,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Ver detalles",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool light;

  const _MiniBadge({
    required this.icon,
    required this.text,
    required this.color,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = light ? Colors.black.withOpacity(0.05) : color.withOpacity(0.10);
    final fg = light ? Colors.black87 : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRoutesState extends StatelessWidget {
  const _EmptyRoutesState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.alt_route, size: 46, color: Colors.black38),
            SizedBox(height: 12),
            Text(
              'No encontramos rutas',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            SizedBox(height: 6),
            Text(
              'Prueba con otra palabra o cambia el filtro para ver más resultados.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
