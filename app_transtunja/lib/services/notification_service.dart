import '../models/notification_model.dart';
// import 'package:http/http.dart' as http; // Descomenta esto cuando instales el paquete http

class NotificationService {
  Future<List<NotificationModel>> getNotifications() async {
    // POR AHORA: Retornamos datos de prueba para que la app no falle
    await Future.delayed(const Duration(seconds: 1)); // Simula carga

    return [
      NotificationModel(
        title: "Cambio de Ruta - Av. Universitaria",
        body: "Debido a obras, la ruta 4 desviará por la calle 10.",
        time: "Hace 10 min",
        type: NotificationType.warning,
        important: true,
      ),
      NotificationModel(
        title: "Nuevo Horario",
        body: "Los buses iniciarán servicio desde las 5:00 AM.",
        time: "Ayer",
        type: NotificationType.info,
      ),
    ];
  }
}
