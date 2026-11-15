import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/env_config.dart';
import '../../../config/environment_provider.dart';
import '../models/wealth_models.dart';
import '../repositories/api_wealth_repository.dart';
import '../repositories/mock_wealth_repository.dart';
import '../repositories/wealth_repository.dart';

final wealthRepositoryProvider = Provider<WealthRepository>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  if (environment == Environment.demo) {
    return MockWealthRepository();
  }
  return ApiWealthRepository();
});

final selectedJurisdictionProvider =
    StateProvider<String>((ref) => 'US_FEDERAL');
final selectedTaxYearProvider = StateProvider<int>((ref) => 2026);

final taxHarvestSimulationProvider =
    FutureProvider<TaxHarvestResult>((ref) async {
  final repo = ref.watch(wealthRepositoryProvider);
  final jur = ref.watch(selectedJurisdictionProvider);
  final year = ref.watch(selectedTaxYearProvider);
  return repo.simulateTaxHarvest(jurisdiction: jur, taxYear: year);
});

final rebalancePlanProvider =
    FutureProvider<List<RebalanceAction>>((ref) async {
  final repo = ref.watch(wealthRepositoryProvider);
  return repo.simulateRebalancing(targetAllocation: {
    'Equities / Stocks': 40.0,
    'Fixed Income / Bonds': 25.0,
    'Crypto Assets': 10.0,
    'Commodities': 15.0,
    'Cash & Equivalents': 10.0,
  });
});
