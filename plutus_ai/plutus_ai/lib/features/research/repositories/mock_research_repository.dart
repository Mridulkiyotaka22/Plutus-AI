import '../fixtures/demo_research.dart';
import '../models/research_model_meta.dart';
import 'research_repository.dart';

class MockResearchRepository implements ResearchRepository {
  @override
  Future<List<ResearchModelMeta>> getResearchModels() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return DemoResearch.defaultModels;
  }
}
