import '../../../core/api/api_client.dart';
import '../models/research_model_meta.dart';
import 'research_repository.dart';

class ApiResearchRepository implements ResearchRepository {
  final ApiClient _client = ApiClient();

  @override
  Future<List<ResearchModelMeta>> getResearchModels() async {
    final response = await _client.dio.get('research/models/');
    final list = response.data as List<dynamic>;
    return list
        .map((json) => ResearchModelMeta.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
