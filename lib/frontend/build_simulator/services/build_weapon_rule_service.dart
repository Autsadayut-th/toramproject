import '../../shared/toram_data_github_service.dart';

class BuildWeaponRuleConfig {
  const BuildWeaponRuleConfig({
    required this.weaponTypeAlias,
    required this.subWeaponTypeAlias,
    required this.mainToAllowedSubTypes,
  });

  final Map<String, String> weaponTypeAlias;
  final Map<String, String> subWeaponTypeAlias;
  final Map<String, List<String>> mainToAllowedSubTypes;
}

class BuildWeaponRuleService {
  const BuildWeaponRuleService._();

  static const List<String> _typeAliasRemoteCandidates = <String>[
    'system/type_alias.json',
  ];

  static const List<String> _weaponSubRuleRemoteCandidates = <String>[
    'rules/weapon_sub_rules.json',
  ];

  static BuildWeaponRuleConfig? _cache;

  static Future<BuildWeaponRuleConfig> load() async {
    final BuildWeaponRuleConfig? cached = _cache;
    if (cached != null) {
      return cached;
    }

    final Map<String, dynamic> aliasRoot = await _loadFirstMapRemote(
      _typeAliasRemoteCandidates,
    );
    final Map<String, dynamic> ruleRoot = await _loadFirstMapRemote(
      _weaponSubRuleRemoteCandidates,
    );

    final BuildWeaponRuleConfig config = BuildWeaponRuleConfig(
      weaponTypeAlias: _toStringMap(aliasRoot['weapon_types']),
      subWeaponTypeAlias: _toStringMap(aliasRoot['sub_weapon_types']),
      mainToAllowedSubTypes: _toStringListMap(ruleRoot['main_to_allowed_sub']),
    );

    _cache = config;
    return config;
  }

  static Future<Map<String, dynamic>> _loadFirstMapRemote(
    List<String> candidates,
  ) async {
    for (final String remotePath in candidates) {
      try {
        final dynamic decoded = await ToramDataGithubService.loadJson(
          remotePath,
        );
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        continue;
      }
    }
    throw StateError('Failed to load remote data: ${candidates.join(', ')}');
  }

  static Map<String, String> _toStringMap(dynamic source) {
    if (source is! Map) {
      return const <String, String>{};
    }
    final Map<String, String> result = <String, String>{};
    for (final MapEntry<dynamic, dynamic> entry in source.entries) {
      final String key = entry.key?.toString().trim() ?? '';
      final String value = entry.value?.toString().trim() ?? '';
      if (key.isEmpty || value.isEmpty) {
        continue;
      }
      result[key] = value;
    }
    return result;
  }

  static Map<String, List<String>> _toStringListMap(dynamic source) {
    if (source is! Map) {
      return const <String, List<String>>{};
    }

    final Map<String, List<String>> result = <String, List<String>>{};
    for (final MapEntry<dynamic, dynamic> entry in source.entries) {
      final String key = entry.key?.toString().trim() ?? '';
      if (key.isEmpty) {
        continue;
      }
      final List<String> values = (entry.value as List<dynamic>? ?? const [])
          .map((dynamic value) => value.toString().trim())
          .where((String value) => value.isNotEmpty)
          .toList(growable: false);
      result[key] = values;
    }
    return result;
  }
}
