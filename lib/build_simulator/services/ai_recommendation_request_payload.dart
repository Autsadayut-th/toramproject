import 'ai/recommendation_item.dart';

class AiRecommendationRequestPayload {
  const AiRecommendationRequestPayload({
    required this.level,
    required this.personalStatType,
    required this.personalStatValue,
    required this.character,
    required this.summary,
    required this.equipmentSlots,
    required this.fallbackRecommendations,
    required this.fallbackRecommendationItems,
  });

  final int level;
  final String personalStatType;
  final int personalStatValue;
  final Map<String, dynamic> character;
  final Map<String, num> summary;
  final Map<String, dynamic> equipmentSlots;
  final List<String> fallbackRecommendations;
  final List<AiRecommendationItem> fallbackRecommendationItems;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'level': level,
      'personalStatType': personalStatType,
      'personalStatValue': personalStatValue,
      'character': Map<String, dynamic>.from(character),
      'summary': Map<String, num>.from(summary),
      'equipmentSlots': Map<String, dynamic>.from(equipmentSlots),
      'fallbackRecommendations': List<String>.from(fallbackRecommendations),
      'fallbackRecommendationItems': fallbackRecommendationItems
          .map((AiRecommendationItem item) => item.toJson())
          .toList(growable: false),
    };
  }
}
