import '../../equipment_library/models/equipment_library_item.dart';
import 'build_rule_set_service.dart';

class BuildCalculatorService {
  static const Map<String, num> summaryTemplate = <String, num>{
    'ATK': 0,
    'MATK': 0,
    'DEF': 0,
    'MDEF': 0,
    'STR': 0,
    'DEX': 0,
    'INT': 0,
    'AGI': 0,
    'VIT': 0,
    'ASPD': 0,
    'CSPD': 0,
    'FLEE': 0,
    'CritRate': 0,
    'PhysicalPierce': 0,
    'MagicPierce': 0,
    'ElementPierce': 0,
    'Accuracy': 0,
    'Stability': 0,
    'HP': 0,
    'MP': 0,
  };

  static const List<String> characterStatKeys = <String>[
    'STR',
    'DEX',
    'INT',
    'AGI',
    'VIT',
  ];

  static const List<String> personalStatOptions = <String>[
    'CRT',
    'LUK',
    'TEC',
    'MNT',
  ];

  static const Set<String> percentDisplaySummaryKeys = <String>{
    'CritRate',
    'PhysicalPierce',
    'MagicPierce',
    'ElementPierce',
    'Stability',
  };

  static const Set<String> _primaryStatKeys = <String>{
    'STR',
    'DEX',
    'INT',
    'AGI',
    'VIT',
  };

  static const Set<String> _pointBasedPercentSummaryKeys = <String>{
    'PhysicalPierce',
    'MagicPierce',
    'ElementPierce',
    'Stability',
  };

  static const String _weaponAtkKey = '_WEAPON_ATK';
  static const String _baseValueType = 'base';

  static const Map<String, String> _summaryKeyByStatKey = <String, String>{
    'atk': 'ATK',
    'matk': 'MATK',
    'def': 'DEF',
    'mdef': 'MDEF',
    'str': 'STR',
    'dex': 'DEX',
    'int': 'INT',
    'agi': 'AGI',
    'vit': 'VIT',
    'aspd': 'ASPD',
    'cspd': 'CSPD',
    'cast_speed': 'CSPD',
    'flee': 'FLEE',
    'dodge': 'FLEE',
    'hit': 'Accuracy',
    'accuracy': 'Accuracy',
    'critical_rate': 'CritRate',
    'physical_pierce': 'PhysicalPierce',
    'magic_pierce': 'MagicPierce',
    'stability': 'Stability',
    'hp': 'HP',
    'maxhp': 'HP',
    'mp': 'MP',
    'maxmp': 'MP',
    'weapon_atk': _weaponAtkKey,
  };

  static const Map<String, double> _defArmorModifier = <String, double>{
    'heavy': 1,
    'light': 0.25,
    'normal': 1,
    'no_armor': 0.1,
  };

  static const Map<String, double> _mdefArmorModifier = <String, double>{
    'heavy': 0.25,
    'light': 1,
    'normal': 1,
    'no_armor': 0.1,
  };

  static const Map<String, double> _fleeArmorModifier = <String, double>{
    'heavy': 0.75,
    'light': 2,
    'normal': 1,
    'no_armor': 2,
  };

  static const Map<String, double> _aspdBaseByWeapon = <String, double>{
    '1H_SWORD': 100,
    'DUAL_SWORD': 100,
    '2H_SWORD': 50,
    'BOW': 75,
    'BOWGUN': 50,
    'STAFF': 50,
    'MAGIC_DEVICE': 150,
    'KNUCKLES': 120,
    'HALBERD': 25,
    'KATANA': 200,
    'BARE_HAND': 100,
  };

  static const Map<String, Map<String, Map<String, double>>> _weaponScaling =
      <String, Map<String, Map<String, double>>>{
        '1H_SWORD': <String, Map<String, double>>{
          'STR': <String, double>{'atk': 2, 'stability': 0.025, 'aspd': 0.2},
          'INT': <String, double>{'matk': 3},
          'AGI': <String, double>{'aspd': 4.2},
          'DEX': <String, double>{'atk': 2, 'matk': 1, 'stability': 0.075},
        },
        'DUAL_SWORD': <String, Map<String, double>>{
          'STR': <String, double>{'atk': 1, 'stability': 0.025, 'aspd': 0.2},
          'INT': <String, double>{'matk': 3},
          'AGI': <String, double>{'atk': 1, 'aspd': 4.2},
          'DEX': <String, double>{'atk': 2, 'matk': 1, 'stability': 0.075},
        },
        '2H_SWORD': <String, Map<String, double>>{
          'STR': <String, double>{'atk': 3, 'aspd': 0.2},
          'INT': <String, double>{'matk': 3},
          'AGI': <String, double>{'aspd': 2.1},
          'DEX': <String, double>{'atk': 1, 'matk': 1, 'stability': 0.1},
        },
        'BOW': <String, Map<String, double>>{
          'STR': <String, double>{'atk': 1, 'stability': 0.05},
          'INT': <String, double>{'matk': 3},
          'AGI': <String, double>{'aspd': 3.1},
          'DEX': <String, double>{
            'atk': 3,
            'matk': 1,
            'stability': 0.05,
            'aspd': 0.2,
          },
        },
        'BOWGUN': <String, Map<String, double>>{
          'STR': <String, double>{'stability': 0.05},
          'INT': <String, double>{'matk': 3},
          'AGI': <String, double>{'aspd': 2.2},
          'DEX': <String, double>{'atk': 4, 'matk': 1, 'aspd': 0.2},
        },
        'STAFF': <String, Map<String, double>>{
          'STR': <String, double>{'atk': 3, 'stability': 0.05},
          'INT': <String, double>{'atk': 1, 'matk': 4, 'aspd': 0.2},
          'AGI': <String, double>{'aspd': 1.8},
          'DEX': <String, double>{'matk': 1},
        },
        'MAGIC_DEVICE': <String, Map<String, double>>{
          'INT': <String, double>{'atk': 2, 'matk': 4, 'aspd': 0.2},
          'AGI': <String, double>{'atk': 2, 'aspd': 4},
          'DEX': <String, double>{'matk': 1, 'stability': 0.1},
        },
        'KNUCKLES': <String, Map<String, double>>{
          'STR': <String, double>{'aspd': 0.1},
          'INT': <String, double>{'matk': 4},
          'AGI': <String, double>{'atk': 2, 'aspd': 4.6},
          'DEX': <String, double>{
            'atk': 0.5,
            'matk': 1,
            'stability': 0.025,
            'aspd': 0.1,
          },
        },
        'HALBERD': <String, Map<String, double>>{
          'STR': <String, double>{'atk': 2.5, 'stability': 0.05, 'aspd': 0.2},
          'INT': <String, double>{'matk': 2},
          'AGI': <String, double>{'atk': 1.5, 'matk': 1, 'aspd': 3.5},
          'DEX': <String, double>{'matk': 1, 'stability': 0.05},
        },
        'KATANA': <String, Map<String, double>>{
          'STR': <String, double>{'atk': 1.5, 'stability': 0.075, 'aspd': 0.3},
          'INT': <String, double>{'matk': 2},
          'AGI': <String, double>{'matk': 1, 'aspd': 3.9},
          'DEX': <String, double>{'atk': 2.5, 'matk': 1, 'stability': 0.025},
        },
        'BARE_HAND': <String, Map<String, double>>{
          'STR': <String, double>{'atk': 1},
          'INT': <String, double>{'matk': 3},
          'AGI': <String, double>{'aspd': 9.6},
          'DEX': <String, double>{'matk': 1},
        },
      };

  static Map<String, num> calculateSummary({
    required Map<String, dynamic> character,
    required int level,
    required String personalStatType,
    required int personalStatValue,
    required int enhanceMain,
    required int enhanceSub,
    required int enhanceArmor,
    required int enhanceHelmet,
    required int enhanceRing,
    required String armorState,
    required EquipmentLibraryItem? mainWeapon,
    required EquipmentLibraryItem? subWeapon,
    required EquipmentLibraryItem? armor,
    required EquipmentLibraryItem? helmet,
    required EquipmentLibraryItem? ring,
    required Iterable<EquipmentStat> equippedCrystalStats,
    required Iterable<EquipmentStat> avatarStats,
    required Map<String, List<String>> mainToAllowedSubTypes,
    BuildRuleSet? ruleSet,
  }) {
    final int normalizedLevel = level.clamp(1, 999).toInt();
    final String normalizedPersonalType = personalStatType.trim().toUpperCase();
    final int normalizedPersonalValue = personalStatValue.clamp(0, 255).toInt();
    final BuildCalculationContext context = buildCalculationContext(
      armorState: armorState,
      mainWeapon: mainWeapon,
      subWeapon: subWeapon,
      armor: armor,
      helmet: helmet,
      ring: ring,
      equippedCrystalStats: equippedCrystalStats,
      avatarStats: avatarStats,
      mainToAllowedSubTypes: mainToAllowedSubTypes,
    );
    return calculateSummaryFromContext(
      context: context,
      character: character,
      level: normalizedLevel,
      personalStatType: normalizedPersonalType,
      personalStatValue: normalizedPersonalValue,
      enhanceMain: enhanceMain,
      enhanceSub: enhanceSub,
      enhanceArmor: enhanceArmor,
      enhanceHelmet: enhanceHelmet,
      enhanceRing: enhanceRing,
      ruleSet: ruleSet,
    );
  }

  static BuildCalculationContext buildCalculationContext({
    required String armorState,
    required EquipmentLibraryItem? mainWeapon,
    required EquipmentLibraryItem? subWeapon,
    required EquipmentLibraryItem? armor,
    required EquipmentLibraryItem? helmet,
    required EquipmentLibraryItem? ring,
    required Iterable<EquipmentStat> equippedCrystalStats,
    required Iterable<EquipmentStat> avatarStats,
    required Map<String, List<String>> mainToAllowedSubTypes,
  }) {
    final _CalculationBuckets buckets = _CalculationBuckets();
    final String normalizedMainWeaponType = _normalizeWeaponType(
      mainWeapon?.type,
    );
    final String normalizedSubWeaponType = _normalizeWeaponType(
      subWeapon?.type,
    );
    final bool isSubWeaponAllowed = _isSubWeaponAllowedByRules(
      mainWeaponType: normalizedMainWeaponType,
      subWeaponType: normalizedSubWeaponType,
      mainToAllowedSubTypes: mainToAllowedSubTypes,
    );
    final String combatWeaponType = _resolveCombatWeaponType(
      mainWeaponType: normalizedMainWeaponType,
      subWeaponType: normalizedSubWeaponType,
    );
    final String effectiveArmorState = armor == null
        ? 'no_armor'
        : _normalizeArmorState(armorState);

    _accumulateItemStats(
      item: mainWeapon,
      slot: 'main',
      combatWeaponType: combatWeaponType,
      mainWeaponType: normalizedMainWeaponType,
      subWeaponType: normalizedSubWeaponType,
      armorState: effectiveArmorState,
      isSubWeaponAllowed: isSubWeaponAllowed,
      buckets: buckets,
    );
    _accumulateItemStats(
      item: subWeapon,
      slot: 'sub',
      combatWeaponType: combatWeaponType,
      mainWeaponType: normalizedMainWeaponType,
      subWeaponType: normalizedSubWeaponType,
      armorState: effectiveArmorState,
      isSubWeaponAllowed: isSubWeaponAllowed,
      buckets: buckets,
    );
    _accumulateItemStats(
      item: armor,
      slot: 'armor',
      combatWeaponType: combatWeaponType,
      mainWeaponType: normalizedMainWeaponType,
      subWeaponType: normalizedSubWeaponType,
      armorState: effectiveArmorState,
      isSubWeaponAllowed: isSubWeaponAllowed,
      buckets: buckets,
    );
    _accumulateItemStats(
      item: helmet,
      slot: 'helmet',
      combatWeaponType: combatWeaponType,
      mainWeaponType: normalizedMainWeaponType,
      subWeaponType: normalizedSubWeaponType,
      armorState: effectiveArmorState,
      isSubWeaponAllowed: isSubWeaponAllowed,
      buckets: buckets,
    );
    _accumulateItemStats(
      item: ring,
      slot: 'ring',
      combatWeaponType: combatWeaponType,
      mainWeaponType: normalizedMainWeaponType,
      subWeaponType: normalizedSubWeaponType,
      armorState: effectiveArmorState,
      isSubWeaponAllowed: isSubWeaponAllowed,
      buckets: buckets,
    );
    for (final EquipmentStat stat in equippedCrystalStats) {
      _accumulateStat(
        stat: stat,
        slot: 'crystal',
        combatWeaponType: combatWeaponType,
        mainWeaponType: normalizedMainWeaponType,
        subWeaponType: normalizedSubWeaponType,
        armorState: effectiveArmorState,
        isSubWeaponAllowed: isSubWeaponAllowed,
        buckets: buckets,
      );
    }
    for (final EquipmentStat stat in avatarStats) {
      _accumulateStat(
        stat: stat,
        slot: 'avatar',
        combatWeaponType: combatWeaponType,
        mainWeaponType: normalizedMainWeaponType,
        subWeaponType: normalizedSubWeaponType,
        armorState: effectiveArmorState,
        isSubWeaponAllowed: isSubWeaponAllowed,
        buckets: buckets,
      );
    }

    return BuildCalculationContext(
      primaryPercentByKey: Map<String, double>.from(
        buckets.primaryPercentByKey,
      ),
      primaryFlatByKey: Map<String, double>.from(buckets.primaryFlatByKey),
      derivedPercentByKey: Map<String, double>.from(
        buckets.derivedPercentByKey,
      ),
      derivedFlatByKey: Map<String, double>.from(buckets.derivedFlatByKey),
      mainWeaponAtkBase: buckets.mainWeaponAtkBase,
      supplementalWeaponAtkBase: buckets.supplementalWeaponAtkBase,
      weaponAtkFlat: buckets.weaponAtkFlat,
      weaponAtkPercent: buckets.weaponAtkPercent,
      mainWeaponBaseStability: buckets.mainWeaponBaseStability,
      supplementalStabilityBase: buckets.supplementalStabilityBase,
      armorDefBase: buckets.armorDefBase,
      helmetDefBase: buckets.helmetDefBase,
      ringDefBase: buckets.ringDefBase,
      otherEquipmentDefBase: buckets.otherEquipmentDefBase,
      armorMdefBase: buckets.armorMdefBase,
      helmetMdefBase: buckets.helmetMdefBase,
      ringMdefBase: buckets.ringMdefBase,
      otherEquipmentMdefBase: buckets.otherEquipmentMdefBase,
      combatWeaponType: combatWeaponType,
      mainWeaponType: normalizedMainWeaponType,
      subWeaponType: normalizedSubWeaponType,
      effectiveArmorState: effectiveArmorState,
      isSubWeaponAllowed: isSubWeaponAllowed,
      subWeaponHasBaseWeaponAtk: _itemHasBaseWeaponAtk(subWeapon),
    );
  }

  static Map<String, num> calculateSummaryFromContext({
    required BuildCalculationContext context,
    required Map<String, dynamic> character,
    required int level,
    required String personalStatType,
    required int personalStatValue,
    required int enhanceMain,
    required int enhanceSub,
    required int enhanceArmor,
    required int enhanceHelmet,
    required int enhanceRing,
    BuildRuleSet? ruleSet,
  }) {
    final Map<String, double> effectivePrimaryStats = _effectivePrimaryStats(
      character: character,
      percentByKey: context.primaryPercentByKey,
      flatByKey: context.primaryFlatByKey,
    );
    final double strValue = effectivePrimaryStats['STR'] ?? 0;
    final double dexValue = effectivePrimaryStats['DEX'] ?? 0;
    final double intValue = effectivePrimaryStats['INT'] ?? 0;
    final double agiValue = effectivePrimaryStats['AGI'] ?? 0;
    final double vitValue = effectivePrimaryStats['VIT'] ?? 0;

    final double effectiveWeaponAtk = _effectiveWeaponAtk(
      mainWeaponAtkBase: context.mainWeaponAtkBase,
      supplementalWeaponAtkBase: context.supplementalWeaponAtkBase,
      weaponAtkFlat: context.weaponAtkFlat,
      weaponAtkPercent: context.weaponAtkPercent,
      enhanceMain: enhanceMain,
      enhanceSub: enhanceSub,
      mainWeaponType: context.mainWeaponType,
      combatWeaponType: context.combatWeaponType,
      subWeaponType: context.subWeaponType,
      isSubWeaponAllowed: context.isSubWeaponAllowed,
      subWeaponHasBaseWeaponAtk: context.subWeaponHasBaseWeaponAtk,
      ruleSet: ruleSet,
    );
    final double baseStability = _baseStability(
      combatWeaponType: context.combatWeaponType,
      mainWeaponBaseStability: context.mainWeaponBaseStability,
      supplementalStabilityBase: context.supplementalStabilityBase,
      strValue: strValue,
      dexValue: dexValue,
      intValue: intValue,
      agiValue: agiValue,
      vitValue: vitValue,
    );
    final double refinedEquipmentDefBase = _effectiveRefinedEquipmentBase(
      armorBase: context.armorDefBase,
      helmetBase: context.helmetDefBase,
      ringBase: context.ringDefBase,
      otherBase: context.otherEquipmentDefBase,
      enhanceArmor: enhanceArmor,
      enhanceHelmet: enhanceHelmet,
      enhanceRing: enhanceRing,
      ruleSet: ruleSet,
    );
    final double refinedEquipmentMdefBase = _effectiveRefinedEquipmentBase(
      armorBase: context.armorMdefBase,
      helmetBase: context.helmetMdefBase,
      ringBase: context.ringMdefBase,
      otherBase: context.otherEquipmentMdefBase,
      enhanceArmor: enhanceArmor,
      enhanceHelmet: enhanceHelmet,
      enhanceRing: enhanceRing,
      ruleSet: ruleSet,
    );

    final Map<String, double> derivedBaseByKey = <String, double>{
      'ATK':
          level +
          effectiveWeaponAtk +
          _weaponScaleValue(
            combatWeaponType: context.combatWeaponType,
            targetKey: 'atk',
            strValue: strValue,
            dexValue: dexValue,
            intValue: intValue,
            agiValue: agiValue,
            vitValue: vitValue,
          ),
      'MATK':
          level +
          effectiveWeaponAtk +
          _weaponScaleValue(
            combatWeaponType: context.combatWeaponType,
            targetKey: 'matk',
            strValue: strValue,
            dexValue: dexValue,
            intValue: intValue,
            agiValue: agiValue,
            vitValue: vitValue,
          ),
      'DEF':
          level +
          (vitValue * _defArmorModifier[context.effectiveArmorState]!) +
          refinedEquipmentDefBase,
      'MDEF':
          level +
          (intValue * _mdefArmorModifier[context.effectiveArmorState]!) +
          refinedEquipmentMdefBase,
      'ASPD':
          level +
          (_aspdBaseByWeapon[context.combatWeaponType] ?? 0) +
          _weaponScaleValue(
            combatWeaponType: context.combatWeaponType,
            targetKey: 'aspd',
            strValue: strValue,
            dexValue: dexValue,
            intValue: intValue,
            agiValue: agiValue,
            vitValue: vitValue,
          ),
      'CSPD': level + (dexValue * 2.94) + (agiValue * 1.16),
      'FLEE':
          level + (agiValue * _fleeArmorModifier[context.effectiveArmorState]!),
      'CritRate':
          25 + (personalStatType == 'CRT' ? personalStatValue / 3.4 : 0),
      'PhysicalPierce': 0,
      'MagicPierce': 0,
      'Accuracy': level + dexValue,
      'Stability': baseStability,
      'HP': _baseHp(
        level: level,
        vitValue: vitValue,
        armorState: context.effectiveArmorState,
      ),
      'MP': _baseMp(
        level: level,
        intValue: intValue,
        personalStatType: personalStatType,
        personalStatValue: personalStatValue,
      ),
    };

    final Map<String, num> nextSummary = Map<String, num>.from(summaryTemplate);
    for (final String key in summaryTemplate.keys) {
      if (_primaryStatKeys.contains(key)) {
        nextSummary[key] = _panelValue(effectivePrimaryStats[key] ?? 0);
        continue;
      }
      if (key == 'ElementPierce') {
        nextSummary[key] = nextSummary['MagicPierce'] ?? 0;
        continue;
      }
      final double baseValue = derivedBaseByKey[key] ?? 0;
      final double flatValue = (context.derivedFlatByKey[key] ?? 0).toDouble();
      final double percentValue = (context.derivedPercentByKey[key] ?? 0)
          .toDouble();
      if (_pointBasedPercentSummaryKeys.contains(key)) {
        nextSummary[key] = _panelValue(baseValue + flatValue + percentValue);
        continue;
      }
      nextSummary[key] = _panelValue(
        (baseValue * (1 + (percentValue / 100))) + flatValue,
      );
    }

    nextSummary['ElementPierce'] = nextSummary['MagicPierce'] ?? 0;
    return nextSummary;
  }

  static void _accumulateItemStats({
    required EquipmentLibraryItem? item,
    required String slot,
    required String combatWeaponType,
    required String mainWeaponType,
    required String subWeaponType,
    required String armorState,
    required bool isSubWeaponAllowed,
    required _CalculationBuckets buckets,
  }) {
    if (item == null) {
      return;
    }
    for (final EquipmentStat stat in item.stats) {
      _accumulateStat(
        stat: stat,
        slot: slot,
        combatWeaponType: combatWeaponType,
        mainWeaponType: mainWeaponType,
        subWeaponType: subWeaponType,
        armorState: armorState,
        isSubWeaponAllowed: isSubWeaponAllowed,
        buckets: buckets,
      );
    }
  }

  static void _accumulateStat({
    required EquipmentStat stat,
    required String slot,
    required String combatWeaponType,
    required String mainWeaponType,
    required String subWeaponType,
    required String armorState,
    required bool isSubWeaponAllowed,
    required _CalculationBuckets buckets,
  }) {
    if (!_matchesCondition(
      stat.condition,
      combatWeaponType: combatWeaponType,
      mainWeaponType: mainWeaponType,
      subWeaponType: subWeaponType,
      armorState: armorState,
    )) {
      return;
    }

    final String normalizedStatKey = stat.statKey.trim().toLowerCase();
    final String? targetKey = _summaryKeyByStatKey[normalizedStatKey];
    if (targetKey == null) {
      return;
    }

    final String normalizedValueType = stat.valueType.trim().toLowerCase();
    final double value = stat.value.toDouble();

    if (targetKey == _weaponAtkKey) {
      if (normalizedValueType == _baseValueType) {
        if (slot == 'main') {
          buckets.mainWeaponAtkBase += value;
        } else if (_subWeaponAddsWeaponAtk(
          mainWeaponType: mainWeaponType,
          combatWeaponType: combatWeaponType,
          subWeaponType: subWeaponType,
          isSubWeaponAllowed: isSubWeaponAllowed,
        )) {
          buckets.supplementalWeaponAtkBase += value;
        }
        return;
      }
      if (normalizedValueType == 'percent') {
        buckets.weaponAtkPercent += value;
      } else {
        buckets.weaponAtkFlat += value;
      }
      return;
    }

    if (targetKey == 'DEF' && normalizedValueType == _baseValueType) {
      _addEquipmentBaseForSlot(
        slot: slot,
        value: value,
        onArmor: (double v) => buckets.armorDefBase += v,
        onHelmet: (double v) => buckets.helmetDefBase += v,
        onRing: (double v) => buckets.ringDefBase += v,
        onOther: (double v) => buckets.otherEquipmentDefBase += v,
      );
      return;
    }
    if (targetKey == 'MDEF' && normalizedValueType == _baseValueType) {
      _addEquipmentBaseForSlot(
        slot: slot,
        value: value,
        onArmor: (double v) => buckets.armorMdefBase += v,
        onHelmet: (double v) => buckets.helmetMdefBase += v,
        onRing: (double v) => buckets.ringMdefBase += v,
        onOther: (double v) => buckets.otherEquipmentMdefBase += v,
      );
      return;
    }
    if (targetKey == 'Stability' && normalizedValueType == _baseValueType) {
      if (slot == 'main') {
        buckets.mainWeaponBaseStability += value;
      } else if (_subWeaponAddsStability(
        mainWeaponType: mainWeaponType,
        combatWeaponType: combatWeaponType,
        subWeaponType: subWeaponType,
        isSubWeaponAllowed: isSubWeaponAllowed,
      )) {
        buckets.supplementalStabilityBase += value;
      }
      return;
    }

    final bool isPercent = normalizedValueType == 'percent';
    if (_primaryStatKeys.contains(targetKey)) {
      if (isPercent) {
        buckets.primaryPercentByKey[targetKey] =
            (buckets.primaryPercentByKey[targetKey] ?? 0) + value;
      } else {
        buckets.primaryFlatByKey[targetKey] =
            (buckets.primaryFlatByKey[targetKey] ?? 0) + value;
      }
      return;
    }

    if (isPercent && !_pointBasedPercentSummaryKeys.contains(targetKey)) {
      buckets.derivedPercentByKey[targetKey] =
          (buckets.derivedPercentByKey[targetKey] ?? 0) + value;
      return;
    }
    buckets.derivedFlatByKey[targetKey] =
        (buckets.derivedFlatByKey[targetKey] ?? 0) + value;
  }

  static Map<String, double> _effectivePrimaryStats({
    required Map<String, dynamic> character,
    required Map<String, double> percentByKey,
    required Map<String, double> flatByKey,
  }) {
    final Map<String, double> next = <String, double>{};
    for (final String key in characterStatKeys) {
      final double baseValue = _readNumericValue(character[key]).toDouble();
      final double percentValue = percentByKey[key] ?? 0;
      final double flatValue = flatByKey[key] ?? 0;
      next[key] = _panelValue(
        (baseValue * (1 + (percentValue / 100))) + flatValue,
      ).toDouble();
    }
    return next;
  }

  static double _effectiveWeaponAtk({
    required double mainWeaponAtkBase,
    required double supplementalWeaponAtkBase,
    required double weaponAtkFlat,
    required double weaponAtkPercent,
    required int enhanceMain,
    required int enhanceSub,
    required String mainWeaponType,
    required String combatWeaponType,
    required String subWeaponType,
    required bool isSubWeaponAllowed,
    required bool subWeaponHasBaseWeaponAtk,
    BuildRuleSet? ruleSet,
  }) {
    final double refinedMainWeaponAtk = _refinedWeaponAtk(
      baseWeaponAtk: mainWeaponAtkBase,
      refineLevel: enhanceMain,
      ruleSet: ruleSet,
    );
    final double refinedSubWeaponAtk =
        _subWeaponAddsWeaponAtk(
          mainWeaponType: mainWeaponType,
          combatWeaponType: combatWeaponType,
          subWeaponType: subWeaponType,
          isSubWeaponAllowed: isSubWeaponAllowed,
        )
        ? _refinedWeaponAtk(
            baseWeaponAtk: supplementalWeaponAtkBase,
            refineLevel:
                _subWeaponUsesWeaponRefine(
                  subWeaponType: subWeaponType,
                  subWeaponHasBaseWeaponAtk: subWeaponHasBaseWeaponAtk,
                )
                ? enhanceSub
                : 0,
            ruleSet: ruleSet,
          )
        : supplementalWeaponAtkBase;
    return (refinedMainWeaponAtk + refinedSubWeaponAtk + weaponAtkFlat) *
        (1 + (weaponAtkPercent / 100));
  }

  static double _effectiveRefinedEquipmentBase({
    required double armorBase,
    required double helmetBase,
    required double ringBase,
    required double otherBase,
    required int enhanceArmor,
    required int enhanceHelmet,
    required int enhanceRing,
    BuildRuleSet? ruleSet,
  }) {
    return _refinedEquipmentBaseValue(
          baseValue: armorBase,
          refineLevel: enhanceArmor,
          ruleSet: ruleSet,
        ) +
        _refinedEquipmentBaseValue(
          baseValue: helmetBase,
          refineLevel: enhanceHelmet,
          ruleSet: ruleSet,
        ) +
        _refinedEquipmentBaseValue(
          baseValue: ringBase,
          refineLevel: enhanceRing,
          ruleSet: ruleSet,
        ) +
        otherBase;
  }

  static double _refinedWeaponAtk({
    required double baseWeaponAtk,
    required int refineLevel,
    BuildRuleSet? ruleSet,
  }) {
    if (baseWeaponAtk <= 0 || refineLevel <= 0) {
      return baseWeaponAtk;
    }
    final int normalizedRefine = refineLevel.clamp(0, 15).toInt();
    final double flatRefineBonus =
        ruleSet?.refineFlatForLevel(normalizedRefine) ??
        normalizedRefine.toDouble();
    final double percentRefineBonus =
        ruleSet?.refinePercentForLevel(normalizedRefine) ??
        (normalizedRefine * normalizedRefine).toDouble();
    return baseWeaponAtk +
        flatRefineBonus +
        (baseWeaponAtk * percentRefineBonus / 100);
  }

  static double _refinedEquipmentBaseValue({
    required double baseValue,
    required int refineLevel,
    BuildRuleSet? ruleSet,
  }) {
    if (baseValue <= 0 || refineLevel <= 0) {
      return baseValue;
    }
    final int normalizedRefine = refineLevel.clamp(0, 15).toInt();
    final double flatRefineBonus =
        ruleSet?.refineFlatForLevel(normalizedRefine) ??
        normalizedRefine.toDouble();
    final double percentRefineBonus =
        ruleSet?.refinePercentForLevel(normalizedRefine) ??
        (normalizedRefine * normalizedRefine).toDouble();
    return baseValue + flatRefineBonus + (baseValue * percentRefineBonus / 100);
  }

  static void _addEquipmentBaseForSlot({
    required String slot,
    required double value,
    required void Function(double) onArmor,
    required void Function(double) onHelmet,
    required void Function(double) onRing,
    required void Function(double) onOther,
  }) {
    switch (slot) {
      case 'armor':
        onArmor(value);
        return;
      case 'helmet':
        onHelmet(value);
        return;
      case 'ring':
        onRing(value);
        return;
      default:
        onOther(value);
        return;
    }
  }

  static double _baseStability({
    required String combatWeaponType,
    required double mainWeaponBaseStability,
    required double supplementalStabilityBase,
    required double strValue,
    required double dexValue,
    required double intValue,
    required double agiValue,
    required double vitValue,
  }) {
    final double statScaling = _weaponScaleValue(
      combatWeaponType: combatWeaponType,
      targetKey: 'stability',
      strValue: strValue,
      dexValue: dexValue,
      intValue: intValue,
      agiValue: agiValue,
      vitValue: vitValue,
    );
    return mainWeaponBaseStability + supplementalStabilityBase + statScaling;
  }

  static double _baseHp({
    required int level,
    required double vitValue,
    required String armorState,
  }) {
    final double adjustedVit = armorState == 'no_armor'
        ? vitValue * 1.1
        : vitValue;
    return 93 + ((adjustedVit + 22.41) * level / 3);
  }

  static double _baseMp({
    required int level,
    required double intValue,
    required String personalStatType,
    required int personalStatValue,
  }) {
    final double tecBonus = personalStatType == 'TEC'
        ? personalStatValue.toDouble()
        : 0;
    return 99 + level + (intValue / 10) + tecBonus;
  }

  static double _weaponScaleValue({
    required String combatWeaponType,
    required String targetKey,
    required double strValue,
    required double dexValue,
    required double intValue,
    required double agiValue,
    required double vitValue,
  }) {
    final Map<String, Map<String, double>> scaling =
        _weaponScaling[combatWeaponType] ??
        const <String, Map<String, double>>{};
    double total = 0;
    total += _readScaleContribution(
      scaling: scaling,
      statKey: 'STR',
      targetKey: targetKey,
      statValue: strValue,
    );
    total += _readScaleContribution(
      scaling: scaling,
      statKey: 'DEX',
      targetKey: targetKey,
      statValue: dexValue,
    );
    total += _readScaleContribution(
      scaling: scaling,
      statKey: 'INT',
      targetKey: targetKey,
      statValue: intValue,
    );
    total += _readScaleContribution(
      scaling: scaling,
      statKey: 'AGI',
      targetKey: targetKey,
      statValue: agiValue,
    );
    total += _readScaleContribution(
      scaling: scaling,
      statKey: 'VIT',
      targetKey: targetKey,
      statValue: vitValue,
    );
    return total;
  }

  static double _readScaleContribution({
    required Map<String, Map<String, double>> scaling,
    required String statKey,
    required String targetKey,
    required double statValue,
  }) {
    final Map<String, double> entry =
        scaling[statKey] ?? const <String, double>{};
    return statValue * (entry[targetKey] ?? 0);
  }

  static bool _matchesCondition(
    EquipmentStatCondition? condition, {
    required String combatWeaponType,
    required String mainWeaponType,
    required String subWeaponType,
    required String armorState,
  }) {
    if (condition == null || condition.isEmpty) {
      return true;
    }
    final String expectedArmor =
        condition.armorState?.trim().toLowerCase() ?? '';
    if (expectedArmor.isNotEmpty && expectedArmor != armorState) {
      return false;
    }

    final String rawWeaponRequirement = condition.weaponRequired?.trim() ?? '';
    if (rawWeaponRequirement.isEmpty) {
      return true;
    }
    if (rawWeaponRequirement.contains(',')) {
      final List<String> options = rawWeaponRequirement
          .split(',')
          .map(_normalizeWeaponCondition)
          .where((String value) => value.isNotEmpty)
          .toList(growable: false);
      if (options.isEmpty) {
        return true;
      }
      final Set<String> activeWeapons = <String>{
        if (combatWeaponType.isNotEmpty) combatWeaponType,
        if (mainWeaponType.isNotEmpty) mainWeaponType,
        if (subWeaponType.isNotEmpty) subWeaponType,
      };
      for (final String option in options) {
        if (activeWeapons.contains(option)) {
          return true;
        }
      }
      return false;
    }

    final String weaponRequirement = _normalizeWeaponCondition(
      rawWeaponRequirement,
    );
    switch (weaponRequirement) {
      case 'HEAVY_ARMOR':
        return armorState == 'heavy';
      case 'LIGHT_ARMOR':
        return armorState == 'light';
      case 'EVENT':
        return false;
      case 'DUAL_SWORDS':
      case 'DUAL_SWORD':
        return combatWeaponType == 'DUAL_SWORD';
      default:
        final Set<String> activeWeapons = <String>{
          if (combatWeaponType.isNotEmpty) combatWeaponType,
          if (mainWeaponType.isNotEmpty) mainWeaponType,
          if (subWeaponType.isNotEmpty) subWeaponType,
        };
        return activeWeapons.contains(weaponRequirement);
    }
  }

  static bool _subWeaponAddsWeaponAtk({
    required String mainWeaponType,
    required String combatWeaponType,
    required String subWeaponType,
    required bool isSubWeaponAllowed,
  }) {
    return isSubWeaponAllowed && subWeaponType.isNotEmpty;
  }

  static bool _subWeaponUsesWeaponRefine({
    required String subWeaponType,
    required bool subWeaponHasBaseWeaponAtk,
  }) {
    return subWeaponType.isNotEmpty && subWeaponHasBaseWeaponAtk;
  }

  static bool _subWeaponAddsStability({
    required String mainWeaponType,
    required String combatWeaponType,
    required String subWeaponType,
    required bool isSubWeaponAllowed,
  }) {
    return isSubWeaponAllowed && subWeaponType.isNotEmpty;
  }

  static bool _isSubWeaponAllowedByRules({
    required String mainWeaponType,
    required String subWeaponType,
    required Map<String, List<String>> mainToAllowedSubTypes,
  }) {
    if (subWeaponType.isEmpty) {
      return true;
    }
    if (mainWeaponType.isEmpty) {
      return true;
    }
    final Map<String, List<String>> normalizedRules =
        _normalizeAllowedSubWeaponRules(mainToAllowedSubTypes);
    final List<String>? allowed = normalizedRules[mainWeaponType];
    if (allowed == null) {
      return true;
    }
    return allowed.contains(subWeaponType);
  }

  static Map<String, List<String>> _normalizeAllowedSubWeaponRules(
    Map<String, List<String>> source,
  ) {
    if (source.isEmpty) {
      return const <String, List<String>>{};
    }

    final Map<String, List<String>> normalized = <String, List<String>>{};
    for (final MapEntry<String, List<String>> entry in source.entries) {
      final String mainWeaponType = _normalizeWeaponType(entry.key);
      if (mainWeaponType.isEmpty) {
        continue;
      }

      final Set<String> allowedTypes = <String>{};
      for (final String rawAllowedType in entry.value) {
        final String allowedType = _normalizeWeaponType(rawAllowedType);
        if (allowedType.isNotEmpty) {
          allowedTypes.add(allowedType);
        }
      }

      if (allowedTypes.isNotEmpty) {
        normalized[mainWeaponType] = allowedTypes.toList(growable: false);
      }
    }
    return normalized;
  }

  static bool _itemHasBaseWeaponAtk(EquipmentLibraryItem? item) {
    if (item == null) {
      return false;
    }
    for (final EquipmentStat stat in item.stats) {
      if (stat.statKey.trim().toLowerCase() != 'weapon_atk') {
        continue;
      }
      if (stat.valueType.trim().toLowerCase() != _baseValueType) {
        continue;
      }
      if (stat.value.toDouble() <= 0) {
        continue;
      }
      return true;
    }
    return false;
  }

  static String _normalizeArmorState(String value) {
    final String normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'heavy':
      case 'light':
      case 'no_armor':
        return normalized;
      default:
        return 'normal';
    }
  }

  static String _resolveCombatWeaponType({
    required String mainWeaponType,
    required String subWeaponType,
  }) {
    if (mainWeaponType == '1H_SWORD' && subWeaponType == '1H_SWORD') {
      return 'DUAL_SWORD';
    }
    if (mainWeaponType.isEmpty) {
      if (subWeaponType.isNotEmpty) {
        return subWeaponType;
      }
      return 'BARE_HAND';
    }
    return mainWeaponType;
  }

  static String _normalizeWeaponType(String? value) {
    final String normalized = (value ?? '')
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
      '1_HANDED_SWORD': '1H_SWORD',
      '1_H_SWORD': '1H_SWORD',
      'TWO_HAND_SWORD': '2H_SWORD',
      '2_HANDED_SWORD': '2H_SWORD',
      '2_H_SWORD': '2H_SWORD',
      'BAREHAND': 'BARE_HAND',
      'KNUCKLE': 'KNUCKLES',
      'MAGICDEVICE': 'MAGIC_DEVICE',
      'DUAL_SWORDS': 'DUAL_SWORD',
    };
    return aliases[normalized] ?? normalized;
  }

  static String _normalizeWeaponCondition(String? value) {
    return _normalizeWeaponType(value);
  }

  static num _panelValue(double value) {
    if (!value.isFinite) {
      return 0;
    }
    return value.truncateToDouble();
  }

  static num _readNumericValue(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }
}

class BuildCalculationContext {
  const BuildCalculationContext({
    required this.primaryPercentByKey,
    required this.primaryFlatByKey,
    required this.derivedPercentByKey,
    required this.derivedFlatByKey,
    required this.mainWeaponAtkBase,
    required this.supplementalWeaponAtkBase,
    required this.weaponAtkFlat,
    required this.weaponAtkPercent,
    required this.mainWeaponBaseStability,
    required this.supplementalStabilityBase,
    required this.armorDefBase,
    required this.helmetDefBase,
    required this.ringDefBase,
    required this.otherEquipmentDefBase,
    required this.armorMdefBase,
    required this.helmetMdefBase,
    required this.ringMdefBase,
    required this.otherEquipmentMdefBase,
    required this.combatWeaponType,
    required this.mainWeaponType,
    required this.subWeaponType,
    required this.effectiveArmorState,
    required this.isSubWeaponAllowed,
    required this.subWeaponHasBaseWeaponAtk,
  });

  final Map<String, double> primaryPercentByKey;
  final Map<String, double> primaryFlatByKey;
  final Map<String, double> derivedPercentByKey;
  final Map<String, double> derivedFlatByKey;
  final double mainWeaponAtkBase;
  final double supplementalWeaponAtkBase;
  final double weaponAtkFlat;
  final double weaponAtkPercent;
  final double mainWeaponBaseStability;
  final double supplementalStabilityBase;
  final double armorDefBase;
  final double helmetDefBase;
  final double ringDefBase;
  final double otherEquipmentDefBase;
  final double armorMdefBase;
  final double helmetMdefBase;
  final double ringMdefBase;
  final double otherEquipmentMdefBase;
  final String combatWeaponType;
  final String mainWeaponType;
  final String subWeaponType;
  final String effectiveArmorState;
  final bool isSubWeaponAllowed;
  final bool subWeaponHasBaseWeaponAtk;
}

class _CalculationBuckets {
  final Map<String, double> primaryPercentByKey = <String, double>{};
  final Map<String, double> primaryFlatByKey = <String, double>{};
  final Map<String, double> derivedPercentByKey = <String, double>{};
  final Map<String, double> derivedFlatByKey = <String, double>{};

  double mainWeaponAtkBase = 0;
  double supplementalWeaponAtkBase = 0;
  double weaponAtkFlat = 0;
  double weaponAtkPercent = 0;
  double mainWeaponBaseStability = 0;
  double supplementalStabilityBase = 0;
  double armorDefBase = 0;
  double helmetDefBase = 0;
  double ringDefBase = 0;
  double otherEquipmentDefBase = 0;
  double armorMdefBase = 0;
  double helmetMdefBase = 0;
  double ringMdefBase = 0;
  double otherEquipmentMdefBase = 0;
}
