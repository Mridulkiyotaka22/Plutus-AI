import '../../../core/api/api_client.dart';
import '../models/alert_model.dart';
import 'alerts_repository.dart';

class ApiAlertsRepository implements AlertsRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<List<AlertModel>> getAlerts(
      {String? category, bool? unreadOnly}) async {
    final params = <String, dynamic>{};
    if (category != null && category != 'ALL') params['category'] = category;
    if (unreadOnly == true) params['unread'] = 'true';

    final response = await _client.dio.get('alerts/', queryParameters: params);
    final list = response.data as List<dynamic>;
    return list
        .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> markAsRead(String alertId) async {
    await _client.dio.post('alerts/$alertId/read/');
    return true;
  }

  @override
  Future<bool> markAllAsRead() async {
    await _client.dio.post('alerts/read-all/');
    return true;
  }
}
