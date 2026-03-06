import 'ai_models.dart';

class AiStatOptimizer {
  const AiStatOptimizer();

  List<String> optimize({
    required AiBuildContext context,
    required AiBuildAnalysis analysis,
  }) {
    final List<String> recommendations = <String>[];
    final ruleSet = context.ruleSet;

    if (ruleSet != null) {
      final String buildId = _inferBuildId(
        physicalFocus: context.physicalFocus,
        highestStat: context.highestStat,
        personalStatType: context.personalStatType,
      );
      final String buildName = ruleSet.buildNameForId(buildId);
      final List<String> priorityStats = ruleSet.priorityStatsForBuild(buildId);
      if (priorityStats.isNotEmpty) {
        final Set<String> mappedPriorityStats = priorityStats
            .map(AiBuildContext.mapRulePriorityStatToDataKey)
            .where((String key) => key.isNotEmpty)
            .toSet();
        if (!context.hasAnyStat(mappedPriorityStats)) {
          _addRecommendation(
            recommendations,
            '$buildName priorities suggest focusing on: ${priorityStats.take(3).join(', ')}.',
          );
        }
      }

      final List<List<String>> statPairs = _extractStatPairs(
        ruleSet.combatStatPriorityForWeapon(context.weaponTypeKey),
      );
      if (statPairs.isNotEmpty) {
        final Set<String> preferredMainStats = statPairs
            .map((List<String> pair) => pair.first.trim().toUpperCase())
            .where((String value) => value.isNotEmpty)
            .toSet();
        if (preferredMainStats.isNotEmpty &&
            !preferredMainStats.contains(context.highestStat)) {
          _addRecommendation(
            recommendations,
            'Primary stat ${context.highestStat} may not match ${context.weaponTypeKey} priorities (${preferredMainStats.join('/')}).',
          );
        }
      }

      final String? preferredScalingStat = _preferredScalingStat(
        ruleSet.weaponScalingForWeapon(context.weaponTypeKey),
        preferMatk: !context.physicalFocus,
      );
      if (preferredScalingStat != null &&
          preferredScalingStat.isNotEmpty &&
          preferredScalingStat != context.highestStat) {
        _addRecommendation(
          recommendations,
          'For ${context.weaponTypeKey}, $preferredScalingStat scales better for ${context.physicalFocus ? 'ATK' : 'MATK'} than ${context.highestStat}.',
        );
      }
    }

    if (recommendations.isEmpty && analysis.priorityStats.isNotEmpty) {
      _addRecommendation(
        recommendations,
        'Current build gaps suggest prioritizing: ${analysis.priorityStats.take(3).join(', ')}.',
      );
    }

    return recommendations.toList(growable: false);
  }

  String _inferBuildId({
    required bool physicalFocus,
    required String highestStat,
    required String personalStatType,
  }) {
    if (highestStat == 'VIT') {
      return 'tank';
    }
    if (personalStatType.trim().toUpperCase() == 'MNT') {
      return 'support';
    }
    if (!physicalFocus) {
      return 'magic_dps';
    }
    return 'physical_dps';
  }

  List<List<String>> _extractStatPairs(dynamic value) {
    final List<List<String>> pairs = <List<String>>[];
    _collectStatPairs(value, pairs);
    return pairs.toList(growable: false);
  }

  void _collectStatPairs(dynamic value, List<List<String>> pairs) {
    if (value is List) {
      if (value.length == 2 && value[0] is String && value[1] is String) {
        pairs.add(<String>[
          value[0].toString().trim(),
          value[1].toString().trim(),
        ]);
        return;
      }
      for (final dynamic item in value) {
        _collectStatPairs(item, pairs);
      }
      return;
    }

    if (value is Map) {
      for (final dynamic child in value.values) {
        _collectStatPairs(child, pairs);
      }
    }
  }

  String? _preferredScalingStat(
    Map<String, dynamic> scaling, {
    required bool preferMatk,
  }) {
    final String targetKey = preferMatk ? 'matk' : 'atk';
    String? bestStat;
    num bestValue = 0;
    for (final MapEntry<String, dynamic> entry in scaling.entries) {
      final String stat = entry.key.trim().toUpperCase();
      if (stat.isEmpty || entry.value is! Map) {
        continue;
      }
      final Map<dynamic, dynamic> statDetails =
          entry.value as Map<dynamic, dynamic>;
      final num currentValue = AiBuildContext.read(statDetails[targetKey]);
      if (currentValue <= 0) {
        continue;
      }
      if (bestStat == null || currentValue > bestValue) {
        bestStat = stat;
        bestValue = currentValue;
      }
    }
    return bestStat;
  }

  void _addRecommendation(List<String> recommendations, String value) {
    final String text = value.trim();
    if (text.isEmpty || recommendations.contains(text)) {
      return;
    }
    recommendations.add(text);
  }
}
