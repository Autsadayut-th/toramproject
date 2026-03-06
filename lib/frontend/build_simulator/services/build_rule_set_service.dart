import '../../shared/toram_data_github_service.dart';

class BuildRuleSet {
  const BuildRuleSet({
    required this.buildRules,
    required this.buildEvaluationRules,
    required this.combatRules,
    required this.crystaSlotRules,
    required this.elementRules,
    required this.statScalingRules,
  });

  final Map<String, dynamic> buildRules;
  final Map<String, dynamic> buildEvaluationRules;
  final Map<String, dynamic> combatRules;
  final Map<String, dynamic> crystaSlotRules;
  final Map<String, dynamic> elementRules;
  final Map<String, dynamic> statScalingRules;

  int get physicalCritTarget {
    final int fromCombat = _readIntPath(
      combatRules,
      <String>['critical_system', 'physical_target'],
    );
    if (fromCombat > 0) {
      return fromCombat;
    }
    return _readIntPath(
      buildEvaluationRules,
      <String>['build_evaluation', 'physical_build', 'required', 'critical_rate'],
      fallback: 100,
    );
  }

  int get magicStaffCritRecommended {
    final int fromCombat = _readIntPath(
      combatRules,
      <String>['critical_system', 'magic_staff_target', 'recommended'],
    );
    if (fromCombat > 0) {
      return fromCombat;
    }
    return _readIntPath(
      buildEvaluationRules,
      <String>[
        'build_evaluation',
        'magic_crit_build',
        'recommended',
        'critical_rate',
      ],
      fallback: 200,
    );
  }

  int get physicalPierceMinimum {
    return _readIntPath(
      buildEvaluationRules,
      <String>[
        'build_evaluation',
        'physical_build',
        'stats',
        'physical_pierce',
        'minimum',
      ],
      fallback: 15,
    );
  }

  int get magicPierceMinimum {
    return _readIntPath(
      buildEvaluationRules,
      <String>['build_evaluation', 'magic_build', 'stats', 'magic_pierce', 'minimum'],
      fallback: 15,
    );
  }

  int get magicMpRecommended {
    return _readIntPath(
      buildEvaluationRules,
      <String>['build_evaluation', 'magic_build', 'recommended', 'max_mp'],
      fallback: 300,
    );
  }

  double get elementDamageBonus {
    return _readNumPath(
      elementRules,
      <String>['element_system', 'damage_bonus'],
    ).toDouble();
  }

  int get criticalDamageBase {
    return _readIntPath(
      combatRules,
      <String>['critical_damage', 'base'],
      fallback: 150,
    );
  }

  int get criticalDamageSoftCap {
    return _readIntPath(
      combatRules,
      <String>['critical_damage', 'soft_cap'],
      fallback: 300,
    );
  }

  double get criticalDamageOvercapPenalty {
    return _readNumPath(
      combatRules,
      <String>['critical_damage', 'overcap_penalty'],
      fallback: 0.5,
    ).toDouble();
  }

  double get strCriticalDamagePerPoint {
    return _readNumPath(
      statScalingRules,
      <String>['global_stats', 'STR', 'critical_damage'],
    ).toDouble();
  }

  bool get noDuplicateCrystaInSameEquipment {
    return _readBoolPath(
      crystaSlotRules,
      <String>['crysta_slot_rules', 'no_duplicate_crysta_in_same_equipment'],
      fallback: false,
    );
  }

  bool get noSameUpgradeGroupInSameEquipment {
    return _readBoolPath(
      crystaSlotRules,
      <String>['crysta_slot_rules', 'no_same_upgrade_group_in_same_equipment'],
      fallback: false,
    );
  }

  String get crystaCheckScope {
    return _readStringPath(
      crystaSlotRules,
      <String>['crysta_slot_rules', 'check_scope'],
    );
  }

  String buildNameForId(String buildId) {
    final Map<String, dynamic>? buildType = _buildTypeById(buildId);
    final String name = buildType?['name']?.toString().trim() ?? '';
    return name.isEmpty ? buildId : name;
  }

  List<String> priorityStatsForBuild(String buildId) {
    final Map<String, dynamic>? buildType = _buildTypeById(buildId);
    return _readStringList(buildType?['priority_stats']);
  }

  List<String> recommendedWeaponsForBuild(String buildId) {
    final Map<String, dynamic>? buildType = _buildTypeById(buildId);
    return _readStringList(buildType?['recommended_weapons'])
        .map(_normalizeWeaponTypeKey)
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);
  }

  dynamic combatStatPriorityForWeapon(String weaponTypeKey) {
    final Map<String, dynamic> root = _readMap(combatRules['build_stat_priority']);
    if (root.isEmpty) {
      return null;
    }
    final String normalized = _normalizeWeaponTypeKey(weaponTypeKey);
    for (final MapEntry<String, dynamic> entry in root.entries) {
      final String candidate = _normalizeWeaponTypeKey(entry.key);
      if (candidate == normalized) {
        return entry.value;
      }
    }
    return null;
  }

  Map<String, dynamic> weaponScalingForWeapon(String weaponTypeKey) {
    final Map<String, dynamic> root = _readMap(statScalingRules['weapon_scaling']);
    if (root.isEmpty) {
      return const <String, dynamic>{};
    }
    final String scalingKey = _toScalingWeaponKey(weaponTypeKey);
    if (scalingKey.isEmpty) {
      return const <String, dynamic>{};
    }
    return _readMap(root[scalingKey]);
  }

  Map<String, dynamic>? _buildTypeById(String buildId) {
    final String target = buildId.trim().toLowerCase();
    if (target.isEmpty) {
      return null;
    }
    final List<dynamic> buildTypes =
        buildRules['build_types'] as List<dynamic>? ?? const <dynamic>[];
    for (final dynamic row in buildTypes) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> item = Map<String, dynamic>.from(row);
      final String id = item['id']?.toString().trim().toLowerCase() ?? '';
      if (id == target) {
        return item;
      }
    }
    return null;
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  static List<String> _readStringList(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }
    return value
        .map((dynamic item) => item?.toString().trim() ?? '')
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static dynamic _readPath(Map<String, dynamic> source, List<String> path) {
    dynamic node = source;
    for (final String segment in path) {
      if (node is Map && node.containsKey(segment)) {
        node = node[segment];
        continue;
      }
      return null;
    }
    return node;
  }

  static num _readNumPath(
    Map<String, dynamic> source,
    List<String> path, {
    num fallback = 0,
  }) {
    final dynamic value = _readPath(source, path);
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }

  static int _readIntPath(
    Map<String, dynamic> source,
    List<String> path, {
    int fallback = 0,
  }) {
    final num value = _readNumPath(source, path, fallback: fallback);
    return value.toInt();
  }

  static bool _readBoolPath(
    Map<String, dynamic> source,
    List<String> path, {
    bool fallback = false,
  }) {
    final dynamic value = _readPath(source, path);
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    }
    if (value is num) {
      return value != 0;
    }
    return fallback;
  }

  static String _readStringPath(Map<String, dynamic> source, List<String> path) {
    final dynamic value = _readPath(source, path);
    return value?.toString().trim() ?? '';
  }

  static String _toScalingWeaponKey(String weaponTypeKey) {
    final String normalized = _normalizeWeaponTypeKey(weaponTypeKey);
    switch (normalized) {
      case '1H_SWORD':
        return 'one_hand_sword';
      case '2H_SWORD':
        return 'two_hand_sword';
      case 'KNUCKLES':
        return 'knuckle';
      case 'BARE_HAND':
        return 'barehand';
      default:
        return normalized.toLowerCase();
    }
  }

  static String _normalizeWeaponTypeKey(String value) {
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
      'MAGICDEVICE': 'MAGIC_DEVICE',
      'BAREHAND': 'BARE_HAND',
      'KNUCKLE': 'KNUCKLES',
    };
    return aliases[normalized] ?? normalized;
  }
}

class BuildRuleSetService {
  const BuildRuleSetService._();

  static const Map<String, String> _remotePaths = <String, String>{
    'buildRules': 'rules/build_rules.json',
    'buildEvaluationRules': 'rules/build_evaluation_rules.json',
    'combatRules': 'rules/combat_rules.json',
    'crystaSlotRules': 'rules/crysta_slot_rules.json',
    'elementRules': 'rules/element_rules.json',
    'statScalingRules': 'rules/stat_scaling_rules.json',
  };

  static BuildRuleSet? _cache;

  static Future<BuildRuleSet> load() async {
    final BuildRuleSet? cached = _cache;
    if (cached != null) {
      return cached;
    }

    final Map<String, Map<String, dynamic>> loaded = <String, Map<String, dynamic>>{};
    for (final MapEntry<String, String> entry in _remotePaths.entries) {
      try {
        loaded[entry.key] = await _loadRemoteMap(entry.value);
      } catch (_) {
        loaded[entry.key] = const <String, dynamic>{};
      }
    }

    final BuildRuleSet ruleSet = BuildRuleSet(
      buildRules: loaded['buildRules'] ?? const <String, dynamic>{},
      buildEvaluationRules:
          loaded['buildEvaluationRules'] ?? const <String, dynamic>{},
      combatRules: loaded['combatRules'] ?? const <String, dynamic>{},
      crystaSlotRules: loaded['crystaSlotRules'] ?? const <String, dynamic>{},
      elementRules: loaded['elementRules'] ?? const <String, dynamic>{},
      statScalingRules: loaded['statScalingRules'] ?? const <String, dynamic>{},
    );
    _cache = ruleSet;
    return ruleSet;
  }

  static Future<Map<String, dynamic>> _loadRemoteMap(String remotePath) async {
    final dynamic decoded = await ToramDataGithubService.loadJson(remotePath);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw FormatException('Remote rule is not an object: $remotePath');
  }

  static void clearCache() {
    _cache = null;
  }
}
