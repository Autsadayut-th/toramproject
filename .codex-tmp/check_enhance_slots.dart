import 'package:toramonline/build_simulator/services/build_calculator_service.dart';
import 'package:toramonline/build_simulator/services/build_rule_set_service.dart';
import 'package:toramonline/equipment_library/models/equipment_library_item.dart';

void main() {
  const EquipmentLibraryItem armor = EquipmentLibraryItem(
    id: 1,
    key: 'armor_test',
    name: 'Armor Test',
    color: 'white',
    type: 'Armor',
    stats: <EquipmentStat>[
      EquipmentStat(statKey: 'def', value: 200, valueType: 'base'),
      EquipmentStat(statKey: 'mdef', value: 100, valueType: 'base'),
    ],
    imageAssetPath: '',
    obtainedFrom: <EquipmentObtainedSource>[],
  );

  const EquipmentLibraryItem helmet = EquipmentLibraryItem(
    id: 2,
    key: 'helmet_test',
    name: 'Helmet Test',
    color: 'white',
    type: 'Additional',
    stats: <EquipmentStat>[
      EquipmentStat(statKey: 'def', value: 100, valueType: 'base'),
      EquipmentStat(statKey: 'mdef', value: 50, valueType: 'base'),
    ],
    imageAssetPath: '',
    obtainedFrom: <EquipmentObtainedSource>[],
  );

  const EquipmentLibraryItem ring = EquipmentLibraryItem(
    id: 3,
    key: 'ring_test',
    name: 'Ring Test',
    color: 'white',
    type: 'Special',
    stats: <EquipmentStat>[
      EquipmentStat(statKey: 'def', value: 50, valueType: 'base'),
      EquipmentStat(statKey: 'mdef', value: 25, valueType: 'base'),
    ],
    imageAssetPath: '',
    obtainedFrom: <EquipmentObtainedSource>[],
  );

  const BuildRuleSet ruleSet = BuildRuleSet(
    buildRules: <String, dynamic>{},
    buildEvaluationRules: <String, dynamic>{},
    combatRules: <String, dynamic>{},
    crystaSlotRules: <String, dynamic>{},
    elementRules: <String, dynamic>{},
    statScalingRules: <String, dynamic>{},
    refineRules: <String, dynamic>{
      'formula': <String, dynamic>{
        'percent': 'refine_level^2',
        'flat': 'refine_level',
      },
    },
  );

  final Map<String, num> base = BuildCalculatorService.calculateSummary(
    character: <String, dynamic>{
      'STR': 1,
      'INT': 1,
      'VIT': 1,
      'AGI': 1,
      'DEX': 1,
    },
    level: 1,
    personalStatType: 'CRT',
    personalStatValue: 0,
    enhanceMain: 0,
    enhanceSub: 0,
    enhanceArmor: 0,
    enhanceHelmet: 0,
    enhanceRing: 0,
    armorState: 'normal',
    mainWeapon: null,
    subWeapon: null,
    armor: armor,
    helmet: helmet,
    ring: ring,
    equippedCrystalStats: const <EquipmentStat>[],
    avatarStats: const <EquipmentStat>[],
    ruleSet: ruleSet,
  );

  final Map<String, num> boosted = BuildCalculatorService.calculateSummary(
    character: <String, dynamic>{
      'STR': 1,
      'INT': 1,
      'VIT': 1,
      'AGI': 1,
      'DEX': 1,
    },
    level: 1,
    personalStatType: 'CRT',
    personalStatValue: 0,
    enhanceMain: 0,
    enhanceSub: 0,
    enhanceArmor: 10,
    enhanceHelmet: 5,
    enhanceRing: 3,
    armorState: 'normal',
    mainWeapon: null,
    subWeapon: null,
    armor: armor,
    helmet: helmet,
    ring: ring,
    equippedCrystalStats: const <EquipmentStat>[],
    avatarStats: const <EquipmentStat>[],
    ruleSet: ruleSet,
  );

  print('BASE DEF=${base['DEF']} MDEF=${base['MDEF']}');
  print('ENH  DEF=${boosted['DEF']} MDEF=${boosted['MDEF']}');
}
