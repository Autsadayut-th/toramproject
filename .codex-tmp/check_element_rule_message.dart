import 'package:toramonline/build_simulator/services/build_recommendation_service.dart';
import 'package:toramonline/build_simulator/services/build_calculator_service.dart';
import 'package:toramonline/build_simulator/services/build_rule_set_service.dart';
import 'package:toramonline/equipment_library/models/equipment_library_item.dart';

void main() {
  final BuildRuleSet ruleSet = BuildRuleSet(
    buildRules: const <String, dynamic>{},
    buildEvaluationRules: const <String, dynamic>{},
    combatRules: const <String, dynamic>{
      'critical_damage': {'base': 150, 'soft_cap': 300, 'overcap_penalty': 0.5},
      'critical_system': {'physical_target': 100},
    },
    crystaSlotRules: const <String, dynamic>{
      'crysta_slot_rules': {
        'check_scope': 'same_equipment_only',
      },
    },
    elementRules: const <String, dynamic>{
      'element_system': {
        'damage_bonus': 0.25,
        'element_advantage': {
          'fire': 'earth',
          'water': 'fire',
          'wind': 'water',
          'earth': 'wind',
          'light': 'dark',
          'dark': 'light',
        },
      },
    },
    statScalingRules: const <String, dynamic>{
      'global_stats': {'STR': {'critical_damage': 0.2}},
      'weapon_scaling': {},
    },
  );

  final List<EquipmentStat> weaponStats = <EquipmentStat>[
    const EquipmentStat(statKey: 'water_element', value: 1, valueType: 'flat'),
  ];

  final EquipmentLibraryItem fakeWeapon = EquipmentLibraryItem(
    id: 1,
    key: 'fake_weapon',
    name: 'Fake Weapon',
    color: 'unknown',
    type: 'Bow',
    stats: weaponStats,
    imageAssetPath: '',
    obtainedFrom: const <EquipmentObtainedSource>[],
  );

  final items = BuildRecommendationService.generateItems(
    summary: Map<String, num>.from(BuildCalculatorService.summaryTemplate)
      ..['ATK'] = 1000
      ..['MATK'] = 200,
    character: <String, dynamic>{'STR': 200, 'DEX': 200, 'INT': 1, 'AGI': 1, 'VIT': 1},
    level: 120,
    personalStatType: 'CRT',
    personalStatValue: 0,
    mainWeaponId: 'fake_weapon',
    subWeaponId: null,
    armorId: 'armor',
    helmetId: 'helmet',
    ringId: 'ring',
    enhanceMain: 9,
    enhanceArmor: 0,
    enhanceHelmet: 0,
    enhanceRing: 0,
    equippedItems: <EquipmentLibraryItem>[fakeWeapon],
    equippedCrystalStats: const <EquipmentStat>[],
    crystalKeysByEquipment: const <String, List<String>>{
      'Main Weapon': <String>[],
      'Armor': <String>[],
      'Helmet': <String>[],
      'Ring': <String>[],
    },
    crystalUpgradeFromByKey: const <String, String?>{},
    normalizedMainWeaponType: 'BOW',
    ruleSet: ruleSet,
  );

  for (final item in items) {
    if (item.category == 'rule') {
      print(item.normalizedMessage);
    }
  }
}
