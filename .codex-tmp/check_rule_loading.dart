import '../lib/build_simulator/services/build_weapon_rule_service.dart';
import '../lib/build_simulator/services/build_rule_set_service.dart';

Future<void> main() async {
  final weaponConfig = await BuildWeaponRuleService.load();
  final ruleSet = await BuildRuleSetService.load();

  print('weapon aliases: ${weaponConfig.weaponTypeAlias.length}');
  print('sub aliases: ${weaponConfig.subWeaponTypeAlias.length}');
  print('main->sub rules: ${weaponConfig.mainToAllowedSubTypes.length}');
  print('physicalCritTarget: ${ruleSet.physicalCritTarget}');
  print('magicStaffCritRecommended: ${ruleSet.magicStaffCritRecommended}');
  print('crysta duplicate rule: ${ruleSet.noDuplicateCrystaInSameEquipment}');
  print('build_rules has build_types: ${ruleSet.buildRules.containsKey('build_types')}');
}
