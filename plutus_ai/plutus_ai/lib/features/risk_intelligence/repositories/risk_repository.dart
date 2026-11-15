import '../models/risk_models.dart';

abstract class RiskRepository {
  Future<QuantitativeRiskProfile> getRiskProfile();
  Future<CorrelationMatrixData> getCorrelationMatrix();
}
