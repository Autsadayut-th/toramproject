import '../../equipment_library/models/equipment_library_item.dart';
import '../../shared/toram_data_github_service.dart';

class AvatarGachaConfig {
  const AvatarGachaConfig({
    required this.sections,
    required this.slotsPerSection,
    required this.noDuplicateStatInSameSection,
    required this.slot3RequiresSlot2,
    required this.options,
  });

  final List<String> sections;
  final int slotsPerSection;
  final bool noDuplicateStatInSameSection;
  final bool slot3RequiresSlot2;
  final List<AvatarStatOption> options;
}

class AvatarStatOption {
  const AvatarStatOption({
    required this.id,
    required this.statKey,
    required this.valueType,
    required this.value,
    required this.displayStat,
    required this.label,
  });

  final String id;
  final String statKey;
  final String valueType;
  final num value;
  final String displayStat;
  final String label;

  EquipmentStat toEquipmentStat() {
    return EquipmentStat(
      statKey: statKey,
      value: value,
      valueType: valueType,
    );
  }
}

class AvatarGachaDataService {
  static const String _avatarStatsAssetPath =
      'items/gacha/avatar_stats.json';
  static const String _avatarRulesAssetPath = 'rules/avatar_rules.json';

  static const Map<String, String> _internalStatKeyBySource = <String, String>{
    'STR': 'str',
    'DEX': 'dex',
    'INT': 'int',
    'AGI': 'agi',
    'VIT': 'vit',
    'MaxHP': 'maxhp',
    'MaxMP': 'maxmp',
    'WeaponATK': 'weapon_atk',
    'ATK': 'atk',
    'MATK': 'matk',
    'Stability': 'stability',
    'Accuracy': 'accuracy',
    'Dodge': 'dodge',
    'DEF': 'def',
    'MDEF': 'mdef',
    'ASPD': 'aspd',
    'CSPD': 'cspd',
    'NaturalHPRegen': 'natural_hp_regen',
    'NaturalMPRegen': 'natural_mp_regen',
    'AttackMPRecovery': 'attack_mp_recovery',
    'CriticalRate': 'critical_rate',
    'CriticalDamage': 'critical_damage',
    'AilmentResistance': 'ailment_resistance',
    'GuardRecharge': 'guard_recharge',
    'GuardPower': 'guard_power',
    'EvasionRecharge': 'evasion_recharge',
    'PhysicalResistance': 'physical_resistance',
    'MagicResistance': 'magic_resistance',
    'PhysicalPierce': 'physical_pierce',
    'MagicPierce': 'magic_pierce',
    'DamageToFire': 'damage_to_fire',
    'DamageToWater': 'damage_to_water',
    'DamageToWind': 'damage_to_wind',
    'DamageToEarth': 'damage_to_earth',
    'DamageToLight': 'damage_to_light',
    'DamageToDark': 'damage_to_dark',
    'DamageToNeutral': 'damage_to_neutral',
    'Aggro': 'aggro',
    'FireResistance': 'fire_resistance',
    'WaterResistance': 'water_resistance',
    'WindResistance': 'wind_resistance',
    'EarthResistance': 'earth_resistance',
    'LightResistance': 'light_resistance',
    'DarkResistance': 'dark_resistance',
    'NeutralResistance': 'neutral_resistance',
    'ShortRangeDamage': 'short_range_damage',
    'LongRangeDamage': 'long_range_damage',
    'Anticipate': 'anticipate',
    'GuardBreak': 'guard_break',
    'AdditionalMelee': 'additional_melee',
    'AdditionalMagic': 'additional_magic',
    'Reflect': 'reflect',
    'PhysicalBarrier': 'physical_barrier',
    'MagicBarrier': 'magic_barrier',
    'FractionalBarrier': 'fractional_barrier',
    'BarrierCooldown': 'barrier_cooldown',
  };

  static Future<AvatarGachaConfig>? _cachedLoad;

  static Future<AvatarGachaConfig> load() {
    return _cachedLoad ??= _load();
  }

  static EquipmentStat? decodeSelectionAsEquipmentStat(String raw) {
    final List<String> parts = raw.split('|');
    if (parts.length != 3) {
      return null;
    }

    final String statKey = parts[0].trim();
    final String valueType = parts[1].trim().toLowerCase();
    final num? value = num.tryParse(parts[2].trim());
    if (statKey.isEmpty || value == null) {
      return null;
    }

    return EquipmentStat(
      statKey: statKey,
      value: value,
      valueType: valueType == 'percent' ? 'percent' : 'flat',
    );
  }

  static String? decodeSelectionStatKey(String raw) {
    return decodeSelectionAsEquipmentStat(raw)?.statKey;
  }

  static Future<AvatarGachaConfig> _load() async {
    final List<dynamic> dataRows = await _loadStatRows();
    final Map<String, dynamic> rules = await _loadRules();

    final Map<String, dynamic> avatarRules =
        (rules['avatar_rules'] as Map<String, dynamic>?) ??
        <String, dynamic>{};
    final List<String> sections =
        (avatarRules['sections_name'] as List<dynamic>?)
            ?.map((dynamic value) => value.toString().trim())
            .where((String value) => value.isNotEmpty)
            .toList(growable: false) ??
        const <String>['top', 'bottom', 'accessory'];

    final List<AvatarStatOption> options = <AvatarStatOption>[];
    for (final Map<String, dynamic> row in dataRows.whereType<Map<String, dynamic>>()) {
      final String sourceStat = row['stat']?.toString().trim() ?? '';
      final String internalStatKey = _internalStatKeyBySource[sourceStat] ?? '';
      if (internalStatKey.isEmpty) {
        continue;
      }

      final String valueType =
          row['type']?.toString().trim().toLowerCase() == 'percent'
          ? 'percent'
          : 'flat';
      final String displayStat = _humanizeSourceStat(sourceStat);
      final Iterable<dynamic> values =
          (row['values'] as List<dynamic>?) ?? const <dynamic>[];
      for (final dynamic rawValue in values) {
        if (rawValue is! num) {
          continue;
        }
        options.add(
          AvatarStatOption(
            id: _encodeSelection(
              statKey: internalStatKey,
              valueType: valueType,
              value: rawValue,
            ),
            statKey: internalStatKey,
            valueType: valueType,
            value: rawValue,
            displayStat: displayStat,
            label: _buildOptionLabel(
              displayStat: displayStat,
              valueType: valueType,
              value: rawValue,
            ),
          ),
        );
      }
    }

    return AvatarGachaConfig(
      sections: sections,
      slotsPerSection:
          (avatarRules['slots_per_section'] as num?)?.toInt() ?? 3,
      noDuplicateStatInSameSection:
          avatarRules['no_duplicate_stat_in_same_section'] == true,
      slot3RequiresSlot2:
          ((avatarRules['slot_unlock_rule'] as Map<String, dynamic>?)?['slot3_requires_slot2']) ==
          true,
      options: options.toList(growable: false),
    );
  }

  static Future<List<dynamic>> _loadStatRows() async {
    final dynamic decoded = await ToramDataGithubService.loadJson(
      _avatarStatsAssetPath,
    );
    if (decoded is! Map<String, dynamic>) {
      return const <dynamic>[];
    }
    return (decoded['avatar_stat_pool'] as List<dynamic>?) ?? const <dynamic>[];
  }

  static Future<Map<String, dynamic>> _loadRules() async {
    final dynamic decoded = await ToramDataGithubService.loadJson(
      _avatarRulesAssetPath,
    );
    if (decoded is! Map<String, dynamic>) {
      return const <String, dynamic>{};
    }
    return decoded;
  }

  static String _encodeSelection({
    required String statKey,
    required String valueType,
    required num value,
  }) {
    return '$statKey|$valueType|$value';
  }

  static String _buildOptionLabel({
    required String displayStat,
    required String valueType,
    required num value,
  }) {
    final String valueText = value == value.toInt()
        ? value.toInt().toString()
        : value.toString();
    final String sign = value >= 0 ? '+' : '';
    final String suffix = valueType == 'percent' ? '%' : '';
    return '$displayStat $sign$valueText$suffix';
  }

  static String _humanizeSourceStat(String sourceStat) {
    if (sourceStat == sourceStat.toUpperCase()) {
      return sourceStat;
    }
    return sourceStat.replaceAllMapped(
      RegExp(r'(?<=[a-z])(?=[A-Z])'),
      (_) => ' ',
    );
  }
}
