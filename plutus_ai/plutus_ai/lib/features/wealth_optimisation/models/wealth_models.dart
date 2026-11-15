class TaxOpportunity {
  final String symbol;
  final String name;
  final double shares;
  final double currentLoss;
  final String substituteSymbol;
  final String substituteName;
  final double correlation;
  final bool washSaleSafe;
  final int washSaleWindowDays;

  const TaxOpportunity({
    required this.symbol,
    required this.name,
    required this.shares,
    required this.currentLoss,
    required this.substituteSymbol,
    required this.substituteName,
    required this.correlation,
    this.washSaleSafe = true,
    this.washSaleWindowDays = 30,
  });

  factory TaxOpportunity.fromJson(Map<String, dynamic> json) {
    return TaxOpportunity(
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      shares: (json['shares'] as num?)?.toDouble() ?? 0.0,
      currentLoss: (json['current_loss'] as num?)?.toDouble() ?? 0.0,
      substituteSymbol: json['substitute_symbol'] as String? ??
          (json['substitute_asset'] is Map
              ? json['substitute_asset']['symbol']
              : json['substitute_asset']?.toString() ?? ''),
      substituteName: json['substitute_name'] as String? ?? '',
      correlation: (json['correlation'] as num?)?.toDouble() ?? 0.95,
      washSaleSafe: json['wash_sale_safe'] as bool? ?? true,
      washSaleWindowDays:
          (json['wash_sale_window_days'] as num?)?.toInt() ?? 30,
    );
  }
}

class TaxHarvestResult {
  final String jurisdiction;
  final int taxYear;
  final String marginalRate;
  final double totalHarvestableLoss;
  final double estimatedTaxSavings;
  final List<TaxOpportunity> opportunities;
  final String disclaimer;

  const TaxHarvestResult({
    required this.jurisdiction,
    required this.taxYear,
    required this.marginalRate,
    required this.totalHarvestableLoss,
    required this.estimatedTaxSavings,
    required this.opportunities,
    required this.disclaimer,
  });

  factory TaxHarvestResult.fromJson(Map<String, dynamic> json) {
    final rawOps = (json['opportunities'] ?? json['harvestable_opportunities'])
            as List<dynamic>? ??
        [];
    return TaxHarvestResult(
      jurisdiction: json['jurisdiction'] as String? ?? 'US_FEDERAL',
      taxYear: (json['tax_year'] as num?)?.toInt() ?? 2026,
      marginalRate: json['marginal_rate_assumed'] as String? ?? '32.0%',
      totalHarvestableLoss:
          (json['total_harvestable_loss'] as num?)?.toDouble() ?? 0.0,
      estimatedTaxSavings:
          (json['estimated_tax_savings'] as num?)?.toDouble() ?? 0.0,
      opportunities: rawOps
          .map((o) => TaxOpportunity.fromJson(o as Map<String, dynamic>))
          .toList(),
      disclaimer: json['disclaimer'] as String? ??
          'Simulation only. Consult a certified CPA.',
    );
  }
}

class RebalanceAction {
  final String assetClass;
  final double currentWeight;
  final double targetWeight;
  final double drift;
  final String action; // BUY, SELL, HOLD
  final double estimatedAdjustment;

  const RebalanceAction({
    required this.assetClass,
    required this.currentWeight,
    required this.targetWeight,
    required this.drift,
    required this.action,
    required this.estimatedAdjustment,
  });
}
