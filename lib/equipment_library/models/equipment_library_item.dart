class EquipmentLibraryItem {
  const EquipmentLibraryItem({
    required this.id,
    required this.key,
    required this.name,
    required this.color,
    required this.type,
    required this.stats,
    required this.imageAssetPath,
    required this.obtainedFrom,
    this.upgradeFrom,
  });

  final int id;
  final String key;
  final String name;
  final String color;
  final String type;
  final List<EquipmentStat> stats;
  final String imageAssetPath;
  final List<EquipmentObtainedSource> obtainedFrom;
  final String? upgradeFrom;

  factory EquipmentLibraryItem.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> display =
        (json['display'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final Map<String, dynamic>? upgrade =
        json['upgrade'] as Map<String, dynamic>?;

    return EquipmentLibraryItem(
      id: _readIntValue(json['id']),
      key: _readItemKey(json),
      name: _readItemName(json, display),
      color: display['color']?.toString().trim() ?? 'unknown',
      type: json['type']?.toString().trim() ?? 'unknown',
      stats: _buildStats(json),
      imageAssetPath: _readImageAssetPath(json, display),
      obtainedFrom: _buildObtainedFrom(json),
      upgradeFrom: upgrade == null ? null : upgrade['from']?.toString().trim(),
    );
  }

  static String _readItemKey(Map<String, dynamic> json) {
    final String explicitKey = json['key']?.toString().trim() ?? '';
    if (explicitKey.isNotEmpty) {
      return explicitKey;
    }

    final String name = json['name']?.toString().trim() ?? '';
    final String normalizedName = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    if (normalizedName.isNotEmpty) {
      final int id = _readIntValue(json['id']);
      return id > 0 ? '${normalizedName}_$id' : normalizedName;
    }

    final int id = _readIntValue(json['id']);
    return id > 0 ? 'item_$id' : '';
  }

  static String _readItemName(
    Map<String, dynamic> json,
    Map<String, dynamic> display,
  ) {
    final String displayName = display['name']?.toString().trim() ?? '';
    if (displayName.isNotEmpty) {
      return displayName;
    }

    final String directName = json['name']?.toString().trim() ?? '';
    if (directName.isNotEmpty) {
      return directName;
    }

    final String key = json['key']?.toString().trim() ?? '';
    if (key.isNotEmpty) {
      return key
          .split(RegExp(r'[_\s]+'))
          .where((String part) => part.isNotEmpty)
          .map(
            (String part) =>
                part[0].toUpperCase() + part.substring(1).toLowerCase(),
          )
          .join(' ');
    }

    return '';
  }

  static String _readImageAssetPath(
    Map<String, dynamic> json,
    Map<String, dynamic> display,
  ) {
    final List<String?> imageCandidates = <String?>[
      json['image']?.toString(),
      json['image_path']?.toString(),
      display['image']?.toString(),
      display['image_path']?.toString(),
    ];

    for (final String? candidate in imageCandidates) {
      final String value = candidate?.trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  static List<EquipmentStat> _buildStats(Map<String, dynamic> json) {
    final List<dynamic> statsJson =
        (json['stats'] as List<dynamic>?) ?? <dynamic>[];
    final List<EquipmentStat> stats = <EquipmentStat>[];
    final Map<String, dynamic> base =
        (json['base'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    final num? baseAtk = _readNumValue(base['atk']);
    if (baseAtk != null) {
      stats.add(
        EquipmentStat(statKey: 'weapon_atk', value: baseAtk, valueType: 'base'),
      );
    }

    final num? baseDef = _readNumValue(base['def']);
    if (baseDef != null) {
      stats.add(
        EquipmentStat(statKey: 'def', value: baseDef, valueType: 'base'),
      );
    }

    final num? baseMdef = _readNumValue(base['mdef']);
    if (baseMdef != null) {
      stats.add(
        EquipmentStat(statKey: 'mdef', value: baseMdef, valueType: 'base'),
      );
    }

    final num? baseStability = _readNumValue(base['stability']);
    if (baseStability != null) {
      stats.add(
        EquipmentStat(
          statKey: 'stability',
          value: baseStability,
          valueType: 'base',
        ),
      );
    }

    for (final Map<String, dynamic> statJson
        in statsJson.whereType<Map<String, dynamic>>()) {
      if (!_hasSupportedStatValueType(statJson['value'])) {
        continue;
      }
      stats.add(EquipmentStat.fromJson(statJson));
    }

    final List<dynamic> conditionalStatsJson =
        (json['conditional_stats'] as List<dynamic>?) ?? <dynamic>[];
    for (final Map<String, dynamic> row
        in conditionalStatsJson.whereType<Map<String, dynamic>>()) {
      final Map<String, dynamic>? condition =
          row['condition'] as Map<String, dynamic>?;
      final Map<String, dynamic>? stat = row['stat'] as Map<String, dynamic>?;
      if (condition == null || stat == null) {
        continue;
      }
      if (!_hasSupportedStatValueType(stat['value'])) {
        continue;
      }
      stats.add(
        EquipmentStat.fromJson(<String, dynamic>{
          ...stat,
          'condition': condition,
        }),
      );
    }

    return stats.toList(growable: false);
  }

  static List<EquipmentObtainedSource> _buildObtainedFrom(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rows =
        (json['obtained_from'] as List<dynamic>?) ?? <dynamic>[];
    final List<EquipmentObtainedSource> result = <EquipmentObtainedSource>[];
    final Set<String> seen = <String>{};

    for (final dynamic row in rows) {
      if (row is! Map) {
        continue;
      }
      final EquipmentObtainedSource source = EquipmentObtainedSource.fromJson(
        Map<String, dynamic>.from(row),
      );
      if (source.isEmpty) {
        continue;
      }
      final String identity =
          '${source.source.toLowerCase()}|${source.map.toLowerCase()}';
      if (seen.add(identity)) {
        result.add(source);
      }
    }

    return result.toList(growable: false);
  }

  static bool _hasSupportedStatValueType(dynamic value) {
    return value is num || value is bool || value is String;
  }

  static int _readIntValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static num? _readNumValue(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value.trim());
    }
    return null;
  }
}

class EquipmentObtainedSource {
  const EquipmentObtainedSource({
    required this.source,
    required this.map,
    this.sourceType,
  });

  final String source;
  final String map;
  final String? sourceType;

  factory EquipmentObtainedSource.fromJson(Map<String, dynamic> json) {
    final String source = _readFirstNonEmpty(<String?>[
      json['monster']?.toString(),
      json['name']?.toString(),
      json['source']?.toString(),
      json['npc']?.toString(),
      json['boss']?.toString(),
      json['drop_from']?.toString(),
    ]);
    final String map = _readFirstNonEmpty(<String?>[
      json['map']?.toString(),
      json['location']?.toString(),
      json['area']?.toString(),
    ]);
    final String sourceType = json['source_type']?.toString().trim() ?? '';

    return EquipmentObtainedSource(
      source: source,
      map: map,
      sourceType: sourceType.isEmpty ? null : sourceType,
    );
  }

  bool get isEmpty => source.isEmpty && map.isEmpty;

  static String _readFirstNonEmpty(List<String?> values) {
    for (final String? value in values) {
      final String trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty && trimmed != '-') {
        return trimmed;
      }
    }
    return '';
  }
}

class EquipmentStat {
  const EquipmentStat({
    required this.statKey,
    required this.value,
    required this.valueType,
    this.condition,
  });

  final String statKey;
  final num value;
  final String valueType;
  final EquipmentStatCondition? condition;

  factory EquipmentStat.fromJson(Map<String, dynamic> json) {
    final String legacyKey = json['key']?.toString().trim() ?? '';
    String normalizedKey = json['stat_key']?.toString().trim() ?? '';
    if (normalizedKey.isEmpty) {
      normalizedKey = legacyKey.replaceFirst(RegExp(r'_pct$'), '');
    }

    String valueType = json['value_type']?.toString().trim() ?? '';
    if (valueType.isEmpty) {
      valueType = legacyKey.endsWith('_pct') ? 'percent' : 'flat';
    }

    return EquipmentStat(
      statKey: normalizedKey,
      value: _readNumericValue(json['value']),
      valueType: valueType,
      condition: EquipmentStatCondition.fromDynamic(json['condition']),
    );
  }

  static num _readNumericValue(dynamic value) {
    if (value is num) {
      return value;
    }
    if (value is bool) {
      return value ? 1 : 0;
    }
    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) {
        return 0;
      }
      final num? direct = num.tryParse(trimmed);
      if (direct != null) {
        return direct;
      }
      final RegExpMatch? match = RegExp(r'-?\d+(\.\d+)?').firstMatch(trimmed);
      if (match != null) {
        return num.tryParse(match.group(0)!) ?? 0;
      }
      return 0;
    }
    return 0;
  }
}

class EquipmentStatCondition {
  const EquipmentStatCondition({this.armorState, this.weaponRequired});

  final String? armorState;
  final String? weaponRequired;

  factory EquipmentStatCondition.fromDynamic(dynamic raw) {
    if (raw is! Map) {
      return const EquipmentStatCondition();
    }
    final Map<String, dynamic> json = Map<String, dynamic>.from(raw);
    final String armor = json['armor']?.toString().trim().toLowerCase() ?? '';
    final String weapon =
        json['weapon_required']?.toString().trim().toLowerCase() ?? '';
    return EquipmentStatCondition(
      armorState: armor.isEmpty ? null : armor,
      weaponRequired: weapon.isEmpty ? null : weapon,
    );
  }

  bool get isEmpty => armorState == null && weaponRequired == null;
}
