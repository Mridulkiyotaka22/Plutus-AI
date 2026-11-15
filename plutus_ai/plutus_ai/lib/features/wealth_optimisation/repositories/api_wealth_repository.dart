import '../../../core/api/api_client.dart';
import '../models/wealth_models.dart';
import 'wealth_repository.dart';

class ApiWealthRepository implements WealthRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<TaxHarvestResult> simulateTaxHarvest({
    required String jurisdiction,
    required int taxYear,
  }) async {
    final response = await _client.dio.post(
      'wealth/tax-harvest/',
      data: {'jurisdiction': jurisdiction, 'tax_year': taxYear},
    );
    return TaxHarvestResult.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<RebalanceAction>> simulateRebalancing({
    required Map<String, double> targetAllocation,
  }) async {
    final response = await _client.dio.post(
      'wealth/rebalance/',
      data: {'target_allocation': targetAllocation},
    );
    final raw = response.data['rebalance_plan'] as List<dynamic>? ?? [];
    return raw.map((item) {
      final m = item as Map<String, dynamic>;
      return RebalanceAction(
        assetClass: m['asset_class'] as String? ?? '',
        currentWeight: (m['current_weight'] as num?)?.toDouble() ?? 0.0,
        targetWeight: (m['target_weight'] as num?)?.toDouble() ?? 0.0,
        drift: (m['drift'] as num?)?.toDouble() ?? 0.0,
        action: m['action'] as String? ?? 'HOLD',
        estimatedAdjustment:
            (m['adjustment_dollars'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }
}
