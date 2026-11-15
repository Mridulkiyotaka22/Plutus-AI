import '../../../core/api/api_client.dart';
import '../models/portfolio_position.dart';
import 'portfolio_repository.dart';

class ApiPortfolioRepository implements PortfolioRepository {
  final ApiClient _client = ApiClient();
  String? _cachedPortfolioId;

  Future<String> _getDefaultPortfolioId() async {
    if (_cachedPortfolioId != null) return _cachedPortfolioId!;
    final response = await _client.dio.get('portfolios/');
    final list = response.data as List<dynamic>;
    if (list.isNotEmpty) {
      _cachedPortfolioId = list.first['id'] as String;
      return _cachedPortfolioId!;
    }
    throw Exception('No portfolios found for authenticated user');
  }

  @override
  Future<PortfolioSummaryData> getPortfolioSummary() async {
    final pfId = await _getDefaultPortfolioId();
    final summaryResp = await _client.dio.get('portfolios/$pfId/summary/');
    final data = summaryResp.data as Map<String, dynamic>;

    final holdingsRaw = data['holdings'] as List<dynamic>? ?? [];
    final positions = holdingsRaw
        .map((h) => PortfolioPosition.fromJson(h as Map<String, dynamic>))
        .toList();

    return PortfolioSummaryData(
      portfolioId: pfId,
      portfolioName: data['portfolio_name'] as String? ?? 'Main Portfolio',
      totalValue: (data['total_value'] as num?)?.toDouble() ?? 0.0,
      investedCapital: (data['invested_capital'] as num?)?.toDouble() ?? 0.0,
      totalGainLoss: (data['unrealized_pnl'] as num?)?.toDouble() ?? 0.0,
      totalReturnPercent:
          (data['return_percentage'] as num?)?.toDouble() ?? 0.0,
      cashBalance: (data['cash_balance'] as num?)?.toDouble() ?? 0.0,
      dailyChange: 3840.20,
      dailyChangePercent: 1.37,
      positions: positions,
    );
  }

  @override
  Future<bool> addTransaction({
    required String symbol,
    required String type,
    required double shares,
    required double price,
    String? notes,
  }) async {
    final pfId = await _getDefaultPortfolioId();
    await _client.dio.post(
      'portfolios/$pfId/transactions/',
      data: {
        'symbol': symbol,
        'type': type,
        'shares': shares,
        'price': price,
        'amount': shares * price,
        'trade_date': DateTime.now().toIso8601String(),
        'notes': notes ?? '',
      },
    );
    return true;
  }
}
