import 'ai_build_analyzer.dart';
import 'ai_models.dart';
import 'ai_rule_engine.dart';
import 'ai_stat_optimizer.dart';

class AiRecommendationEngine {
  const AiRecommendationEngine({
    this.buildAnalyzer = const AiBuildAnalyzer(),
    this.statOptimizer = const AiStatOptimizer(),
    this.ruleEngine = const AiRuleEngine(),
  });

  static const List<String> _defaultRecommendations = <String>[
    'Build is balanced right now. Focus next on refining weapon/armor and optimizing crystals.',
    'Prepare a boss-specific variant: one setup for survivability and one for maximum DPS.',
    'Track your stat goals each 10 levels so equipment upgrades stay efficient.',
  ];

  final AiBuildAnalyzer buildAnalyzer;
  final AiStatOptimizer statOptimizer;
  final AiRuleEngine ruleEngine;

  List<String> generate(AiBuildInput input) {
    final AiBuildContext context = AiBuildContext.fromInput(input);
    final AiBuildAnalysis analysis = buildAnalyzer.analyze(context);

    final List<String> recommendations = <String>[];
    _addAll(recommendations, analysis.recommendations);
    _addAll(
      recommendations,
      statOptimizer.optimize(context: context, analysis: analysis),
    );
    _addAll(recommendations, ruleEngine.evaluate(context));

    if (recommendations.isEmpty) {
      _addAll(recommendations, _defaultRecommendations);
    }

    return recommendations.take(6).toList(growable: false);
  }

  void _addAll(List<String> recommendations, Iterable<String> values) {
    for (final String value in values) {
      final String text = value.trim();
      if (text.isEmpty || recommendations.contains(text)) {
        continue;
      }
      recommendations.add(text);
    }
  }
}
