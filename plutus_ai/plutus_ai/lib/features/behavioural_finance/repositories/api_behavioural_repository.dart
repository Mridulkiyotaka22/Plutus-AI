import '../../../core/api/api_client.dart';
import '../models/behavioural_models.dart';
import 'behavioural_repository.dart';

class ApiBehaviouralRepository implements BehaviouralRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<List<QuestionModel>> getQuestions() async {
    final response = await _client.dio.get('behavioural/questionnaire/');
    final list = response.data as List<dynamic>;
    return list
        .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BehaviouralProfileModel> getProfile() async {
    final response = await _client.dio.get('behavioural/profile/');
    return BehaviouralProfileModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<BehaviouralProfileModel> submitAnswers(
      Map<String, int> answers) async {
    final response = await _client.dio.post(
      'behavioural/questionnaire/submit/',
      data: {'answers': answers},
    );
    final data = response.data as Map<String, dynamic>;
    return BehaviouralProfileModel.fromJson(
        data['profile'] as Map<String, dynamic>);
  }
}
