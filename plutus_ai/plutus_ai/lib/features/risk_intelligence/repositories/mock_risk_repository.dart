import '../fixtures/demo_risk.dart';
import '../models/risk_models.dart';
import 'risk_repository.dart';

class MockRiskRepository implements RiskRepository {
  @override
  Future<QuantitativeRiskProfile> getRiskProfile() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return DemoRisk.defaultProfile;
  }

  @override
  Future<CorrelationMatrixData> getCorrelationMatrix() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return DemoRisk.defaultCorrelation;
  }
}
