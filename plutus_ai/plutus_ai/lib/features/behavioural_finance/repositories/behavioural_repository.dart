import '../models/behavioural_models.dart';

abstract class BehaviouralRepository {
  Future<List<QuestionModel>> getQuestions();
  Future<BehaviouralProfileModel> getProfile();
  Future<BehaviouralProfileModel> submitAnswers(Map<String, int> answers);
}
