import '../../../equipment_library/models/equipment_library_item.dart';
import '../build_rule_set_service.dart';

class AiEquipmentSlots {
  const AiEquipmentSlots({
    required this.mainWeaponId,
    required this.subWeaponId,
    required this.armorId,
    required this.helmetId,
    required this.ringId,
    required this.enhanceMain,
    required this.enhanceArmor,
    required this.enhanceHelmet,
    required this.enhanceRing,
  });

  final String? mainWeaponId;
  final String? subWeaponId;
  final String? armorId;
  final String? helmetId;
  final String? ringId;
  final int enhanceMain;
  final int enhanceArmor;
  final int enhanceHelmet;
  final int enhanceRing;

  List<String> missingSlotLabels() {
    final List<String> missing = <String>[];
    if (AiBuildContext.isEmpty(mainWeaponId)) {
      missing.add('Main Weapon');
    }
    if (AiBuildContext.isEmpty(subWeaponId)) {
      missing.add('Sub Weapon');
    }
    if (AiBuildContext.isEmpty(armorId)) {
      missing.add('Armor');
    }
    if (AiBuildContext.isEmpty(helmetId)) {
      missing.add('Helmet');
    }
    if (AiBuildContext.isEmpty(ringId)) {
      missing.add('Ring');
    }
    return missing.toList(growable: false);
  }
}

class AiBuildInput {
  const AiBuildInput({
    required this.summary,
    required this.character,
    required this.level,
    required this.personalStatType,
    required this.personalStatValue,
    required this.equipmentSlots,
    required this.equippedItems,
    required this.equippedCrystalStats,
    required this.crystalKeysByEquipment,
    required this.crystalUpgradeFromByKey,
    required this.normalizedMainWeaponType,
    required this.ruleSet,
  });

  final Map<String, num> summary;
  final Map<String, dynamic> character;
  final int level;
  final String personalStatType;
  final int personalStatValue;
  final AiEquipmentSlots equipmentSlots;
  final Iterable<EquipmentLibraryItem> equippedItems;
  final Iterable<EquipmentStat> equippedCrystalStats;
  final Map<String, List<String>> crystalKeysByEquipment;
  final Map<String, String?> crystalUpgradeFromByKey;
  final String normalizedMainWeaponType;
  final BuildRuleSet? ruleSet;
}

class AiBuildAnalysis {
  const AiBuildAnalysis({
    required this.recommendations,
    required this.priorityStats,
  });

  final List<String> recommendations;
  final List<String> priorityStats;
}

class AiBuildContext {
  const AiBuildContext({
    required this.summary,
    required this.character,
    required this.level,
    required this.personalStatType,
    required this.personalStatValue,
    required this.equipmentSlots,
    required this.equippedItems,
    required this.equippedCrystalStats,
    required this.combinedStats,
    required this.crystalKeysByEquipment,
    required this.crystalUpgradeFromByKey,
    required this.normalizedMainWeaponType,
    required this.ruleSet,
    required this.atk,
    required this.matk,
    required this.def,
    required this.mdef,
    required this.critRate,
    required this.physicalPierce,
    required this.magicPierce,
    required this.stability,
    required this.accuracy,
    required this.hp,
    required this.mp,
    required this.weaponTypeKey,
    required this.highestStat,
    required this.physicalFocus,
    required this.physicalCritTarget,
    required this.physicalPierceTarget,
    required this.magicPierceTarget,
    required this.magicMpTarget,
    required this.expectedAccuracy,
    required this.expectedHp,
    required this.expectedDefense,
  });

  factory AiBuildContext.fromInput(AiBuildInput input) {
    final List<EquipmentLibraryItem> equippedItems = input.equippedItems.toList(
      growable: false,
    );
    final List<EquipmentStat> equippedCrystalStats = input.equippedCrystalStats
        .toList(growable: false);
    final List<EquipmentStat> combinedStats = <EquipmentStat>[];
    for (final EquipmentLibraryItem item in equippedItems) {
      combinedStats.addAll(item.stats);
    }
    combinedStats.addAll(equippedCrystalStats);

    final num atk = read(input.summary['ATK']);
    final num matk = read(input.summary['MATK']);
    final num def = read(input.summary['DEF']);
    final num mdef = read(input.summary['MDEF']);
    final num critRate = read(input.summary['CritRate']);
    final num physicalPierce = read(input.summary['PhysicalPierce']);
    final num magicPierce = read(
      input.summary['MagicPierce'] ?? input.summary['ElementPierce'],
    );
    final num stability = read(input.summary['Stability']);
    final num accuracy = read(input.summary['Accuracy']);
    final num hp = read(input.summary['HP']);
    final num mp = read(input.summary['MP']);
    final BuildRuleSet? ruleSet = input.ruleSet;

    return AiBuildContext(
      summary: Map<String, num>.from(input.summary),
      character: Map<String, dynamic>.from(input.character),
      level: input.level,
      personalStatType: input.personalStatType.trim().toUpperCase(),
      personalStatValue: input.personalStatValue,
      equipmentSlots: input.equipmentSlots,
      equippedItems: equippedItems,
      equippedCrystalStats: equippedCrystalStats,
      combinedStats: combinedStats.toList(growable: false),
      crystalKeysByEquipment: input.crystalKeysByEquipment.map(
        (String key, List<String> value) =>
            MapEntry<String, List<String>>(key, value.toList(growable: false)),
      ),
      crystalUpgradeFromByKey: Map<String, String?>.from(
        input.crystalUpgradeFromByKey,
      ),
      normalizedMainWeaponType: input.normalizedMainWeaponType,
      ruleSet: ruleSet,
      atk: atk,
      matk: matk,
      def: def,
      mdef: mdef,
      critRate: critRate,
      physicalPierce: physicalPierce,
      magicPierce: magicPierce,
      stability: stability,
      accuracy: accuracy,
      hp: hp,
      mp: mp,
      weaponTypeKey: normalizeWeaponTypeKey(input.normalizedMainWeaponType),
      highestStat: highestCharacterStat(input.character),
      physicalFocus: atk >= matk,
      physicalCritTarget: ruleSet?.physicalCritTarget ?? 70,
      physicalPierceTarget: ruleSet?.physicalPierceMinimum ?? 15,
      magicPierceTarget: ruleSet?.magicPierceMinimum ?? 15,
      magicMpTarget: ruleSet?.magicMpRecommended ?? 300,
      expectedAccuracy: (input.level + 20).clamp(30, 320),
      expectedHp: (700 + (input.level * 20)).clamp(700, 7000),
      expectedDefense: (120 + (input.level * 2)).clamp(120, 1000),
    );
  }

  final Map<String, num> summary;
  final Map<String, dynamic> character;
  final int level;
  final String personalStatType;
  final int personalStatValue;
  final AiEquipmentSlots equipmentSlots;
  final List<EquipmentLibraryItem> equippedItems;
  final List<EquipmentStat> equippedCrystalStats;
  final List<EquipmentStat> combinedStats;
  final Map<String, List<String>> crystalKeysByEquipment;
  final Map<String, String?> crystalUpgradeFromByKey;
  final String normalizedMainWeaponType;
  final BuildRuleSet? ruleSet;
  final num atk;
  final num matk;
  final num def;
  final num mdef;
  final num critRate;
  final num physicalPierce;
  final num magicPierce;
  final num stability;
  final num accuracy;
  final num hp;
  final num mp;
  final String weaponTypeKey;
  final String highestStat;
  final bool physicalFocus;
  final int physicalCritTarget;
  final int physicalPierceTarget;
  final int magicPierceTarget;
  final int magicMpTarget;
  final int expectedAccuracy;
  final int expectedHp;
  final int expectedDefense;

  bool hasAnyStat(Set<String> keys) {
    if (keys.isEmpty) {
      return false;
    }
    final Set<String> normalizedKeys = keys
        .map((String key) => key.trim().toLowerCase())
        .where((String key) => key.isNotEmpty)
        .toSet();
    for (final EquipmentStat stat in combinedStats) {
      final String statKey = stat.statKey.trim().toLowerCase();
      if (normalizedKeys.contains(statKey)) {
        return true;
      }
    }
    return false;
  }

  num sumStatValue(String key) {
    final String target = key.trim().toLowerCase();
    num total = 0;
    for (final EquipmentStat stat in combinedStats) {
      if (stat.statKey.trim().toLowerCase() != target) {
        continue;
      }
      total += stat.value;
    }
    return total;
  }

  bool hasDuplicateUpgradeGroup(List<String> crystalKeys) {
    final Set<String> seenRoots = <String>{};
    for (final String key in crystalKeys) {
      final String root = resolveUpgradeRoot(key);
      if (root.isEmpty) {
        continue;
      }
      if (!seenRoots.add(root)) {
        return true;
      }
    }
    return false;
  }

  String resolveUpgradeRoot(String crystalKey) {
    String current = crystalKey.trim().toLowerCase();
    if (current.isEmpty) {
      return '';
    }
    final Set<String> visited = <String>{};
    while (visited.add(current)) {
      final String parent = (crystalUpgradeFromByKey[current] ?? '')
          .trim()
          .toLowerCase();
      if (parent.isEmpty) {
        return current;
      }
      current = parent;
    }
    return current;
  }

  static num read(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static bool isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  static String highestCharacterStat(Map<String, dynamic> character) {
    const List<String> keys = <String>['STR', 'DEX', 'INT', 'AGI', 'VIT'];
    String bestKey = keys.first;
    num bestValue = read(character[bestKey]);
    for (int i = 1; i < keys.length; i++) {
      final String key = keys[i];
      final num value = read(character[key]);
      if (value > bestValue) {
        bestKey = key;
        bestValue = value;
      }
    }
    return bestKey;
  }

  static String mapRulePriorityStatToDataKey(String value) {
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

  static String normalizeWeaponTypeKey(String value) {
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
}
