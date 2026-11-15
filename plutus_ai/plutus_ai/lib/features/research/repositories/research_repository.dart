import '../models/research_model_meta.dart';

abstract class ResearchRepository {
  Future<List<ResearchModelMeta>> getResearchModels();
}
