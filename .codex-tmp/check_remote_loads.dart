import 'package:toramonline/build_simulator/services/build_rule_set_service.dart';
import 'package:toramonline/build_simulator/services/build_weapon_rule_service.dart';
import 'package:toramonline/build_simulator/services/crystal_library_service.dart';
import 'package:toramonline/equipment_library/repository/equipment_library_repository.dart';

Future<void> main() async {
  final BuildRuleSet ruleSet = await BuildRuleSetService.load();
  final BuildWeaponRuleConfig weaponConfig = await BuildWeaponRuleService.load();
  final repository = EquipmentLibraryRepository();
  final all = await repository.loadAllCategories();
  final crystals = await CrystalLibraryService.loadByCategories(
    const <String>['weapon', 'armor', 'additional', 'special', 'normal'],
  );

  print('ruleSet: buildRules=${ruleSet.buildRules.isNotEmpty}, combatRules=${ruleSet.combatRules.isNotEmpty}');
  print('weaponConfig: aliases=${weaponConfig.weaponTypeAlias.length}, subRules=${weaponConfig.mainToAllowedSubTypes.length}');
  print('equipment categories loaded: ${all.keys.toList()}');
  print('equipment totals: ${all.values.fold<int>(0, (int s, list) => s + list.length)}');
  print('crystals loaded: ${crystals.length}');
}
