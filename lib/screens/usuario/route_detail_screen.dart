import 'package:flutter/material.dart';

class RouteDetailScreen extends StatelessWidget {
  final String routeName;
  final String stopName;
  final String etaText;

  const RouteDetailScreen({
    super.key,
    required this.routeName,
    required this.stopName,
    required this.etaText,
  });

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFD10000);

    // Datos fake (luego backend)
    final stops = <_Stop>[
      const _Stop(
        name: "Centro",
        info: "Punto de inicio",
        state: _StopState.start,
      ),
      _Stop(name: stopName, info: "Parada cercana", state: _StopState.current),
      const _Stop(
        name: "Parque Santander",
        info: "Intermedia",
        state: _StopState.middle,
      ),
      const _Stop(name: "UPTC", info: "Destino final", state: _StopState.end),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("Detalle de ruta"), centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            // Header card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(14),
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
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.directions_bus, color: red),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routeName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Próximo bus: $etaText",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Parada actual: $stopName",
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: red,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        "ACTIVA",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Timeline title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recorrido",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Timeline list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: stops.length,
                itemBuilder: (context, index) {
                  final s = stops[index];
                  final isFirst = index == 0;
                  final isLast = index == stops.length - 1;
                  return _TimelineTile(
                    stop: s,
                    red: red,
                    isFirst: isFirst,
                    isLast: isLast,
                  );
                },
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // placeholder
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Más adelante lo conectamos al mapa 😉"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text("Ver en mapa"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------- Timeline UI -------------------- */

enum _StopState { start, current, middle, end }

class _Stop {
  final String name;
  final String info;
  final _StopState state;

  const _Stop({required this.name, required this.info, required this.state});
}

class _TimelineTile extends StatelessWidget {
  final _Stop stop;
  final Color red;
  final bool isFirst;
  final bool isLast;

  const _TimelineTile({
    required this.stop,
    required this.red,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = stop.state == _StopState.current ? red : Colors.black26;
    final dotFill = stop.state == _StopState.current ? red : Colors.white;
    final titleWeight = stop.state == _StopState.current
        ? FontWeight.w900
        : FontWeight.w700;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline column
        SizedBox(
          width: 34,
          child: Column(
            children: [
              // line top
              Container(
                height: 10,
                width: 2,
                color: isFirst ? Colors.transparent : Colors.black12,
              ),
              // dot
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: dotFill,
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
              ),
              // line bottom
              Container(
                height: 54,
                width: 2,
                color: isLast ? Colors.transparent : Colors.black12,
              ),
            ],
          ),
        ),

        // Card
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: stop.state == _StopState.current
                    ? red.withOpacity(0.25)
                    : Colors.black12,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  stop.state == _StopState.end
                      ? Icons.flag_outlined
                      : Icons.place_outlined,
                  color: stop.state == _StopState.current
                      ? red
                      : Colors.black54,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.name,
                        style: TextStyle(fontSize: 15, fontWeight: titleWeight),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        stop.info,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                if (stop.state == _StopState.current)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      "AHORA",
                      style: TextStyle(color: red, fontWeight: FontWeight.w900),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}