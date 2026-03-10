import 'package:flutter/material.dart';
import 'route_detail_screen.dart';

class MapScreen extends StatelessWidget {
  final VoidCallback onGoToRoutes;

  const MapScreen({super.key, required this.onGoToRoutes});

  @override
  Widget build(BuildContext context) {
    // Datos fake (luego lo conectamos a backend)
    const stopName = 'Plaza Real';
    const etaText = '4 min';
    const routeName = 'Centro - UPTC';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // MAPA (placeholder)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey.shade300,
              child: const Center(
                child: Text(
                  'MAPA (placeholder)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            // Degradado suave arriba
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black26, Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),

            // BUSCADOR (tap -> bottom sheet)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _SearchBarButton(
                onTap: () => _openDestinationSheet(context),
              ),
            ),

            // CHIPS
            Positioned(
              top: 78,
              left: 16,
              right: 16,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _QuickChip(
                      icon: Icons.alt_route,
                      label: 'Rutas populares',
                      onTap: onGoToRoutes,
                    ),
                    const SizedBox(width: 10),
                    _QuickChip(
                      icon: Icons.place_outlined,
                      label: 'Paradas cercanas',
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    _QuickChip(
                      icon: Icons.star_border,
                      label: 'Favoritas',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            // BOTÓN MI UBICACIÓN
            Positioned(
              right: 16,
              bottom: 190,
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.white,
                elevation: 2,
                child: const Icon(Icons.my_location, color: Colors.black87),
              ),
            ),

            // TARJETA INFERIOR
            Positioned(
              left: 16,
              right: 16,
              bottom: 88,
              child: _BottomInfoCard(
                stopName: stopName,
                etaText: etaText,
                routeName: routeName,
                onGoToRoutes: onGoToRoutes,
                onDetails: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RouteDetailScreen(
                        routeName: routeName,
                        stopName: stopName,
                        etaText: etaText,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDestinationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DestinationSheet(onGoToRoutes: onGoToRoutes),
    );
  }
}

class _SearchBarButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBarButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.place_outlined),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '¿Hacia dónde vas?',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ),
              Icon(Icons.search),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomInfoCard extends StatelessWidget {
  final String stopName;
  final String etaText;
  final String routeName;
  final VoidCallback onGoToRoutes;
  final VoidCallback onDetails;

  const _BottomInfoCard({
    required this.stopName,
    required this.etaText,
    required this.routeName,
    required this.onGoToRoutes,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFD10000);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.directions_bus, size: 20),
              SizedBox(width: 8),
              Text(
                'Resumen',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Parada cercana',
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stopName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Próximo bus: $etaText • Ruta: $routeName',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),

          // ✅ Botones iguales (mismo estilo)
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onGoToRoutes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Rutas'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Detalles'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DestinationSheet extends StatefulWidget {
  final VoidCallback onGoToRoutes;
  const _DestinationSheet({required this.onGoToRoutes});

  @override
  State<_DestinationSheet> createState() => _DestinationSheetState();
}

class _DestinationSheetState extends State<_DestinationSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _selected = '';

  final List<String> _suggestions = const [
    'UPTC (Universidad Pedagógica y Tecnológica)',
    'Terminal de Transportes de Tunja',
    'Centro Comercial Unicentro',
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _canGo => _selected.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 14,
        bottom: 16 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 5,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.search),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu destino',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    _selected = value.trim();
                    setState(() {});
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  _controller.clear();
                  setState(() => _selected = '');
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sugerencias',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          ..._suggestions.map(
            (s) => _SuggestionTile(
              text: s,
              isSelected: _selected == s,
              onTap: () {
                setState(() {
                  _selected = s;
                  _controller.text = s;
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length),
                  );
                });
              },
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canGo
                  ? () {
                      Navigator.pop(context);
                      widget.onGoToRoutes();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Ver rutas'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black12 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            const Icon(Icons.place_outlined),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
