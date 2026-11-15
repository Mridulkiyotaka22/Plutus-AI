import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/env_config.dart';
import '../../../config/environment_provider.dart';
import '../models/portfolio_position.dart';
import '../repositories/api_portfolio_repository.dart';
import '../repositories/mock_portfolio_repository.dart';
import '../repositories/portfolio_repository.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  if (environment == Environment.demo) {
    return MockPortfolioRepository();
  }
  return ApiPortfolioRepository();
});

final portfolioSummaryProvider =
    FutureProvider<PortfolioSummaryData>((ref) async {
  final repo = ref.watch(portfolioRepositoryProvider);
  return repo.getPortfolioSummary();
});
