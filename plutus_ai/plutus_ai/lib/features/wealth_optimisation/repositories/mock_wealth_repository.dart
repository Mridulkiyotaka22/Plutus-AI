import '../fixtures/demo_wealth.dart';
import '../models/wealth_models.dart';
import 'wealth_repository.dart';

class MockWealthRepository implements WealthRepository {
  @override
  Future<TaxHarvestResult> simulateTaxHarvest({
    required String jurisdiction,
    required int taxYear,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    double rate = 0.32;
    if (jurisdiction == 'UK_HMRC') rate = 0.20;
    if (jurisdiction == 'IN_ITR') rate = 0.20;

    const loss = 1365.00;
    return TaxHarvestResult(
      jurisdiction: jurisdiction,
      taxYear: taxYear,
      marginalRate: '${(rate * 100).toStringAsFixed(1)}%',
      totalHarvestableLoss: loss,
      estimatedTaxSavings: loss * rate,
      opportunities: DemoWealth.defaultTaxHarvest.opportunities,
      disclaimer:
          'Tax simulation only. Does not constitute tax or legal advice. Verify with a certified CPA.',
    );
  }

  @override
  Future<List<RebalanceAction>> simulateRebalancing({
    required Map<String, double> targetAllocation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return DemoWealth.defaultRebalance;
  }
}
