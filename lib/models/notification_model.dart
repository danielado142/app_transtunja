enum NotificationType { info, warning, important }

class NotificationModel {
  final String title;
  final String body;
  final String time;
  final NotificationType type;
  final bool important;

  const NotificationModel({
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.important,
  });
}
