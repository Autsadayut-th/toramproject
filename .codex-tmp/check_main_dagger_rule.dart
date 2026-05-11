import '../lib/build_simulator/services/build_weapon_rule_service.dart';

Future<void> main() async {
  final cfg = await BuildWeaponRuleService.load();
  final allowed = <String>{}
    ..addAll(cfg.weaponTypeAlias.values.map((v) => v.trim()).where((v) => v.isNotEmpty))
    ..addAll(cfg.mainToAllowedSubTypes.keys.map((k) => k.trim()).where((k) => k.isNotEmpty));
  print('contains DAGGER: ${allowed.contains('DAGGER')}');
  print('allowed main types: ${allowed.toList()..sort()}');
}
