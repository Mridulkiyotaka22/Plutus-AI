import '../models/wealth_models.dart';

class DemoWealth {
  static const TaxHarvestResult defaultTaxHarvest = TaxHarvestResult(
    jurisdiction: 'US_FEDERAL',
    taxYear: 2026,
    marginalRate: '32.0%',
    totalHarvestableLoss: 1365.00,
    estimatedTaxSavings: 436.80,
    opportunities: [
      TaxOpportunity(
        symbol: 'BND',
        name: 'Vanguard Total Bond Market ETF',
        shares: 650.0,
        currentLoss: 1365.00,
        substituteSymbol: 'AGG',
        substituteName: 'iShares Core U.S. Aggregate Bond ETF',
        correlation: 0.98,
        washSaleSafe: true,
        washSaleWindowDays: 30,
      ),
    ],
    disclaimer:
        'Tax simulation only. Does not constitute tax or legal advice. Verify with a qualified CPA.',
  );

  static const List<RebalanceAction> defaultRebalance = [
    RebalanceAction(
      assetClass: 'Equities / Stocks',
      currentWeight: 58.7,
      targetWeight: 40.0,
      drift: 18.7,
      action: 'TRIM',
      estimatedAdjustment: -53248.00,
    ),
    RebalanceAction(
      assetClass: 'Fixed Income / Bonds',
      currentWeight: 16.5,
      targetWeight: 25.0,
      drift: -8.5,
      action: 'BUY',
      estimatedAdjustment: 24200.00,
    ),
    RebalanceAction(
      assetClass: 'Crypto Assets',
      currentWeight: 11.9,
      targetWeight: 10.0,
      drift: 1.9,
      action: 'HOLD',
      estimatedAdjustment: -5410.00,
    ),
    RebalanceAction(
      assetClass: 'Commodities',
      currentWeight: 9.4,
      targetWeight: 15.0,
      drift: -5.6,
      action: 'BUY',
      estimatedAdjustment: 16000.00,
    ),
    RebalanceAction(
      assetClass: 'Cash & Equivalents',
      currentWeight: 8.0,
      targetWeight: 10.0,
      drift: -2.0,
      action: 'BUY',
      estimatedAdjustment: 5700.00,
    ),
  ];
}
