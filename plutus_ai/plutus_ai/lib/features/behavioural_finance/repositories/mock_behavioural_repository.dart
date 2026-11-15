import '../fixtures/demo_behavioural.dart';
import '../models/behavioural_models.dart';
import 'behavioural_repository.dart';

class MockBehaviouralRepository implements BehaviouralRepository {
  BehaviouralProfileModel _profile = DemoBehavioural.defaultProfile;

  @override
  Future<List<QuestionModel>> getQuestions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return DemoBehavioural.defaultQuestions;
  }

  @override
  Future<BehaviouralProfileModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _profile;
  }

  @override
  Future<BehaviouralProfileModel> submitAnswers(
      Map<String, int> answers) async {
    await Future.delayed(const Duration(milliseconds: 300));
    int score = 0;
    for (final s in answers.values) {
      score += s;
    }
    String cat = 'Assertive / Growth Oriented';
    if (score >= 80) cat = 'Aggressive Growth';
    if (score < 40) cat = 'Conservative Capital Preservation';

    _profile = BehaviouralProfileModel(
      compositeScore: score,
      riskCategory: cat,
      lossAversionScore: 100 - score,
      overconfidenceScore: (score * 0.45).toInt(),
      panicSellingPropensity: score > 60 ? 'Low' : 'Moderate',
      selfReportedScore: score,
      tradeObservedScore: (score * 0.92).toInt(),
      summary:
          'Updated psychological assessment reflects $cat posture with calibrated loss aversion.',
    );
    return _profile;
  }
}
