import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/env_config.dart';
import '../../../config/environment_provider.dart';
import '../models/behavioural_models.dart';
import '../repositories/api_behavioural_repository.dart';
import '../repositories/behavioural_repository.dart';
import '../repositories/mock_behavioural_repository.dart';

final behaviouralRepositoryProvider = Provider<BehaviouralRepository>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  if (environment == Environment.demo) {
    return MockBehaviouralRepository();
  }
  return ApiBehaviouralRepository();
});

final behaviouralProfileProvider =
    FutureProvider<BehaviouralProfileModel>((ref) async {
  final repo = ref.watch(behaviouralRepositoryProvider);
  return repo.getProfile();
});

final questionnaireQuestionsProvider =
    FutureProvider<List<QuestionModel>>((ref) async {
  final repo = ref.watch(behaviouralRepositoryProvider);
  return repo.getQuestions();
});
