import '../../equipment_library/models/equipment_library_item.dart';
import 'build_rule_set_service.dart';

class BuildRecommendationService {
  static List<String> generate({
    required Map<String, num> summary,
    required Map<String, dynamic> character,
    required int level,
    required String personalStatType,
    required int personalStatValue,
    required String? mainWeaponId,
    required String? subWeaponId,
    required String? armorId,
    required String? helmetId,
    required String? ringId,
    required int enhanceMain,
    required int enhanceArmor,
    required int enhanceHelmet,
    required int enhanceRing,
    required Iterable<EquipmentLibraryItem> equippedItems,
    required Iterable<EquipmentStat> equippedCrystalStats,
    required Map<String, List<String>> crystalKeysByEquipment,
    required Map<String, String?> crystalUpgradeFromByKey,
    required String? normalizedMainWeaponType,
    BuildRuleSet? ruleSet,
  }) {
    final List<String> recommendations = <String>[];
    final num atk = _read(summary['ATK']);
    final num matk = _read(summary['MATK']);
    final num def = _read(summary['DEF']);
    final num mdef = _read(summary['MDEF']);
    final num critRate = _read(summary['CritRate']);
    final num physicalPierce = _read(summary['PhysicalPierce']);
    final num magicPierce = _read(summary['MagicPierce'] ?? summary['ElementPierce']);
    final num stability = _read(summary['Stability']);
    final num accuracy = _read(summary['Accuracy']);
    final num hp = _read(summary['HP']);
    final num mp = _read(summary['MP']);
    final String weaponTypeKey = _normalizeWeaponTypeKey(
      normalizedMainWeaponType ?? '',
    );
    final List<EquipmentStat> combinedStats = _combinedStats(
      equippedItems: equippedItems,
      equippedCrystalStats: equippedCrystalStats,
    );
    final bool hasRuleSet = ruleSet != null;
    final int physicalCritTarget = hasRuleSet ? ruleSet.physicalCritTarget : 70;
    final int physicalPierceTarget = hasRuleSet ? ruleSet.physicalPierceMinimum : 15;
    final int magicPierceTarget = hasRuleSet ? ruleSet.magicPierceMinimum : 15;
    final int magicMpTarget = hasRuleSet ? ruleSet.magicMpRecommended : 300;

    final List<String> missingSlots = <String>[];
    if (_isEmpty(mainWeaponId)) {
      missingSlots.add('Main Weapon');
    }
    if (_isEmpty(subWeaponId)) {
      missingSlots.add('Sub Weapon');
    }
    if (_isEmpty(armorId)) {
      missingSlots.add('Armor');
    }
    if (_isEmpty(helmetId)) {
      missingSlots.add('Helmet');
    }
    if (_isEmpty(ringId)) {
      missingSlots.add('Ring');
    }

    if (missingSlots.isNotEmpty) {
      _addRecommendation(
        recommendations,
        'Fill empty slots first: ${missingSlots.join(', ')}.',
      );
    }

    if (!_isEmpty(mainWeaponId) && level >= 30 && enhanceMain < 5) {
      _addRecommendation(
        recommendations,
        'Refine Main Weapon to at least +5. Current +$enhanceMain limits damage scaling.',
      );
    }
    if ((enhanceArmor + enhanceHelmet) < 6 && level >= 30) {
      _addRecommendation(
        recommendations,
        'Increase Armor/Helmet refine for better survivability. Current total: +${enhanceArmor + enhanceHelmet}.',
      );
    }
    if (!_isEmpty(ringId) && level >= 40 && enhanceRing < 3 && mp < 400) {
      _addRecommendation(
        recommendations,
        'Refine Ring or switch to MP-focused accessories. Current MP is ${mp.toInt()}.',
      );
    }

    final bool physicalFocus = atk >= matk;
    if (physicalFocus) {
      if (critRate < physicalCritTarget) {
        _addRecommendation(
          recommendations,
          'Critical Rate is low (${critRate.toInt()}). Target at least $physicalCritTarget for physical consistency.',
        );
      }
      if (physicalPierce < physicalPierceTarget && level >= 80) {
        _addRecommendation(
          recommendations,
          'Physical Pierce is low (${physicalPierce.toInt()}%). Target around $physicalPierceTarget+ for high-defense targets.',
        );
      }
    } else {
      if (magicPierce < magicPierceTarget && level >= 80) {
        _addRecommendation(
          recommendations,
          'Magic Pierce is low (${magicPierce.toInt()}%). Target around $magicPierceTarget+ for magic DPS consistency.',
        );
      }
      if (mp < magicMpTarget) {
        _addRecommendation(
          recommendations,
          'MP is low (${mp.toInt()}). Aim at least $magicMpTarget MP to keep your combo rotation stable.',
        );
      }
      if (weaponTypeKey == 'STAFF' && ruleSet != null) {
        final int staffCritTarget = ruleSet.magicStaffCritRecommended;
        if (staffCritTarget > 0 && critRate < staffCritTarget) {
          _addRecommendation(
            recommendations,
            'Staff magic-crit target is high ($staffCritTarget). Current Crit Rate ${critRate.toInt()} may be insufficient.',
          );
        }
      }
    }

    if (stability < 50 && level >= 50) {
      _addRecommendation(
        recommendations,
        'Stability is only ${stability.toInt()}%. Add Stability stats to reduce damage variance.',
      );
    }

    final int expectedAccuracy = (level + 20).clamp(30, 320);
    if (accuracy < expectedAccuracy) {
      _addRecommendation(
        recommendations,
        'Accuracy (${accuracy.toInt()}) may be low for Lv.$level. Aim around $expectedAccuracy+.',
      );
    }

    final int expectedHp = (700 + (level * 20)).clamp(700, 7000);
    if (hp < expectedHp) {
      _addRecommendation(
        recommendations,
        'HP (${hp.toInt()}) is low for Lv.$level. Add VIT/HP stats to avoid one-shot deaths.',
      );
    }

    final int expectedDefense = (120 + (level * 2)).clamp(120, 1000);
    if ((def + mdef) < expectedDefense) {
      _addRecommendation(
        recommendations,
        'DEF + MDEF is ${(def + mdef).toInt()}, below target $expectedDefense for Lv.$level.',
      );
    }

    final String highestStat = _highestStat(character);
    if (highestStat == 'INT' && atk > (matk * 1.2)) {
      _addRecommendation(
        recommendations,
        'Your main stat looks INT, but ATK is much higher than MATK. Check weapon/stat synergy.',
      );
    }
    if ((highestStat == 'STR' ||
            highestStat == 'DEX' ||
            highestStat == 'AGI') &&
        matk > (atk * 1.2)) {
      _addRecommendation(
        recommendations,
        'Your main stat looks physical, but MATK is much higher than ATK. Recheck build direction.',
      );
    }

    final bool hasCritOrPierce = _hasAnyStat(combinedStats, <String>{
      'critical_rate',
      'physical_pierce',
      'magic_pierce',
    });
    if (!hasCritOrPierce && level >= 60) {
      _addRecommendation(
        recommendations,
        'Most equipment lacks Crit/Pierce stats. Add at least one offensive stat source.',
      );
    }

    if (personalStatType.trim().toUpperCase() == 'CRT' &&
        personalStatValue == 0 &&
        physicalFocus) {
      _addRecommendation(
        recommendations,
        'Set personal stat CRT points if this is a physical DPS build.',
      );
    }

    if (ruleSet != null) {
      _appendBuildTypeRuleRecommendations(
        recommendations: recommendations,
        ruleSet: ruleSet,
        physicalFocus: physicalFocus,
        highestStat: highestStat,
        personalStatType: personalStatType,
        weaponTypeKey: weaponTypeKey,
        combinedStats: combinedStats,
      );
      _appendWeaponScalingRecommendation(
        recommendations: recommendations,
        ruleSet: ruleSet,
        physicalFocus: physicalFocus,
        highestStat: highestStat,
        weaponTypeKey: weaponTypeKey,
      );
      _appendCriticalDamageSoftCapRecommendation(
        recommendations: recommendations,
        ruleSet: ruleSet,
        level: level,
        character: character,
        combinedStats: combinedStats,
      );
      _appendCrystaSlotRecommendations(
        recommendations: recommendations,
        ruleSet: ruleSet,
        crystalKeysByEquipment: crystalKeysByEquipment,
        crystalUpgradeFromByKey: crystalUpgradeFromByKey,
      );
      _appendElementRuleRecommendation(
        recommendations: recommendations,
        ruleSet: ruleSet,
        level: level,
        hasMainWeapon: !_isEmpty(mainWeaponId),
      );
    }

    if (recommendations.isEmpty) {
      _addRecommendation(
        recommendations,
        'Build is balanced right now. Focus next on refining weapon/armor and optimizing crystals.',
      );
      _addRecommendation(
        recommendations,
        'Prepare a boss-specific variant: one setup for survivability and one for maximum DPS.',
      );
      _addRecommendation(
        recommendations,
        'Track your stat goals each 10 levels so equipment upgrades stay efficient.',
      );
    }

    return recommendations.take(6).toList(growable: false);
  }

  static void _appendBuildTypeRuleRecommendations({
    required List<String> recommendations,
    required BuildRuleSet ruleSet,
    required bool physicalFocus,
    required String highestStat,
    required String personalStatType,
    required String weaponTypeKey,
    required List<EquipmentStat> combinedStats,
  }) {
    final String buildId = _inferBuildId(
      physicalFocus: physicalFocus,
      highestStat: highestStat,
      personalStatType: personalStatType,
    );
    final String buildName = ruleSet.buildNameForId(buildId);
    final List<String> recommendedWeapons = ruleSet.recommendedWeaponsForBuild(
      buildId,
    );
    if (weaponTypeKey.isNotEmpty &&
        recommendedWeapons.isNotEmpty &&
        !recommendedWeapons.contains(weaponTypeKey)) {
      _addRecommendation(
        recommendations,
        '$weaponTypeKey is not in recommended weapons for $buildName.',
      );
    }

    final List<String> priorityStats = ruleSet.priorityStatsForBuild(buildId);
    if (priorityStats.isNotEmpty) {
      final Set<String> mappedPriorityStats = priorityStats
          .map(_mapRulePriorityStatToDataKey)
          .where((String key) => key.isNotEmpty)
          .toSet();
      final bool hasPriorityStat = _hasAnyStat(combinedStats, mappedPriorityStats);
      if (!hasPriorityStat) {
        final String hint = priorityStats.take(3).join(', ');
        _addRecommendation(
          recommendations,
          '$buildName priorities suggest focusing on: $hint.',
        );
      }
    }

    final dynamic combatPriority = ruleSet.combatStatPriorityForWeapon(
      weaponTypeKey,
    );
    final List<List<String>> statPairs = _extractStatPairs(combatPriority);
    if (statPairs.isNotEmpty) {
      final Set<String> preferredMainStats = statPairs
          .map((List<String> pair) => pair.first.trim().toUpperCase())
          .where((String value) => value.isNotEmpty)
          .toSet();
      if (preferredMainStats.isNotEmpty &&
          !preferredMainStats.contains(highestStat)) {
        _addRecommendation(
          recommendations,
          'Primary stat $highestStat may not match $weaponTypeKey priorities (${preferredMainStats.join('/')}).',
        );
      }
    }
  }

  static void _appendWeaponScalingRecommendation({
    required List<String> recommendations,
    required BuildRuleSet ruleSet,
    required bool physicalFocus,
    required String highestStat,
    required String weaponTypeKey,
  }) {
    if (weaponTypeKey.isEmpty) {
      return;
    }
    final Map<String, dynamic> scaling = ruleSet.weaponScalingForWeapon(
      weaponTypeKey,
    );
    if (scaling.isEmpty) {
      return;
    }
    final String? preferredStat = _preferredScalingStat(
      scaling,
      preferMatk: !physicalFocus,
    );
    if (preferredStat == null || preferredStat.isEmpty) {
      return;
    }
    if (preferredStat == highestStat) {
      return;
    }
    _addRecommendation(
      recommendations,
      'For $weaponTypeKey, $preferredStat scales better for ${physicalFocus ? 'ATK' : 'MATK'} than $highestStat.',
    );
  }

  static void _appendCriticalDamageSoftCapRecommendation({
    required List<String> recommendations,
    required BuildRuleSet ruleSet,
    required int level,
    required Map<String, dynamic> character,
    required List<EquipmentStat> combinedStats,
  }) {
    if (level < 80) {
      return;
    }
    final int softCap = ruleSet.criticalDamageSoftCap;
    if (softCap <= 0) {
      return;
    }
    final num totalCritDamage = _sumStatValue(combinedStats, 'critical_damage');
    final num str = _read(character['STR']);
    final num estimatedCritDamage = ruleSet.criticalDamageBase +
        (str * ruleSet.strCriticalDamagePerPoint) +
        totalCritDamage;
    if (estimatedCritDamage <= softCap) {
      return;
    }
    _addRecommendation(
      recommendations,
      'Estimated Critical Damage ${estimatedCritDamage.toInt()} is above soft cap $softCap (penalty factor ${ruleSet.criticalDamageOvercapPenalty}).',
    );
  }

  static void _appendCrystaSlotRecommendations({
    required List<String> recommendations,
    required BuildRuleSet ruleSet,
    required Map<String, List<String>> crystalKeysByEquipment,
    required Map<String, String?> crystalUpgradeFromByKey,
  }) {
    if (crystalKeysByEquipment.isEmpty) {
      return;
    }
    if (ruleSet.crystaCheckScope.trim().toLowerCase() != 'same_equipment_only') {
      return;
    }

    if (ruleSet.noDuplicateCrystaInSameEquipment) {
      final List<String> duplicatedEquipments = <String>[];
      for (final MapEntry<String, List<String>> entry
          in crystalKeysByEquipment.entries) {
        final List<String> keys = entry.value
            .map(_normalizeCrystalKey)
            .where((String key) => key.isNotEmpty)
            .toList(growable: false);
        if (keys.length <= 1) {
          continue;
        }
        if (keys.toSet().length != keys.length) {
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
          in crystalKeysByEquipment.entries) {
        final List<String> keys = entry.value
            .map(_normalizeCrystalKey)
            .where((String key) => key.isNotEmpty)
            .toList(growable: false);
        if (keys.length <= 1) {
          continue;
        }
        if (_hasDuplicateUpgradeGroup(keys, crystalUpgradeFromByKey)) {
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

  static void _appendElementRuleRecommendation({
    required List<String> recommendations,
    required BuildRuleSet ruleSet,
    required int level,
    required bool hasMainWeapon,
  }) {
    if (!hasMainWeapon || level < 60) {
      return;
    }
    final double bonus = ruleSet.elementDamageBonus;
    if (bonus <= 0) {
      return;
    }
    _addRecommendation(
      recommendations,
      'Element advantage can add about ${(bonus * 100).toStringAsFixed(0)}% damage. Prepare element-specific weapon variants.',
    );
  }

  static bool _hasDuplicateUpgradeGroup(
    List<String> crystalKeys,
    Map<String, String?> crystalUpgradeFromByKey,
  ) {
    final Set<String> seenRoots = <String>{};
    for (final String key in crystalKeys) {
      final String root = _resolveUpgradeRoot(key, crystalUpgradeFromByKey);
      if (root.isEmpty) {
        continue;
      }
      if (!seenRoots.add(root)) {
        return true;
      }
    }
    return false;
  }

  static String _resolveUpgradeRoot(
    String crystalKey,
    Map<String, String?> crystalUpgradeFromByKey,
  ) {
    String current = _normalizeCrystalKey(crystalKey);
    if (current.isEmpty) {
      return '';
    }
    final Set<String> visited = <String>{};
    while (visited.add(current)) {
      final String parent = _normalizeCrystalKey(
        crystalUpgradeFromByKey[current] ?? '',
      );
      if (parent.isEmpty) {
        return current;
      }
      current = parent;
    }
    return current;
  }

  static String _normalizeCrystalKey(String value) {
    return value.trim().toLowerCase();
  }

  static String _inferBuildId({
    required bool physicalFocus,
    required String highestStat,
    required String personalStatType,
  }) {
    final String normalizedPersonalStat = personalStatType.trim().toUpperCase();
    if (highestStat == 'VIT') {
      return 'tank';
    }
    if (normalizedPersonalStat == 'MNT') {
      return 'support';
    }
    if (!physicalFocus) {
      return 'magic_dps';
    }
    return 'physical_dps';
  }

  static String _mapRulePriorityStatToDataKey(String value) {
    final String normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    switch (normalized) {
      case 'atk_percent':
      case 'atk_flat':
        return 'atk';
      case 'matk_percent':
      case 'matk_flat':
        return 'matk';
      case 'max_mp':
        return 'maxmp';
      case 'max_hp':
        return 'maxhp';
      case 'cast_speed':
        return 'cspd';
      default:
        return normalized;
    }
  }

  static String _normalizeWeaponTypeKey(String value) {
    final String normalized = value
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (normalized.isEmpty) {
      return '';
    }
    const Map<String, String> aliases = <String, String>{
      'ONE_HAND_SWORD': '1H_SWORD',
      'TWO_HAND_SWORD': '2H_SWORD',
      'BAREHAND': 'BARE_HAND',
      'KNUCKLE': 'KNUCKLES',
      'MAGICDEVICE': 'MAGIC_DEVICE',
    };
    return aliases[normalized] ?? normalized;
  }

  static List<List<String>> _extractStatPairs(dynamic value) {
    final List<List<String>> pairs = <List<String>>[];
    _collectStatPairs(value, pairs);
    return pairs;
  }

  static void _collectStatPairs(dynamic value, List<List<String>> pairs) {
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

  static String? _preferredScalingStat(
    Map<String, dynamic> scaling, {
    required bool preferMatk,
  }) {
    final String targetKey = preferMatk ? 'matk' : 'atk';
    String? bestStat;
    num bestValue = 0;
    for (final MapEntry<String, dynamic> entry in scaling.entries) {
      final String stat = entry.key.trim().toUpperCase();
      if (stat.isEmpty) {
        continue;
      }
      final dynamic statDetails = entry.value;
      if (statDetails is! Map) {
        continue;
      }
      final num currentValue = _read(statDetails[targetKey]);
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

  static num _sumStatValue(Iterable<EquipmentStat> stats, String key) {
    final String target = key.trim().toLowerCase();
    num total = 0;
    for (final EquipmentStat stat in stats) {
      if (stat.statKey.trim().toLowerCase() != target) {
        continue;
      }
      total += stat.value;
    }
    return total;
  }

  static List<EquipmentStat> _combinedStats({
    required Iterable<EquipmentLibraryItem> equippedItems,
    required Iterable<EquipmentStat> equippedCrystalStats,
  }) {
    final List<EquipmentStat> merged = <EquipmentStat>[];
    for (final EquipmentLibraryItem item in equippedItems) {
      merged.addAll(item.stats);
    }
    merged.addAll(equippedCrystalStats);
    return merged;
  }

  static void _addRecommendation(List<String> recommendations, String value) {
    final String text = value.trim();
    if (text.isEmpty) {
      return;
    }
    if (recommendations.contains(text)) {
      return;
    }
    recommendations.add(text);
  }

  static bool _hasAnyStat(
    Iterable<EquipmentStat> stats,
    Set<String> keys,
  ) {
    if (keys.isEmpty) {
      return false;
    }
    final Set<String> normalizedKeys = keys
        .map((String key) => key.trim().toLowerCase())
        .where((String key) => key.isNotEmpty)
        .toSet();
    for (final EquipmentStat stat in stats) {
      final String statKey = stat.statKey.trim().toLowerCase();
      if (normalizedKeys.contains(statKey)) {
        return true;
      }
    }
    return false;
  }

  static String _highestStat(Map<String, dynamic> character) {
    const List<String> keys = <String>['STR', 'DEX', 'INT', 'AGI', 'VIT'];
    String bestKey = keys.first;
    num bestValue = _read(character[bestKey]);
    for (int i = 1; i < keys.length; i++) {
      final String key = keys[i];
      final num value = _read(character[key]);
      if (value > bestValue) {
        bestKey = key;
        bestValue = value;
      }
    }
    return bestKey;
  }

  static num _read(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static bool _isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }
}
