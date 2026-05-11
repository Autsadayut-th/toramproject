import 'package:toramonline/build_simulator/services/build_recommendation_service.dart';
import 'package:toramonline/build_simulator/services/build_calculator_service.dart';
import 'package:toramonline/build_simulator/services/build_rule_set_service.dart';
import 'package:toramonline/equipment_library/models/equipment_library_item.dart';

void main() {
  final ruleSet = BuildRuleSet(
    buildRules: const <String, dynamic>{},
    buildEvaluationRules: const <String, dynamic>{
      'build_evaluation': {
        'physical_build': {
          'required': {'critical_rate': 100},
          'stats': {'physical_pierce': {'minimum': 15}},
        },
      },
    },
    combatRules: const <String, dynamic>{
      'critical_damage': {'base': 150, 'soft_cap': 300, 'overcap_penalty': 0.5},
      'critical_system': {'physical_target': 100},
    },
    crystaSlotRules: const <String, dynamic>{
      'crysta_slot_rules': {
        'check_scope': 'same_equipment_only',
        'no_duplicate_crysta_in_same_equipment': true,
        'no_same_upgrade_group_in_same_equipment': true,
      },
    },
    elementRules: const <String, dynamic>{
      'element_system': {'damage_bonus': 0.25},
    },
    statScalingRules: const <String, dynamic>{
      'global_stats': {'STR': {'critical_damage': 0.2}},
      'weapon_scaling': {},
    },
  );

  final summary = Map<String, num>.from(BuildCalculatorService.summaryTemplate)
    ..['ATK'] = 1000
    ..['MATK'] = 300
    ..['CritRate'] = 50
    ..['PhysicalPierce'] = 0
    ..['HP'] = 1500
    ..['DEF'] = 120
    ..['MDEF'] = 120;

  final items = BuildRecommendationService.generateItems(
    summary: summary,
    character: <String, dynamic>{'STR': 300, 'DEX': 100, 'INT': 1, 'AGI': 1, 'VIT': 40},
    level: 120,
    personalStatType: 'CRT',
    personalStatValue: 0,
    mainWeaponId: 'main_1',
    subWeaponId: 'sub_1',
    armorId: 'armor_1',
    helmetId: 'helm_1',
    ringId: 'ring_1',
    enhanceMain: 7,
    enhanceArmor: 2,
    enhanceHelmet: 2,
    enhanceRing: 0,
    equippedItems: const <EquipmentLibraryItem>[],
    equippedCrystalStats: const <EquipmentStat>[],
    crystalKeysByEquipment: const <String, List<String>>{
      'Main Weapon': <String>['ageladanios', 'ageladanios'],
      'Armor': <String>['brass_dragon_reguita', 'evil_magic_sword'],
      'Helmet': <String>[],
      'Ring': <String>[],
    },
    crystalUpgradeFromByKey: const <String, String?>{
      'ageladanios': 'orkn',
      'evil_magic_sword': 'orkn',
      'brass_dragon_reguita': null,
    },
    normalizedMainWeaponType: '1H_SWORD',
    ruleSet: ruleSet,
  );

  for (final item in items) {
    print('[${item.category}] p${item.priority} ${item.normalizedMessage}');
  }
}
