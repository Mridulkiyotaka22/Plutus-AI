import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/env_config.dart';
import '../../../config/environment_provider.dart';
import '../models/watchlist_model.dart';
import '../repositories/api_watchlists_repository.dart';
import '../repositories/mock_watchlists_repository.dart';
import '../repositories/watchlists_repository.dart';

final watchlistsRepositoryProvider = Provider<WatchlistsRepository>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  if (environment == Environment.demo) {
    return MockWatchlistsRepository();
  }
  return ApiWatchlistsRepository();
});

final selectedWatchlistIdProvider = StateProvider<String?>((ref) => null);

final watchlistsListProvider =
    FutureProvider<List<WatchlistModel>>((ref) async {
  final repo = ref.watch(watchlistsRepositoryProvider);
  return repo.getWatchlists();
});
