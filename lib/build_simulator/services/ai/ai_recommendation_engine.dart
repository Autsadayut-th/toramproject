import 'ai_build_analyzer.dart';
import 'ai_deterministic_recommender.dart';
import 'ai_models.dart';
import 'ai_rule_engine.dart';
import 'ai_stat_optimizer.dart';
import 'recommendation_item.dart';

class AiRecommendationEngine {
  const AiRecommendationEngine({
    this.buildAnalyzer = const AiBuildAnalyzer(),
    this.statOptimizer = const AiStatOptimizer(),
    this.ruleEngine = const AiRuleEngine(),
    this.deterministicRecommender = const AiDeterministicRecommender(),
  });

  static const List<String> _defaultRecommendations = <String>[
    'Build is balanced right now. Focus next on refining weapon/armor and optimizing crystals.',
    'Prepare a boss-specific variant: one setup for survivability and one for maximum DPS.',
    'Track your stat goals each 10 levels so equipment upgrades stay efficient.',
  ];

  final AiBuildAnalyzer buildAnalyzer;
  final AiStatOptimizer statOptimizer;
  final AiRuleEngine ruleEngine;
  final AiDeterministicRecommender deterministicRecommender;

  List<String> generate(AiBuildInput input) {
    return generateItems(input)
        .map((AiRecommendationItem item) => item.normalizedMessage)
        .toList(growable: false);
  }

  List<AiRecommendationItem> generateItems(AiBuildInput input) {
    final AiBuildContext context = AiBuildContext.fromInput(input);
    final AiBuildAnalysis analysis = buildAnalyzer.analyze(context);

    final List<AiRecommendationItem> recommendations = <AiRecommendationItem>[];
    _addTextRecommendations(
      recommendations,
      analysis.recommendations,
      category: 'analysis',
      priority: 2,
      confidence: 0.82,
      reason: 'Derived from build-state analysis checks.',
    );
    _addTextRecommendations(
      recommendations,
      statOptimizer.optimize(context: context, analysis: analysis),
      category: 'stat',
      priority: 2,
      confidence: 0.84,
      reason: 'Derived from stat optimizer and rule thresholds.',
    );
    _addTextRecommendations(
      recommendations,
      ruleEngine.evaluate(context),
      category: 'rule',
      priority: 1,
      confidence: 0.9,
      reason: 'Triggered from explicit rule validations.',
    );
    _addItems(recommendations, deterministicRecommender.suggest(context));

    if (recommendations.isEmpty) {
      _addTextRecommendations(
        recommendations,
        _defaultRecommendations,
        category: 'analysis',
        priority: 4,
        confidence: 0.6,
        reason: 'Fallback recommendations because no critical gaps were found.',
      );
    }

    recommendations.sort((AiRecommendationItem a, AiRecommendationItem b) {
      final int priorityDiff = a.priority.compareTo(b.priority);
      if (priorityDiff != 0) {
        return priorityDiff;
      }
      return b.confidence.compareTo(a.confidence);
    });

    return recommendations.take(6).toList(growable: false);
  }

  void _addTextRecommendations(
    List<AiRecommendationItem> recommendations,
    Iterable<String> values, {
    required String category,
    required int priority,
    required double confidence,
    required String reason,
  }) {
    for (final String value in values) {
      _add(
        recommendations,
        AiRecommendationItem.fromText(
          message: value,
          category: category,
          priority: priority,
          source: 'rule',
          confidence: confidence,
          reason: reason,
        ),
      );
    }
  }

  void _addItems(
    List<AiRecommendationItem> recommendations,
    Iterable<AiRecommendationItem> values,
  ) {
    for (final AiRecommendationItem value in values) {
      _add(recommendations, value);
    }
  }

  void _add(
    List<AiRecommendationItem> recommendations,
    AiRecommendationItem candidate,
  ) {
    if (!candidate.isValid) {
      return;
    }
    final String message = candidate.normalizedMessage;
    for (final AiRecommendationItem existing in recommendations) {
      if (existing.normalizedMessage == message) {
        return;
      }
    }
    recommendations.add(candidate);
  }
}
