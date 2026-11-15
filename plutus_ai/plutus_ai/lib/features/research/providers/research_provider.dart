import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/env_config.dart';
import '../../../config/environment_provider.dart';
import '../models/research_model_meta.dart';
import '../repositories/api_research_repository.dart';
import '../repositories/mock_research_repository.dart';
import '../repositories/research_repository.dart';

final researchRepositoryProvider = Provider<ResearchRepository>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  if (environment == Environment.demo) {
    return MockResearchRepository();
  }
  return ApiResearchRepository();
});

final researchModelsProvider =
    FutureProvider<List<ResearchModelMeta>>((ref) async {
  final repo = ref.watch(researchRepositoryProvider);
  return repo.getResearchModels();
});
