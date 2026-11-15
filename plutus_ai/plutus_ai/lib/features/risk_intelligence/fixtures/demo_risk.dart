import '../models/risk_models.dart';

class DemoRisk {
  static const QuantitativeRiskProfile defaultProfile = QuantitativeRiskProfile(
    riskScore: 68,
    riskLevel: 'Moderate-Aggressive',
    beta: 1.14,
    sharpeRatio: 6.30,
    sortinoRatio: 15.41,
    annualizedVolatility: 11.69,
    maxDrawdown: -1.13,
    var951d: 1762.50,
    cvar951d: 2000.00,
    hhiConcentration: 0.132,
    methodology:
        'Parametric & Historical Simulation (252-day annualization, 4.5% Risk-Free Rate)',
    status: 'VERIFIED_CALCULATION',
  );

  static const CorrelationMatrixData defaultCorrelation = CorrelationMatrixData(
    assets: ['NVDA', 'AAPL', 'MSFT', 'BTC', 'BND', 'GLD'],
    matrix: [
      [1.00, 0.72, 0.78, 0.44, -0.18, 0.05],
      [0.72, 1.00, 0.81, 0.38, -0.12, 0.08],
      [0.78, 0.81, 1.00, 0.41, -0.15, 0.04],
      [0.44, 0.38, 0.41, 1.00, -0.05, 0.22],
      [-0.18, -0.12, -0.15, -0.05, 1.00, 0.31],
      [0.05, 0.08, 0.04, 0.22, 0.31, 1.00],
    ],
    period: '1Y_DAILY',
  );
}
