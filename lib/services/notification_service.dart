import '../models/notification_model.dart';

class NotificationService {
  static List<NotificationModel> getNotifications() {
    return const [
      NotificationModel(
        title: "Retraso en ruta Centro - UPTC",
        body: "Se reporta congestión. Tiempo estimado +6 min.",
        time: "Hace 5 min",
        type: NotificationType.warning,
        important: true,
      ),
      NotificationModel(
        title: "Nueva parada habilitada",
        body: "Se agregó la parada “Avenida Norte” para rutas hacia Unicentro.",
        time: "Hoy",
        type: NotificationType.info,
        important: false,
      ),
      NotificationModel(
        title: "Mantenimiento programado",
        body: "Algunas rutas tendrán cambios temporales el fin de semana.",
        time: "Ayer",
        type: NotificationType.important,
        important: true,
      ),
      NotificationModel(
        title: "Recordatorio",
        body: "Califica tu último viaje para mejorar el servicio.",
        time: "Ayer",
        type: NotificationType.info,
        important: false,
      ),
    ];
  }
}
