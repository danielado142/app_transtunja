import 'package:flutter/material.dart';
import 'route_detail_screen.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  static const red = Color(0xFFD10000);

  final List<Map<String, String>> _routes = const [
    {
      "name": "Centro - UPTC",
      "eta": "4 min",
      "stop": "Plaza Real",
      "tag": "UPTC",
    },
    {
      "name": "Terminal - Centro",
      "eta": "7 min",
      "stop": "Parque Santander",
      "tag": "Terminal",
    },
    {
      "name": "Unicentro - Hospital",
      "eta": "10 min",
      "stop": "Avenida Norte",
      "tag": "Unicentro",
    },
    {
      "name": "Centro - Unicentro",
      "eta": "6 min",
      "stop": "Centro",
      "tag": "Centro",
    },
    {"name": "UPTC - Terminal", "eta": "9 min", "stop": "UPTC", "tag": "UPTC"},
    {
      "name": "Centro - Terminal",
      "eta": "8 min",
      "stop": "Plaza de Bolívar",
      "tag": "Centro",
    },
    {
      "name": "Unicentro - Centro",
      "eta": "5 min",
      "stop": "Unicentro",
      "tag": "Unicentro",
    },
  ];

  final List<String> _filters = const [
    "Todas",
    "Centro",
    "UPTC",
    "Terminal",
    "Unicentro",
  ];
  String _selectedFilter = "Todas";

  final TextEditingController _searchCtrl = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredRoutes {
    // 1) filtro por chip
    var list = _selectedFilter == "Todas"
        ? _routes
        : _routes.where((r) => r["tag"] == _selectedFilter).toList();

    // 2) filtro por texto
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return list;

    return list.where((r) {
      final name = (r["name"] ?? "").toLowerCase();
      final stop = (r["stop"] ?? "").toLowerCase();
      final tag = (r["tag"] ?? "").toLowerCase();
      return name.contains(q) || stop.contains(q) || tag.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRoutes;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  children: [
                    const Text(
                      "Rutas disponibles",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ Buscador
                    Material(
                      elevation: 1,
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
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
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ CHIPS (sin recorte)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SizedBox(
                  height: 52,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      final f = _filters[i];
                      final selected = f == _selectedFilter;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ChoiceChip(
                          label: Text(f, style: const TextStyle(fontSize: 13)),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedFilter = f),
                          selectedColor: red.withOpacity(0.15),
                          labelStyle: TextStyle(
                            color: selected ? red : Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: selected ? red : Colors.black26,
                            ),
                          ),
                          backgroundColor: Colors.white,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: _filters.length,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ✅ Resultados
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Resultados: ${filtered.length}",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            if (filtered.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    "No encontramos rutas con esos filtros",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final route = filtered[index];
                    return _RouteCard(
                      routeName: route["name"]!,
                      eta: route["eta"]!,
                      stopName: route["stop"]!,
                    );
                  }, childCount: filtered.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  static const red = Color(0xFFD10000);

  final String routeName;
  final String eta;
  final String stopName;

  const _RouteCard({
    required this.routeName,
    required this.eta,
    required this.stopName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_bus),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  routeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  eta,
                  style: const TextStyle(
                    color: red,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Próxima parada: $stopName",
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RouteDetailScreen(
                      routeName: routeName,
                      stopName: stopName,
                      etaText: eta,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text("Ver detalles"),
            ),
          ),
        ],
      ),
    );
  }
}
