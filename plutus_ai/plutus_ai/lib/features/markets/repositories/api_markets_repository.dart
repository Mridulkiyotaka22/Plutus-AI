import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/market_instrument.dart';
import 'markets_repository.dart';

class ApiMarketsRepository implements MarketsRepository {
  final ApiClient _client = ApiClient();

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map<String, dynamic> ? value : <String, dynamic>{};

  @override
  Future<List<MarketInstrument>> getInstruments({String? search, AssetCategory? category}) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();
    if (category != null && category != AssetCategory.all) {
      switch (category) {
        case AssetCategory.equity:
          queryParams['asset_type'] = 'EQUITY';
          break;
        case AssetCategory.crypto:
          queryParams['asset_type'] = 'CRYPTO';
          break;
        case AssetCategory.fixedIncome:
          queryParams['asset_type'] = 'FIXED_INCOME';
          break;
        case AssetCategory.commodity:
          queryParams['asset_type'] = 'COMMODITY';
          break;
        case AssetCategory.all:
          break;
      }
    }

    final response = await _client.dio.get('market/instruments/', queryParameters: queryParams);
    final list = response.data as List<dynamic>;
    // Load catalogue metadata cheaply. Quotes/history are requested only for the
    // selected symbol in getInstrumentDetail to avoid burst requests to Yahoo.
    return list
        .whereType<Map<String, dynamic>>()
        .map(MarketInstrument.fromJson)
        .toList();
  }

  @override
  Future<MarketInstrument> getInstrumentDetail(String symbol, {String period = '1mo'}) async {
    final encoded = Uri.encodeComponent(symbol);
    final detailResponse = await _client.dio.get('market/instruments/$encoded/');
    final combined = Map<String, dynamic>.from(_asMap(detailResponse.data));

    try {
      final quoteResponse = await _client.dio.get('market/instruments/$encoded/quote/');
      combined.addAll(_asMap(quoteResponse.data));
    } on DioException {
      combined['available'] = false;
    }

    try {
      final interval = period == '1d' ? '5m' : (period == '5d' ? '15m' : '1d');
      final historyResponse = await _client.dio.get(
        'market/instruments/$encoded/history/',
        queryParameters: {'range': period, 'interval': interval},
      );
      final historyBody = _asMap(historyResponse.data);
      combined['history'] = historyBody['data'] is List ? historyBody['data'] : const [];
      combined['source'] = historyBody['source'] ?? combined['source'];
    } on DioException {
      combined['history'] = const [];
    }
    return MarketInstrument.fromJson(combined);
  }
}
