import 'ai_build_recommendation_service.dart';
import 'ai_recommendation_request_payload.dart';
import 'ai/recommendation_item.dart';

class BuildRecommendationUiResult {
  const BuildRecommendationUiResult({
    required this.recommendationItems,
    required this.recommendations,
    required this.source,
    required this.message,
    required this.isFallback,
  });

  final List<AiRecommendationItem> recommendationItems;
  final List<String> recommendations;
  final String source;
  final String message;
  final bool isFallback;
}

class BuildRecommendationController {
  const BuildRecommendationController({
    required AiBuildRecommendationService aiService,
  }) : _aiService = aiService;

  final AiBuildRecommendationService _aiService;

  Future<BuildRecommendationUiResult> fetchRecommendations({
    required AiRecommendationRequestPayload payload,
  }) async {
    final AiBuildRecommendationResult result = await _aiService
        .fetchRecommendations(payload: payload);

    final List<AiRecommendationItem> items = result.recommendationItems;
    final List<String> recommendations = result.recommendations;
    final bool isFallback =
        result.status == 'fallback' || result.source == 'fallback';
    final String details = result.summary.isNotEmpty
        ? result.summary
        : result.message;

    return BuildRecommendationUiResult(
      recommendationItems: items,
      recommendations: recommendations,
      source: result.source,
      message: details,
      isFallback: isFallback,
    );
  }

  List<AiRecommendationItem> buildFallbackItems(
    List<String> recommendations,
  ) {
    return recommendations
        .map((String message) {
          return AiRecommendationItem.fromText(
            message: message,
            category: 'analysis',
            priority: 3,
            source: 'rule',
            confidence: 0.7,
          );
        })
        .toList(growable: false);
  }
}
