import 'package:flutter/material.dart';

import '../../models/route_detail_model.dart';
import '../../models/route_stop_model.dart';

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

    final detail = RouteDetailModel.fromBasicData(
      routeName: routeName,
      stopName: stopName,
      etaText: etaText,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Detalle de ruta",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Container(
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: red.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.directions_bus, color: red),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.routeName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            detail.destination.isEmpty
                                ? detail.origin
                                : '${detail.origin}  →  ${detail.destination}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoPill(
                                icon: Icons.schedule,
                                text: 'Próximo bus: ${detail.etaText}',
                                color: red,
                              ),
                              _InfoPill(
                                icon: Icons.place_outlined,
                                text: 'Parada actual: ${detail.stopName}',
                                color: Colors.black87,
                                light: true,
                              ),
                              _InfoPill(
                                icon: Icons.alt_route,
                                text:
                                    '${detail.stops.length} puntos en la ruta',
                                color: Colors.black87,
                                light: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: red,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        "ACTIVA",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recorrido",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: detail.stops.length,
                itemBuilder: (context, index) {
                  final stop = detail.stops[index];
                  final isFirst = index == 0;
                  final isLast = index == detail.stops.length - 1;

                  return _TimelineTile(
                    stop: stop,
                    red: red,
                    isFirst: isFirst,
                    isLast: isLast,
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Más adelante lo conectamos al mapa"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text(
                    "Ver en mapa",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool light;

  const _InfoPill({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

class _TimelineTile extends StatelessWidget {
  final RouteStopModel stop;
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
    final isCurrent = stop.state == RouteStopState.current;
    final isStart = stop.state == RouteStopState.start;
    final isEnd = stop.state == RouteStopState.end;

    final dotColor = isCurrent ? red : Colors.black26;
    final titleWeight = isCurrent ? FontWeight.w900 : FontWeight.w700;

    IconData icon;
    if (isEnd) {
      icon = Icons.flag_outlined;
    } else if (isStart) {
      icon = Icons.place_outlined;
    } else {
      icon = Icons.location_on_outlined;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34,
          child: Column(
            children: [
              Container(
                height: 12,
                width: 2,
                color: isFirst ? Colors.transparent : Colors.black12,
              ),
              Container(
                width: isCurrent ? 14 : 12,
                height: isCurrent ? 14 : 12,
                decoration: BoxDecoration(
                  color: isCurrent ? red : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
              ),
              Container(
                height: 64,
                width: 2,
                color: isLast ? Colors.transparent : Colors.black12,
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isCurrent ? red.withOpacity(0.30) : Colors.black12,
              ),
              boxShadow: isCurrent
                  ? const [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black12,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isCurrent ? red.withOpacity(0.10) : Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: isCurrent ? red : Colors.black54),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.name,
                        style: TextStyle(fontSize: 15, fontWeight: titleWeight),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stop.info,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: red.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      "AHORA",
                      style: TextStyle(
                        color: red,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
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
