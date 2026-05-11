import 'package:toramonline/build_simulator/services/build_calculator_service.dart';
import 'package:toramonline/build_simulator/services/build_rule_set_service.dart';
import 'package:toramonline/equipment_library/models/equipment_library_item.dart';

void main() {
  const EquipmentLibraryItem bow = EquipmentLibraryItem(
    id: 10,
    key: 'bow_test',
    name: 'Bow Test',
    color: 'white',
    type: 'Bow',
    stats: <EquipmentStat>[
      EquipmentStat(statKey: 'weapon_atk', value: 500, valueType: 'base'),
      EquipmentStat(statKey: 'stability', value: 60, valueType: 'base'),
    ],
    imageAssetPath: '',
    obtainedFrom: <EquipmentObtainedSource>[],
  );

  const EquipmentLibraryItem arrow = EquipmentLibraryItem(
    id: 11,
    key: 'arrow_test',
    name: 'Arrow Test',
    color: 'white',
    type: 'Arrow',
    stats: <EquipmentStat>[
      EquipmentStat(statKey: 'weapon_atk', value: 80, valueType: 'base'),
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

  Map<String, num> summary({required int enhMain, required int enhSub}) {
    return BuildCalculatorService.calculateSummary(
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
      enhanceMain: enhMain,
      enhanceSub: enhSub,
      enhanceArmor: 0,
      enhanceHelmet: 0,
      enhanceRing: 0,
      armorState: 'normal',
      mainWeapon: bow,
      subWeapon: arrow,
      armor: null,
      helmet: null,
      ring: null,
      equippedCrystalStats: const <EquipmentStat>[],
      avatarStats: const <EquipmentStat>[],
      ruleSet: ruleSet,
    );
  }

  final Map<String, num> sub0 = summary(enhMain: 0, enhSub: 0);
  final Map<String, num> sub10 = summary(enhMain: 0, enhSub: 10);
  final Map<String, num> main10 = summary(enhMain: 10, enhSub: 0);

  print('ATK enhSub 0 = ${sub0['ATK']}');
  print('ATK enhSub10 = ${sub10['ATK']}');
  print('ATK enhMain10 = ${main10['ATK']}');
}
