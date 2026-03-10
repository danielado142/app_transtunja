import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const red = Color(0xFFD10000);

  bool _onlyImportant = false;

  final List<_Notif> _all = const [
    _Notif(
      title: "Retraso en ruta Centro - UPTC",
      body: "Se reporta congestión. Tiempo estimado +6 min.",
      time: "Hace 5 min",
      type: _NotifType.warning,
      important: true,
    ),
    _Notif(
      title: "Nueva parada habilitada",
      body: "Se agregó la parada “Avenida Norte” para rutas hacia Unicentro.",
      time: "Hoy",
      type: _NotifType.info,
      important: false,
    ),
    _Notif(
      title: "Mantenimiento programado",
      body: "Algunas rutas tendrán cambios temporales el fin de semana.",
      time: "Ayer",
      type: _NotifType.important,
      important: true,
    ),
    _Notif(
      title: "Recordatorio",
      body: "Califica tu último viaje para mejorar el servicio.",
      time: "Ayer",
      type: _NotifType.info,
      important: false,
    ),
  ];

  List<_Notif> get _filtered {
    if (!_onlyImportant) return _all;
    return _all.where((n) => n.important).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            const Text(
              "Notificaciones",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    Icon(Icons.notifications_none, color: red.withOpacity(0.9)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Solo importantes",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Switch(
                      value: _onlyImportant,
                      activeColor: red,
                      onChanged: (v) => setState(() => _onlyImportant = v),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: list.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: list.length,
                      itemBuilder: (context, i) => _NotifCard(notif: list[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: Colors.black38,
            ),
            SizedBox(height: 10),
            Text(
              "No hay notificaciones por ahora",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            SizedBox(height: 6),
            Text(
              "Cuando haya novedades de rutas o avisos importantes, aparecerán aquí.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

enum _NotifType { info, warning, important }

class _Notif {
  final String title;
  final String body;
  final String time;
  final _NotifType type;
  final bool important;

  const _Notif({
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.important,
  });
}

class _NotifCard extends StatelessWidget {
  static const red = Color(0xFFD10000);

  final _Notif notif;

  const _NotifCard({required this.notif});

  @override
  Widget build(BuildContext context) {
    final icon = switch (notif.type) {
      _NotifType.info => Icons.info_outline,
      _NotifType.warning => Icons.warning_amber_outlined,
      _NotifType.important => Icons.report_gmailerrorred_outlined,
    };

    final badgeText = switch (notif.type) {
      _NotifType.info => "INFO",
      _NotifType.warning => "ALERTA",
      _NotifType.important => "IMPORTANTE",
    };

    final badgeColor = switch (notif.type) {
      _NotifType.info => Colors.black87,
      _NotifType.warning => red,
      _NotifType.important => red,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        border: Border.all(
          color: notif.important ? red.withOpacity(0.25) : Colors.black12,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  (notif.type == _NotifType.warning ||
                      notif.type == _NotifType.important)
                  ? red.withOpacity(0.12)
                  : Colors.black12,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color:
                  (notif.type == _NotifType.warning ||
                      notif.type == _NotifType.important)
                  ? red
                  : Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(notif.body, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 10),
                Text(
                  notif.time,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
