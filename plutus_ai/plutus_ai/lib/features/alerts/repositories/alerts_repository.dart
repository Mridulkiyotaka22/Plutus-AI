import '../models/alert_model.dart';

abstract class AlertsRepository {
  Future<List<AlertModel>> getAlerts({String? category, bool? unreadOnly});
  Future<bool> markAsRead(String alertId);
  Future<bool> markAllAsRead();
}
