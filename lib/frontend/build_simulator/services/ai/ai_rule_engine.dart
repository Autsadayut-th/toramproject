import 'ai_models.dart';

class AiRuleEngine {
  const AiRuleEngine();

  List<String> evaluate(AiBuildContext context) {
    final ruleSet = context.ruleSet;
    if (ruleSet == null) {
      return const <String>[];
    }

    final List<String> recommendations = <String>[];

    if (context.level >= 80) {
      final int softCap = ruleSet.criticalDamageSoftCap;
      if (softCap > 0) {
        final num totalCritDamage = context.sumStatValue('critical_damage');
        final num str = AiBuildContext.read(context.character['STR']);
        final num estimatedCritDamage =
            ruleSet.criticalDamageBase +
            (str * ruleSet.strCriticalDamagePerPoint) +
            totalCritDamage;
        if (estimatedCritDamage > softCap) {
          _addRecommendation(
            recommendations,
            'Estimated Critical Damage ${estimatedCritDamage.toInt()} is above soft cap $softCap (penalty factor ${ruleSet.criticalDamageOvercapPenalty}).',
          );
        }
      }
    }

    if (ruleSet.crystaCheckScope.trim().toLowerCase() ==
        'same_equipment_only') {
      if (ruleSet.noDuplicateCrystaInSameEquipment) {
        final List<String> duplicatedEquipments = <String>[];
        for (final MapEntry<String, List<String>> entry
            in context.crystalKeysByEquipment.entries) {
          final List<String> keys = entry.value
              .map((String key) => key.trim().toLowerCase())
              .where((String key) => key.isNotEmpty)
              .toList(growable: false);
          if (keys.length > 1 && keys.toSet().length != keys.length) {
            duplicatedEquipments.add(entry.key);
          }
        }
        if (duplicatedEquipments.isNotEmpty) {
          _addRecommendation(
            recommendations,
            'Duplicate crysta in same equipment is not allowed by rules: ${duplicatedEquipments.join(', ')}.',
          );
        }
      }

      if (ruleSet.noSameUpgradeGroupInSameEquipment) {
        final List<String> sameGroupEquipments = <String>[];
        for (final MapEntry<String, List<String>> entry
            in context.crystalKeysByEquipment.entries) {
          final List<String> keys = entry.value
              .map((String key) => key.trim().toLowerCase())
              .where((String key) => key.isNotEmpty)
              .toList(growable: false);
          if (keys.length > 1 && context.hasDuplicateUpgradeGroup(keys)) {
            sameGroupEquipments.add(entry.key);
          }
        }
        if (sameGroupEquipments.isNotEmpty) {
          _addRecommendation(
            recommendations,
            'Crysta from the same upgrade line should not share one equipment: ${sameGroupEquipments.join(', ')}.',
          );
        }
      }
    }

    if (!AiBuildContext.isEmpty(context.equipmentSlots.mainWeaponId) &&
        context.level >= 60 &&
        ruleSet.elementDamageBonus > 0) {
      _addRecommendation(
        recommendations,
        'Element advantage can add about ${(ruleSet.elementDamageBonus * 100).toStringAsFixed(0)}% damage. Prepare element-specific weapon variants.',
      );
    }

    return recommendations.toList(growable: false);
  }

  void _addRecommendation(List<String> recommendations, String value) {
    final String text = value.trim();
    if (text.isEmpty || recommendations.contains(text)) {
      return;
    }
    recommendations.add(text);
  }
}
