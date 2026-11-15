import '../models/wealth_models.dart';

abstract class WealthRepository {
  Future<TaxHarvestResult> simulateTaxHarvest({
    required String jurisdiction,
    required int taxYear,
  });
  Future<List<RebalanceAction>> simulateRebalancing({
    required Map<String, double> targetAllocation,
  });
}
