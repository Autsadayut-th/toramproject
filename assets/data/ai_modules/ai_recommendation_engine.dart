import 'ai_build_analyzer.dart';
import 'ai_crysta_recommender.dart';

class AIRecommendationEngine {

  BuildAnalyzer analyzer = BuildAnalyzer();
  CrystaRecommender crystaRecommender = CrystaRecommender();

  CrystaRecommendation run(
    Crysta current,
    List<Crysta> database,
    List<String> priorityStats,
  ) {

    CrystaRecommendation rec =
        crystaRecommender.recommend(
      current,
      database,
      priorityStats,
    );

    return rec;
  }
}