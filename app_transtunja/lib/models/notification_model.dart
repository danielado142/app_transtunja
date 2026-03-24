enum NotificationType { info, warning, important }

class NotificationModel {
  final String title;
  final String body;
  final String time;
  final NotificationType type;
  final bool important;

  NotificationModel({
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.important = false,
  });

  // Esto te servirá luego para XAMPP
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['titulo'],
      body: json['mensaje'],
      time: json['fecha'],
      important: json['prioridad'] == 1,
      type: _parseType(json['tipo']),
    );
  }

  static NotificationType _parseType(String type) {
    if (type == 'alerta') return NotificationType.warning;
    if (type == 'critico') return NotificationType.important;
    return NotificationType.info;
  }
}
