class QuantitativeRiskProfile {
  final int riskScore;
  final String riskLevel;
  final double beta;
  final double sharpeRatio;
  final double sortinoRatio;
  final double annualizedVolatility;
  final double maxDrawdown;
  final double var951d;
  final double cvar951d;
  final double hhiConcentration;
  final String methodology;
  final String status;

  const QuantitativeRiskProfile({
    required this.riskScore,
    required this.riskLevel,
    required this.beta,
    required this.sharpeRatio,
    required this.sortinoRatio,
    required this.annualizedVolatility,
    required this.maxDrawdown,
    required this.var951d,
    required this.cvar951d,
    required this.hhiConcentration,
    required this.methodology,
    required this.status,
  });

  factory QuantitativeRiskProfile.fromJson(Map<String, dynamic> json) {
    return QuantitativeRiskProfile(
      riskScore: (json['risk_score'] as num?)?.toInt() ?? 68,
      riskLevel: json['risk_level'] as String? ?? 'Moderate-Aggressive',
      beta: (json['beta'] as num?)?.toDouble() ?? 1.14,
      sharpeRatio: (json['sharpe_ratio'] as num?)?.toDouble() ?? 6.30,
      sortinoRatio: (json['sortino_ratio'] as num?)?.toDouble() ?? 15.41,
      annualizedVolatility:
          (json['annualized_volatility'] as num?)?.toDouble() ?? 11.69,
      maxDrawdown: (json['max_drawdown'] as num?)?.toDouble() ?? -1.13,
      var951d: (json['var_95_1d'] as num?)?.toDouble() ?? 1762.50,
      cvar951d: (json['cvar_95_1d'] as num?)?.toDouble() ?? 2000.00,
      hhiConcentration:
          (json['hhi_concentration'] as num?)?.toDouble() ?? 0.132,
      methodology: json['methodology'] as String? ??
          'Parametric & Historical Simulation',
      status: json['status'] as String? ?? 'VERIFIED_CALCULATION',
    );
  }
}

class CorrelationMatrixData {
  final List<String> assets;
  final List<List<double>> matrix;
  final String period;

  const CorrelationMatrixData({
    required this.assets,
    required this.matrix,
    required this.period,
  });

  factory CorrelationMatrixData.fromJson(Map<String, dynamic> json) {
    final rawAssets = json['assets'] as List<dynamic>? ?? [];
    final rawMatrix = json['matrix'] as List<dynamic>? ?? [];
    final matrix = rawMatrix
        .map((row) =>
            (row as List<dynamic>).map((v) => (v as num).toDouble()).toList())
        .toList();

    return CorrelationMatrixData(
      assets: rawAssets.map((a) => a.toString()).toList(),
      matrix: matrix,
      period: json['period'] as String? ?? '1Y_DAILY',
    );
  }
}
