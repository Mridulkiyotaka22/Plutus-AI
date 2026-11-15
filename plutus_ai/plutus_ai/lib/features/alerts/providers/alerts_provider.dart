import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/env_config.dart';
import '../../../config/environment_provider.dart';
import '../models/alert_model.dart';
import '../repositories/alerts_repository.dart';
import '../repositories/api_alerts_repository.dart';
import '../repositories/mock_alerts_repository.dart';

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  if (environment == Environment.demo) {
    return MockAlertsRepository();
  }
  return ApiAlertsRepository();
});

final selectedAlertCategoryProvider = StateProvider<String>((ref) => 'ALL');
final unreadOnlyFilterProvider = StateProvider<bool>((ref) => false);

final alertsListProvider = FutureProvider<List<AlertModel>>((ref) async {
  final repo = ref.watch(alertsRepositoryProvider);
  final cat = ref.watch(selectedAlertCategoryProvider);
  final unread = ref.watch(unreadOnlyFilterProvider);
  return repo.getAlerts(category: cat, unreadOnly: unread);
});
