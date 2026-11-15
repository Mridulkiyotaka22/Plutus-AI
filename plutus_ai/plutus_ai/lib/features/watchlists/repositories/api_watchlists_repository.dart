import '../../../core/api/api_client.dart';
import '../models/watchlist_model.dart';
import 'watchlists_repository.dart';

class ApiWatchlistsRepository implements WatchlistsRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<List<WatchlistModel>> getWatchlists() async {
    final response = await _client.dio.get('watchlists/');
    final list = response.data as List<dynamic>;
    return list
        .map((json) => WatchlistModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<WatchlistModel> createWatchlist(String name) async {
    final response = await _client.dio.post(
      'watchlists/',
      data: {'name': name},
    );
    return WatchlistModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<bool> addItem(String watchlistId, String symbol,
      {String? notes}) async {
    // Lookup instrument id first
    final instResp = await _client.dio.get('market/instruments/$symbol/');
    final instId = instResp.data['id'];

    await _client.dio.post(
      'watchlists/$watchlistId/items/',
      data: {
        'instrument_id': instId,
        'notes': notes ?? '',
      },
    );
    return true;
  }

  @override
  Future<bool> removeItem(String watchlistId, String itemId) async {
    await _client.dio.delete('watchlists/$watchlistId/items/$itemId/');
    return true;
  }
}
