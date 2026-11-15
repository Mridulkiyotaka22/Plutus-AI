import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/env_config.dart';
import '../../../config/environment_provider.dart';
import '../models/risk_models.dart';
import '../repositories/api_risk_repository.dart';
import '../repositories/mock_risk_repository.dart';
import '../repositories/risk_repository.dart';

final riskRepositoryProvider = Provider<RiskRepository>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  if (environment == Environment.demo) {
    return MockRiskRepository();
  }
  return ApiRiskRepository();
});

final riskProfileProvider =
    FutureProvider<QuantitativeRiskProfile>((ref) async {
  final repo = ref.watch(riskRepositoryProvider);
  return repo.getRiskProfile();
});

final correlationMatrixProvider =
    FutureProvider<CorrelationMatrixData>((ref) async {
  final repo = ref.watch(riskRepositoryProvider);
  return repo.getCorrelationMatrix();
});
