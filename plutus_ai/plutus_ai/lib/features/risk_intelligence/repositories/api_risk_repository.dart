import '../../../core/api/api_client.dart';
import '../models/risk_models.dart';
import 'risk_repository.dart';

class ApiRiskRepository implements RiskRepository {
  final ApiClient _client = ApiClient();
  String? _cachedPortfolioId;

  Future<String> _getPortfolioId() async {
    if (_cachedPortfolioId != null) return _cachedPortfolioId!;
    final response = await _client.dio.get('portfolios/');
    final list = response.data as List<dynamic>;
    if (list.isNotEmpty) {
      _cachedPortfolioId = list.first['id'] as String;
      return _cachedPortfolioId!;
    }
    throw Exception('No portfolios found');
  }

  @override
  Future<QuantitativeRiskProfile> getRiskProfile() async {
    final pfId = await _getPortfolioId();
    final response = await _client.dio.get('analytics/portfolio/$pfId/risk/');
    return QuantitativeRiskProfile.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<CorrelationMatrixData> getCorrelationMatrix() async {
    final pfId = await _getPortfolioId();
    final response =
        await _client.dio.get('analytics/portfolio/$pfId/correlation/');
    return CorrelationMatrixData.fromJson(
        response.data as Map<String, dynamic>);
  }
}
