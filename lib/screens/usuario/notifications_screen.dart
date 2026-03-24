import 'package:flutter/material.dart';

import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const red = Color(0xFFD10000);

  final NotificationService _notificationService = NotificationService();

  bool _onlyImportant = false;
  bool _isLoading = true;
  List<NotificationModel> _all = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await _notificationService.getNotifications();

      if (!mounted) return;

      setState(() {
        _all = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar notificaciones: $e')),
      );
    }
  }

  List<NotificationModel> get _filtered {
    if (!_onlyImportant) return _all;
    return _all.where((notification) => notification.important).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      appBar: AppBar(
        backgroundColor: red,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Notificaciones",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Consulta avisos, alertas y novedades importantes.",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
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
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: red.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none,
                                    color: red,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Solo importantes",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        "Muestra únicamente alertas prioritarias.",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _onlyImportant,
                                  activeColor: red,
                                  onChanged: (value) {
                                    setState(() {
                                      _onlyImportant = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            "Resultados: ${list.length}",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    Expanded(
                      child: list.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 120),
                                _EmptyState(),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                return _NotifCard(notif: list[index]);
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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

class _NotifCard extends StatelessWidget {
  static const red = Color(0xFFD10000);

  final NotificationModel notif;

  const _NotifCard({required this.notif});

  @override
  Widget build(BuildContext context) {
    final icon = switch (notif.type) {
      NotificationType.info => Icons.info_outline,
      NotificationType.warning => Icons.warning_amber_outlined,
      NotificationType.important => Icons.report_gmailerrorred_outlined,
    };

    final badgeText = switch (notif.type) {
      NotificationType.info => "INFO",
      NotificationType.warning => "ALERTA",
      NotificationType.important => "IMPORTANTE",
    };

    final badgeColor = switch (notif.type) {
      NotificationType.info => Colors.black87,
      NotificationType.warning => red,
      NotificationType.important => red,
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
              color: (notif.type == NotificationType.warning ||
                      notif.type == NotificationType.important)
                  ? red.withOpacity(0.12)
                  : Colors.black12,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: (notif.type == NotificationType.warning ||
                      notif.type == NotificationType.important)
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
