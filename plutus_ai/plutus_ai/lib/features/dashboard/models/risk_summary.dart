/// Portfolio risk metrics snapshot.
class RiskSummary {
  final int riskScore; // 0 - 100
  final String riskLevel; // e.g., Moderate-Aggressive
  final double beta;
  final double sharpeRatio;
  final double maxDrawdown;
  final double valueAtRisk95;
  final String riskAssessment;
  final bool available;

  const RiskSummary({
    required this.riskScore,
    required this.riskLevel,
    required this.beta,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.valueAtRisk95,
    required this.riskAssessment,
    this.available = true,
  });
}
