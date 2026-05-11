import 'package:toramonline/build_simulator/services/build_recommendation_service.dart';
import 'package:toramonline/build_simulator/services/build_calculator_service.dart';
import 'package:toramonline/equipment_library/models/equipment_library_item.dart';

void main() {
  final items = BuildRecommendationService.generateItems(
    summary: Map<String, num>.from(BuildCalculatorService.summaryTemplate),
    character: <String, dynamic>{'STR': 1, 'DEX': 1, 'INT': 1, 'AGI': 1, 'VIT': 1},
    level: 120,
    personalStatType: 'CRT',
    personalStatValue: 0,
    mainWeaponId: null,
    subWeaponId: null,
    armorId: null,
    helmetId: null,
    ringId: null,
    enhanceMain: 0,
    enhanceArmor: 0,
    enhanceHelmet: 0,
    enhanceRing: 0,
    equippedItems: const <EquipmentLibraryItem>[],
    equippedCrystalStats: const <EquipmentStat>[],
    crystalKeysByEquipment: const <String, List<String>>{
      'Main Weapon': <String>[],
      'Armor': <String>[],
      'Helmet': <String>[],
      'Ring': <String>[],
    },
    crystalUpgradeFromByKey: const <String, String?>{},
    normalizedMainWeaponType: '',
    ruleSet: null,
  );

  for (final item in items) {
    print('[${item.category}] p${item.priority} ${item.normalizedMessage}');
  }
}
