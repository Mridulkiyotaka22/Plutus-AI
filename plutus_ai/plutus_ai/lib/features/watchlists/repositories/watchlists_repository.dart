import '../models/watchlist_model.dart';

abstract class WatchlistsRepository {
  Future<List<WatchlistModel>> getWatchlists();
  Future<WatchlistModel> createWatchlist(String name);
  Future<bool> addItem(String watchlistId, String symbol, {String? notes});
  Future<bool> removeItem(String watchlistId, String itemId);
}
