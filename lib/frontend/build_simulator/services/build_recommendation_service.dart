import '../../equipment_library/models/equipment_library_item.dart';

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
  }) {
    final List<String> recommendations = <String>[];
    final num atk = _read(summary['ATK']);
    final num matk = _read(summary['MATK']);
    final num def = _read(summary['DEF']);
    final num mdef = _read(summary['MDEF']);
    final num critRate = _read(summary['CritRate']);
    final num physicalPierce = _read(summary['PhysicalPierce']);
    final num elementPierce = _read(summary['ElementPierce']);
    final num stability = _read(summary['Stability']);
    final num accuracy = _read(summary['Accuracy']);
    final num hp = _read(summary['HP']);
    final num mp = _read(summary['MP']);

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
      recommendations.add(
        'Fill empty slots first: ${missingSlots.join(', ')}.',
      );
    }

    if (!_isEmpty(mainWeaponId) && level >= 30 && enhanceMain < 5) {
      recommendations.add(
        'Refine Main Weapon to at least +5. Current +$enhanceMain limits damage scaling.',
      );
    }
    if ((enhanceArmor + enhanceHelmet) < 6 && level >= 30) {
      recommendations.add(
        'Increase Armor/Helmet refine for better survivability. Current total: +${enhanceArmor + enhanceHelmet}.',
      );
    }
    if (!_isEmpty(ringId) && level >= 40 && enhanceRing < 3 && mp < 400) {
      recommendations.add(
        'Refine Ring or switch to MP-focused accessories. Current MP is ${mp.toInt()}.',
      );
    }

    final bool physicalFocus = atk >= matk;
    if (physicalFocus) {
      if (critRate < 70) {
        recommendations.add(
          'Critical Rate is low (${critRate.toInt()}%). Add CRT personal stat or Crit gear for consistent damage.',
        );
      }
      if (physicalPierce < 15 && level >= 80) {
        recommendations.add(
          'Physical Pierce is low (${physicalPierce.toInt()}%). Add pierce stats for high-defense targets.',
        );
      }
    } else {
      if (elementPierce < 15 && level >= 80) {
        recommendations.add(
          'Magic Pierce is low (${elementPierce.toInt()}%). Add more pierce for magic DPS consistency.',
        );
      }
      if (mp < 300) {
        recommendations.add(
          'MP is low (${mp.toInt()}). Add MP/CSPD sources to keep your combo rotation stable.',
        );
      }
    }

    if (stability < 50 && level >= 50) {
      recommendations.add(
        'Stability is only ${stability.toInt()}%. Add Stability stats to reduce damage variance.',
      );
    }

    final int expectedAccuracy = (level + 20).clamp(30, 320);
    if (accuracy < expectedAccuracy) {
      recommendations.add(
        'Accuracy (${accuracy.toInt()}) may be low for Lv.$level. Aim around $expectedAccuracy+.',
      );
    }

    final int expectedHp = (700 + (level * 20)).clamp(700, 7000);
    if (hp < expectedHp) {
      recommendations.add(
        'HP (${hp.toInt()}) is low for Lv.$level. Add VIT/HP stats to avoid one-shot deaths.',
      );
    }

    final int expectedDefense = (120 + (level * 2)).clamp(120, 1000);
    if ((def + mdef) < expectedDefense) {
      recommendations.add(
        'DEF + MDEF is ${(def + mdef).toInt()}, below target $expectedDefense for Lv.$level.',
      );
    }

    final String highestStat = _highestStat(character);
    if (highestStat == 'INT' && atk > (matk * 1.2)) {
      recommendations.add(
        'Your main stat looks INT, but ATK is much higher than MATK. Check weapon/stat synergy.',
      );
    }
    if ((highestStat == 'STR' ||
            highestStat == 'DEX' ||
            highestStat == 'AGI') &&
        matk > (atk * 1.2)) {
      recommendations.add(
        'Your main stat looks physical, but MATK is much higher than ATK. Recheck build direction.',
      );
    }

    final bool hasCritOrPierce = _hasAnyStat(equippedItems, <String>{
      'critical_rate',
      'physical_pierce',
      'magic_pierce',
    });
    if (!hasCritOrPierce && level >= 60) {
      recommendations.add(
        'Most equipment lacks Crit/Pierce stats. Add at least one offensive stat source.',
      );
    }

    if (personalStatType.trim().toUpperCase() == 'CRT' &&
        personalStatValue == 0 &&
        physicalFocus) {
      recommendations.add(
        'Set personal stat CRT points if this is a physical DPS build.',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        'Build is balanced right now. Focus next on refining weapon/armor and optimizing crystals.',
      );
      recommendations.add(
        'Prepare a boss-specific variant: one setup for survivability and one for maximum DPS.',
      );
      recommendations.add(
        'Track your stat goals each 10 levels so equipment upgrades stay efficient.',
      );
    }

    return recommendations.take(6).toList(growable: false);
  }

  static bool _hasAnyStat(
    Iterable<EquipmentLibraryItem> items,
    Set<String> keys,
  ) {
    for (final EquipmentLibraryItem item in items) {
      for (final EquipmentStat stat in item.stats) {
        if (keys.contains(stat.statKey.toLowerCase())) {
          return true;
        }
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
