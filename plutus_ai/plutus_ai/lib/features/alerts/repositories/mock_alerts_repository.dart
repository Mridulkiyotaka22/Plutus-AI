import '../fixtures/demo_alerts.dart';
import '../models/alert_model.dart';
import 'alerts_repository.dart';

class MockAlertsRepository implements AlertsRepository {
  List<AlertModel> _alerts = List.from(DemoAlerts.defaultAlerts);

  @override
  Future<List<AlertModel>> getAlerts(
      {String? category, bool? unreadOnly}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var list = _alerts;
    if (category != null && category != 'ALL') {
      list = list.where((a) => a.category == category).toList();
    }
    if (unreadOnly == true) {
      list = list.where((a) => !a.isRead).toList();
    }
    return list;
  }

  @override
  Future<bool> markAsRead(String alertId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _alerts.indexWhere((a) => a.id == alertId);
    if (idx != -1) {
      _alerts[idx] = _alerts[idx].copyWith(isRead: true);
      return true;
    }
    return false;
  }

  @override
  Future<bool> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _alerts = _alerts.map((a) => a.copyWith(isRead: true)).toList();
    return true;
  }
}
