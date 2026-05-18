import 'package:flutter_test/flutter_test.dart';
import 'package:toramonline/build_simulator/services/ai/ai_build_analyzer.dart';
import 'package:toramonline/build_simulator/services/ai/ai_deterministic_recommender.dart';
import 'package:toramonline/build_simulator/services/ai/ai_models.dart';
import 'package:toramonline/build_simulator/services/ai/ai_recommendation_engine.dart';
import 'package:toramonline/build_simulator/services/ai/ai_rule_engine.dart';
import 'package:toramonline/build_simulator/services/ai/ai_stat_optimizer.dart';
import 'package:toramonline/build_simulator/services/ai/recommendation_item.dart';
import 'package:toramonline/equipment_library/models/equipment_library_item.dart';

void main() {
  const Map<String, dynamic> emptyCharacter = <String, dynamic>{
    'STR': 1,
    'DEX': 1,
    'INT': 1,
    'AGI': 1,
    'VIT': 1,
  };

  AiBuildInput buildInput() {
    return AiBuildInput(
      summary: const <String, num>{
        'ATK': 0,
        'MATK': 0,
        'DEF': 0,
        'MDEF': 0,
        'STR': 1,
        'DEX': 1,
        'INT': 1,
        'AGI': 1,
        'VIT': 1,
        'ASPD': 0,
        'CSPD': 0,
        'FLEE': 0,
        'CritRate': 25,
        'PhysicalPierce': 0,
        'MagicPierce': 0,
        'ElementPierce': 0,
        'Accuracy': 0,
        'Stability': 0,
        'HP': 100,
        'MP': 100,
      },
      character: emptyCharacter,
      level: 100,
      personalStatType: 'CRT',
      personalStatValue: 0,
      equipmentSlots: const AiEquipmentSlots(
        mainWeaponId: 'main',
        subWeaponId: 'sub',
        armorId: 'armor',
        helmetId: 'helmet',
        ringId: 'ring',
        enhanceMain: 0,
        enhanceArmor: 0,
        enhanceHelmet: 0,
        enhanceRing: 0,
      ),
      equippedItems: const <EquipmentLibraryItem>[],
      equippedCrystalStats: const <EquipmentStat>[],
      crystalKeysByEquipment: const <String, List<String>>{},
      crystalUpgradeFromByKey: const <String, String?>{},
      normalizedMainWeaponType: '1H_SWORD',
      ruleSet: null,
    );
  }

  test(
    'dedupes near-identical recommendations that only differ by punctuation',
    () {
      final AiRecommendationEngine engine = AiRecommendationEngine(
        buildAnalyzer: _FakeAnalyzer(const <String>['Refine Main Weapon now!']),
        statOptimizer: _FakeStatOptimizer(const <String>[
          'Refine Main Weapon now',
        ]),
        ruleEngine: _FakeRuleEngine(const <String>[]),
        deterministicRecommender: _FakeDeterministicRecommender(
          const <AiRecommendationItem>[],
        ),
      );

      final List<AiRecommendationItem> items = engine.generateItems(
        buildInput(),
      );

      expect(items, hasLength(1));
      expect(items.single.normalizedMessage, 'Refine Main Weapon now!');
    },
  );

  test('ranks equally strong items by category quality before confidence', () {
    final AiRecommendationEngine engine = AiRecommendationEngine(
      buildAnalyzer: _FakeAnalyzer(const <String>['General build cleanup']),
      statOptimizer: _FakeStatOptimizer(const <String>['Stat tuning']),
      ruleEngine: _FakeRuleEngine(const <String>['Rule validation']),
      deterministicRecommender: _FakeDeterministicRecommender(
        const <AiRecommendationItem>[],
      ),
    );

    final List<AiRecommendationItem> items = engine.generateItems(buildInput());

    expect(items, hasLength(3));
    expect(items[0].category, 'rule');
    expect(items[1].category, 'stat');
    expect(items[2].category, 'analysis');
  });
}

class _FakeAnalyzer extends AiBuildAnalyzer {
  const _FakeAnalyzer(this.recommendations);

  final List<String> recommendations;

  @override
  AiBuildAnalysis analyze(AiBuildContext context) {
    return AiBuildAnalysis(
      recommendations: recommendations,
      priorityStats: const <String>[],
    );
  }
}

class _FakeStatOptimizer extends AiStatOptimizer {
  const _FakeStatOptimizer(this.recommendations);

  final List<String> recommendations;

  @override
  List<String> optimize({
    required AiBuildContext context,
    required AiBuildAnalysis analysis,
  }) {
    return recommendations;
  }
}

class _FakeRuleEngine extends AiRuleEngine {
  const _FakeRuleEngine(this.recommendations);

  final List<String> recommendations;

  @override
  List<String> evaluate(AiBuildContext context) {
    return recommendations;
  }
}

class _FakeDeterministicRecommender extends AiDeterministicRecommender {
  const _FakeDeterministicRecommender(this.recommendations);

  final List<AiRecommendationItem> recommendations;

  @override
  List<AiRecommendationItem> suggest(AiBuildContext context) {
    return recommendations;
  }
}
