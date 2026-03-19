import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationService {
  final NotificationRepository _repository = NotificationRepository();

  Future<List<NotificationModel>> getNotifications() {
    return _repository.getNotifications();
  }
}
