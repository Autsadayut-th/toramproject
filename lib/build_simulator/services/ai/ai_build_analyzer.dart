import 'ai_models.dart';

class AiBuildAnalyzer {
  const AiBuildAnalyzer();

  AiBuildAnalysis analyze(AiBuildContext context) {
    final List<String> recommendations = <String>[];
    final List<String> priorityStats = <String>[];

    final List<String> missingSlots = context.equipmentSlots
        .missingSlotLabels();
    if (missingSlots.isNotEmpty) {
      _addRecommendation(
        recommendations,
        'Fill empty slots first: ${missingSlots.join(', ')}.',
      );
    }

    if (!AiBuildContext.isEmpty(context.equipmentSlots.mainWeaponId) &&
        context.level >= 30 &&
        context.equipmentSlots.enhanceMain < 5) {
      _addRecommendation(
        recommendations,
        'Refine Main Weapon to at least +5. Current +${context.equipmentSlots.enhanceMain} limits damage scaling.',
      );
    }

    if ((context.equipmentSlots.enhanceArmor +
                context.equipmentSlots.enhanceHelmet) <
            6 &&
        context.level >= 30) {
      _addRecommendation(
        recommendations,
        'Increase Armor/Helmet refine for better survivability. Current total: +${context.equipmentSlots.enhanceArmor + context.equipmentSlots.enhanceHelmet}.',
      );
    }

    if (!AiBuildContext.isEmpty(context.equipmentSlots.ringId) &&
        context.level >= 40 &&
        context.equipmentSlots.enhanceRing < 3 &&
        context.mp < 400) {
      _addRecommendation(
        recommendations,
        'Refine Ring or switch to MP-focused accessories. Current MP is ${context.mp.toInt()}.',
      );
      _addPriority(priorityStats, 'Max MP');
    }

    if (context.physicalFocus) {
      if (context.critRate < context.physicalCritTarget) {
        _addRecommendation(
          recommendations,
          'Critical Rate is low (${context.critRate.toInt()}). Target at least ${context.physicalCritTarget} for physical consistency.',
        );
        _addPriority(priorityStats, 'Critical Rate');
      }
      if (context.physicalPierce < context.physicalPierceTarget &&
          context.level >= 80) {
        _addRecommendation(
          recommendations,
          'Physical Pierce is low (${context.physicalPierce.toInt()}%). Target around ${context.physicalPierceTarget}+ for high-defense targets.',
        );
        _addPriority(priorityStats, 'Physical Pierce');
      }
    } else {
      if (context.magicPierce < context.magicPierceTarget &&
          context.level >= 80) {
        _addRecommendation(
          recommendations,
          'Magic Pierce is low (${context.magicPierce.toInt()}%). Target around ${context.magicPierceTarget}+ for magic DPS consistency.',
        );
        _addPriority(priorityStats, 'Magic Pierce');
      }
      if (context.mp < context.magicMpTarget) {
        _addRecommendation(
          recommendations,
          'MP is low (${context.mp.toInt()}). Aim at least ${context.magicMpTarget} MP to keep your combo rotation stable.',
        );
        _addPriority(priorityStats, 'Max MP');
      }
      final int staffCritTarget =
          context.ruleSet?.magicStaffCritRecommended ?? 0;
      if (context.weaponTypeKey == 'STAFF' &&
          staffCritTarget > 0 &&
          context.critRate < staffCritTarget) {
        _addRecommendation(
          recommendations,
          'Staff magic-crit target is high ($staffCritTarget). Current Crit Rate ${context.critRate.toInt()} may be insufficient.',
        );
        _addPriority(priorityStats, 'Critical Rate');
      }
    }

    if (context.stability < 50 && context.level >= 50) {
      _addRecommendation(
        recommendations,
        'Stability is only ${context.stability.toInt()}%. Add Stability stats to reduce damage variance.',
      );
      _addPriority(priorityStats, 'Stability');
    }

    if (context.accuracy < context.expectedAccuracy) {
      _addRecommendation(
        recommendations,
        'Accuracy (${context.accuracy.toInt()}) may be low for Lv.${context.level}. Aim around ${context.expectedAccuracy}+.',
      );
      _addPriority(priorityStats, 'Accuracy');
    }

    if (context.hp < context.expectedHp) {
      _addRecommendation(
        recommendations,
        'HP (${context.hp.toInt()}) is low for Lv.${context.level}. Add VIT/HP stats to avoid one-shot deaths.',
      );
      _addPriority(priorityStats, 'HP');
    }

    if ((context.def + context.mdef) < context.expectedDefense) {
      _addRecommendation(
        recommendations,
        'DEF + MDEF is ${(context.def + context.mdef).toInt()}, below target ${context.expectedDefense} for Lv.${context.level}.',
      );
      _addPriority(priorityStats, 'DEF / MDEF');
    }

    if (context.highestStat == 'INT' && context.atk > (context.matk * 1.2)) {
      _addRecommendation(
        recommendations,
        'Your main stat looks INT, but ATK is much higher than MATK. Check weapon/stat synergy.',
      );
    }

    if ((context.highestStat == 'STR' ||
            context.highestStat == 'DEX' ||
            context.highestStat == 'AGI') &&
        context.matk > (context.atk * 1.2)) {
      _addRecommendation(
        recommendations,
        'Your main stat looks physical, but MATK is much higher than ATK. Recheck build direction.',
      );
    }

    final bool hasCritOrPierce = context.hasAnyStat(<String>{
      'critical_rate',
      'physical_pierce',
      'magic_pierce',
    });
    if (!hasCritOrPierce && context.level >= 60) {
      _addRecommendation(
        recommendations,
        'Most equipment lacks Crit/Pierce stats. Add at least one offensive stat source.',
      );
      _addPriority(
        priorityStats,
        context.physicalFocus ? 'Critical Rate' : 'Magic Pierce',
      );
    }

    if (context.personalStatType == 'CRT' &&
        context.personalStatValue == 0 &&
        context.physicalFocus) {
      _addRecommendation(
        recommendations,
        'Set personal stat CRT points if this is a physical DPS build.',
      );
      _addPriority(priorityStats, 'Personal Stat CRT');
    }

    return AiBuildAnalysis(
      recommendations: recommendations.toList(growable: false),
      priorityStats: priorityStats.toList(growable: false),
    );
  }

  void _addRecommendation(List<String> recommendations, String value) {
    final String text = value.trim();
    if (text.isEmpty || recommendations.contains(text)) {
      return;
    }
    recommendations.add(text);
  }

  void _addPriority(List<String> priorityStats, String value) {
    final String text = value.trim();
    if (text.isEmpty || priorityStats.contains(text)) {
      return;
    }
    priorityStats.add(text);
  }
}
