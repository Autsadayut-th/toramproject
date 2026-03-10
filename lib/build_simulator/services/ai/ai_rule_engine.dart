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
      final Set<String> equippedElements = context.equippedElements();
      final int bonusPercent = (ruleSet.elementDamageBonus * 100).toInt();
      if (equippedElements.isEmpty) {
        _addRecommendation(
          recommendations,
          'No weapon element detected. Add an elemental weapon/arrow to gain up to about $bonusPercent% advantage damage.',
        );
      } else {
        final List<String> sortedElements = equippedElements.toList(
          growable: false,
        )..sort();
        if (sortedElements.length == 1) {
          final String element = sortedElements.first;
          final String favored = ruleSet.elementAdvantageMap[element] ?? '';
          if (favored.isNotEmpty) {
            _addRecommendation(
              recommendations,
              'Element equipped: ${_displayElement(element)}. It is strong against ${_displayElement(favored)} (+$bonusPercent% by rules).',
            );
          } else {
            _addRecommendation(
              recommendations,
              'Element equipped: ${_displayElement(element)}. Prepare element swaps to maximize the +$bonusPercent% advantage bonus.',
            );
          }
        } else {
          _addRecommendation(
            recommendations,
            'Element variants detected (${sortedElements.map(_displayElement).join(', ')}). Swap per boss element for about +$bonusPercent% advantage damage.',
          );
        }
      }
    }

    return recommendations.toList(growable: false);
  }

  String _displayElement(String value) {
    final String cleaned = value.trim().toLowerCase();
    if (cleaned.isEmpty) {
      return 'Unknown';
    }
    if (cleaned.length == 1) {
      return cleaned.toUpperCase();
    }
    return '${cleaned[0].toUpperCase()}${cleaned.substring(1)}';
  }

  void _addRecommendation(List<String> recommendations, String value) {
    final String text = value.trim();
    if (text.isEmpty || recommendations.contains(text)) {
      return;
    }
    recommendations.add(text);
  }
}
