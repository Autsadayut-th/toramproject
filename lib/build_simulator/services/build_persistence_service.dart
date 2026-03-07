import 'dart:convert';

class BuildPersistenceService {
  static const int defaultTotalStatPoints = 776;
  static const int minTotalStatPoints = 1;
  static const int maxTotalStatPoints = 9999;

  static const List<String> characterStatKeys = <String>[
    'STR',
    'DEX',
    'INT',
    'AGI',
    'VIT',
  ];

  static const List<String> personalStatOptions = <String>[
    'CRT',
    'LUK',
    'TEC',
    'MNT',
  ];
  static const String shareCodePrefix = 'TB2.';
  static const String _shareCodePrefixV1 = 'TB1.';
  static const int shareCodeVersion = 2;
  static const List<String> _shareBuildKeys = <String>[
    'name',
    'level',
    'totalStatPoints',
    'personalStatType',
    'personalStatValue',
    'mainWeaponId',
    'enhMain',
    'mainCrystal1',
    'mainCrystal2',
    'subWeaponId',
    'enhSub',
    'armorId',
    'armorMode',
    'enhArmor',
    'armorCrystal1',
    'armorCrystal2',
    'helmetId',
    'enhHelmet',
    'helmetCrystal1',
    'helmetCrystal2',
    'ringId',
    'enhRing',
    'ringCrystal1',
    'ringCrystal2',
    'gacha1Stat1',
    'gacha1Stat2',
    'gacha1Stat3',
    'gacha2Stat1',
    'gacha2Stat2',
    'gacha2Stat3',
    'gacha3Stat1',
    'gacha3Stat2',
    'gacha3Stat3',
  ];
  static const List<String> _shareV2FieldOrder = <String>[
    'name',
    'level',
    'totalStatPoints',
    'personalStatType',
    'personalStatValue',
    'mainWeaponId',
    'enhMain',
    'mainCrystal1',
    'mainCrystal2',
    'subWeaponId',
    'enhSub',
    'armorId',
    'armorMode',
    'enhArmor',
    'armorCrystal1',
    'armorCrystal2',
    'helmetId',
    'enhHelmet',
    'helmetCrystal1',
    'helmetCrystal2',
    'ringId',
    'enhRing',
    'ringCrystal1',
    'ringCrystal2',
    'gacha1Stat1',
    'gacha1Stat2',
    'gacha1Stat3',
    'gacha2Stat1',
    'gacha2Stat2',
    'gacha2Stat3',
    'gacha3Stat1',
    'gacha3Stat2',
    'gacha3Stat3',
  ];

  static int readIntValue(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }

  static bool readBoolValue(dynamic value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
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
    return fallback;
  }

  static String readStringValue(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    return value.toString();
  }

  static String? readOptionalStringValue(dynamic value) {
    final String normalized = readStringValue(value).trim();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static String normalizePersonalStatType(dynamic value) {
    final String candidate = readStringValue(value).trim().toUpperCase();
    if (personalStatOptions.contains(candidate)) {
      return candidate;
    }
    return personalStatOptions.first;
  }

  static String normalizeArmorMode(dynamic value) {
    final String normalized = readStringValue(value).trim().toLowerCase();
    switch (normalized) {
      case 'heavy':
      case 'light':
        return normalized;
      default:
        return 'normal';
    }
  }

  static String buildIdFor(Map<String, dynamic> build, int index) {
    final String existingId = readStringValue(build['id']).trim();
    if (existingId.isNotEmpty) {
      return existingId;
    }
    final String generatedId =
        'build_${DateTime.now().microsecondsSinceEpoch}_$index';
    build['id'] = generatedId;
    return generatedId;
  }

  static int findBuildIndexById(
    List<Map<String, dynamic>> savedBuilds,
    String buildId,
  ) {
    for (int i = 0; i < savedBuilds.length; i++) {
      if (buildIdFor(savedBuilds[i], i) == buildId) {
        return i;
      }
    }
    return -1;
  }

  static Map<String, dynamic>? normalizeBuildSnapshot(
    dynamic raw,
    int fallbackIndex, {
    required Map<String, num> summaryTemplate,
  }) {
    if (raw is! Map) {
      return null;
    }

    final Map<String, dynamic> build = Map<String, dynamic>.from(raw);

    final String name = readStringValue(build['name']).trim();
    build['name'] = name.isEmpty ? 'Imported Build ${fallbackIndex + 1}' : name;

    final String id = readStringValue(build['id']).trim();
    build['id'] = id.isEmpty
        ? 'imported_${DateTime.now().microsecondsSinceEpoch}_$fallbackIndex'
        : id;

    build['isFavorite'] = readBoolValue(build['isFavorite']);

    final String savedAt = readStringValue(build['savedAt']).trim();
    build['savedAt'] = savedAt.isEmpty
        ? DateTime.now().toIso8601String()
        : savedAt;

    build['level'] = readIntValue(build['level'], fallback: 1).clamp(1, 999);
    build['totalStatPoints'] = readIntValue(
      build['totalStatPoints'],
      fallback: defaultTotalStatPoints,
    ).clamp(minTotalStatPoints, maxTotalStatPoints);
    build['personalStatType'] = normalizePersonalStatType(
      build['personalStatType'],
    );
    build['armorMode'] = normalizeArmorMode(build['armorMode']);
    build['personalStatValue'] = readIntValue(
      build['personalStatValue'],
      fallback: 0,
    ).clamp(0, 255);

    final dynamic rawSummary = build['summary'];
    final Map<String, num> normalizedSummary = Map<String, num>.from(
      summaryTemplate,
    );
    if (rawSummary is Map) {
      rawSummary.forEach((dynamic key, dynamic value) {
        final String summaryKey = key.toString();
        if (!normalizedSummary.containsKey(summaryKey)) {
          return;
        }
        if (value is num) {
          normalizedSummary[summaryKey] = value;
          return;
        }
        if (value is String) {
          normalizedSummary[summaryKey] =
              num.tryParse(value.trim()) ?? normalizedSummary[summaryKey]!;
        }
      });
      if ((normalizedSummary['MagicPierce'] ?? 0) == 0 &&
          rawSummary['ElementPierce'] is num) {
        normalizedSummary['MagicPierce'] = rawSummary['ElementPierce'] as num;
      }
      if ((normalizedSummary['ElementPierce'] ?? 0) == 0 &&
          rawSummary['MagicPierce'] is num) {
        normalizedSummary['ElementPierce'] = rawSummary['MagicPierce'] as num;
      }
    }
    build['summary'] = normalizedSummary;
    return build;
  }

  static List<Map<String, dynamic>> normalizeBuildList(
    Iterable<dynamic> rawBuilds, {
    Set<String>? reservedIds,
    required Map<String, num> summaryTemplate,
  }) {
    final Set<String> usedIds = <String>{...?reservedIds};
    final List<Map<String, dynamic>> normalized = <Map<String, dynamic>>[];
    int fallbackIndex = 0;
    for (final dynamic raw in rawBuilds) {
      final Map<String, dynamic>? build = normalizeBuildSnapshot(
        raw,
        fallbackIndex,
        summaryTemplate: summaryTemplate,
      );
      fallbackIndex++;
      if (build == null) {
        continue;
      }

      String id = readStringValue(build['id']).trim();
      if (id.isEmpty) {
        id =
            'imported_${DateTime.now().microsecondsSinceEpoch}_${normalized.length}';
      }
      while (usedIds.contains(id)) {
        id = '${id}_copy';
      }
      usedIds.add(id);
      build['id'] = id;
      normalized.add(build);
    }
    return normalized;
  }

  static Map<String, dynamic> createBuildSnapshot({
    required String name,
    required Map<String, dynamic> character,
    required int level,
    required int totalStatPoints,
    required String personalStatType,
    required int personalStatValue,
    required String? mainWeaponId,
    required int enhMain,
    required String? mainCrystal1,
    required String? mainCrystal2,
    required String? subWeaponId,
    required int enhSub,
    required String? armorId,
    required String armorMode,
    required int enhArmor,
    required String? armorCrystal1,
    required String? armorCrystal2,
    required String? helmetId,
    required int enhHelmet,
    required String? helmetCrystal1,
    required String? helmetCrystal2,
    required String? ringId,
    required int enhRing,
    required String? ringCrystal1,
    required String? ringCrystal2,
    required String gacha1Stat1,
    required String gacha1Stat2,
    required String gacha1Stat3,
    required String gacha2Stat1,
    required String gacha2Stat2,
    required String gacha2Stat3,
    required String gacha3Stat1,
    required String gacha3Stat2,
    required String gacha3Stat3,
    required bool isCharacterStatsExpanded,
    required bool isMainWeaponExpanded,
    required bool isSubWeaponExpanded,
    required bool isArmorExpanded,
    required bool isHelmetExpanded,
    required bool isRingExpanded,
    required bool isGachaExpanded,
    required Map<String, num> summary,
  }) {
    final Map<String, int> normalizedCharacter = <String, int>{
      for (final String key in characterStatKeys)
        key: readIntValue(character[key]),
    };

    return <String, dynamic>{
      'id': 'build_${DateTime.now().microsecondsSinceEpoch}',
      'name': name,
      'isFavorite': false,
      'savedAt': DateTime.now().toIso8601String(),
      'character': normalizedCharacter,
      'level': level.clamp(1, 999).toInt(),
      'totalStatPoints': totalStatPoints
          .clamp(minTotalStatPoints, maxTotalStatPoints)
          .toInt(),
      'personalStatType': normalizePersonalStatType(personalStatType),
      'personalStatValue': personalStatValue.clamp(0, 255).toInt(),
      'mainWeaponId': mainWeaponId,
      'enhMain': enhMain.clamp(0, 15).toInt(),
      'mainCrystal1': mainCrystal1,
      'mainCrystal2': mainCrystal2,
      'subWeaponId': subWeaponId,
      'enhSub': enhSub.clamp(0, 15).toInt(),
      'armorId': armorId,
      'armorMode': normalizeArmorMode(armorMode),
      'enhArmor': enhArmor.clamp(0, 15).toInt(),
      'armorCrystal1': armorCrystal1,
      'armorCrystal2': armorCrystal2,
      'helmetId': helmetId,
      'enhHelmet': enhHelmet.clamp(0, 15).toInt(),
      'helmetCrystal1': helmetCrystal1,
      'helmetCrystal2': helmetCrystal2,
      'ringId': ringId,
      'enhRing': enhRing.clamp(0, 15).toInt(),
      'ringCrystal1': ringCrystal1,
      'ringCrystal2': ringCrystal2,
      'gacha1Stat1': gacha1Stat1,
      'gacha1Stat2': gacha1Stat2,
      'gacha1Stat3': gacha1Stat3,
      'gacha2Stat1': gacha2Stat1,
      'gacha2Stat2': gacha2Stat2,
      'gacha2Stat3': gacha2Stat3,
      'gacha3Stat1': gacha3Stat1,
      'gacha3Stat2': gacha3Stat2,
      'gacha3Stat3': gacha3Stat3,
      'isCharacterStatsExpanded': isCharacterStatsExpanded,
      'isMainWeaponExpanded': isMainWeaponExpanded,
      'isSubWeaponExpanded': isSubWeaponExpanded,
      'isArmorExpanded': isArmorExpanded,
      'isHelmetExpanded': isHelmetExpanded,
      'isRingExpanded': isRingExpanded,
      'isGachaExpanded': isGachaExpanded,
      'summary': Map<String, num>.from(summary),
    };
  }

  static String encodeBuildShareCode(Map<String, dynamic> build) {
    final Map<String, dynamic> shareBuild = _normalizeShareBuild(build);
    final List<dynamic> payload = _encodeShareV2Payload(shareBuild);
    final String encoded = base64UrlEncode(utf8.encode(jsonEncode(payload)));
    return '$shareCodePrefix$encoded';
  }

  static Map<String, dynamic>? decodeBuildShareCode(
    String rawCode, {
    required Map<String, num> summaryTemplate,
    int fallbackIndex = 0,
  }) {
    final String compact = rawCode.replaceAll(RegExp(r'\s+'), '');
    if (compact.isEmpty) {
      return null;
    }
    if (compact.startsWith(shareCodePrefix)) {
      return _decodeShareV2FromEncoded(
        compact.substring(shareCodePrefix.length),
        summaryTemplate: summaryTemplate,
        fallbackIndex: fallbackIndex,
      );
    }
    if (compact.startsWith(_shareCodePrefixV1)) {
      return _decodeShareV1FromEncoded(
        compact.substring(_shareCodePrefixV1.length),
        summaryTemplate: summaryTemplate,
        fallbackIndex: fallbackIndex,
      );
    }

    final Map<String, dynamic>? decodedAsV2 = _decodeShareV2FromEncoded(
      compact,
      summaryTemplate: summaryTemplate,
      fallbackIndex: fallbackIndex,
    );
    if (decodedAsV2 != null) {
      return decodedAsV2;
    }
    return _decodeShareV1FromEncoded(
      compact,
      summaryTemplate: summaryTemplate,
      fallbackIndex: fallbackIndex,
    );
  }

  static List<dynamic> _encodeShareV2Payload(Map<String, dynamic> shareBuild) {
    final List<dynamic> payload = <dynamic>[
      _encodeCharacterCompact(shareBuild['character']),
    ];
    for (final String key in _shareV2FieldOrder) {
      payload.add(_encodeV2FieldValue(key, shareBuild[key]));
    }
    while (payload.length > 1 && payload.last == null) {
      payload.removeLast();
    }
    return payload;
  }

  static List<int> _encodeCharacterCompact(dynamic rawCharacter) {
    final Map<dynamic, dynamic> characterMap = rawCharacter is Map
        ? rawCharacter
        : const <dynamic, dynamic>{};
    return <int>[
      readIntValue(characterMap['STR'], fallback: 1).clamp(1, 510),
      readIntValue(characterMap['DEX'], fallback: 1).clamp(1, 510),
      readIntValue(characterMap['INT'], fallback: 1).clamp(1, 510),
      readIntValue(characterMap['AGI'], fallback: 1).clamp(1, 510),
      readIntValue(characterMap['VIT'], fallback: 1).clamp(1, 510),
    ];
  }

  static dynamic _encodeV2FieldValue(String key, dynamic value) {
    switch (key) {
      case 'name':
        final String text = readStringValue(value).trim();
        if (text.isEmpty || text == 'Shared Build') {
          return null;
        }
        return text;
      case 'level':
        final int normalized = readIntValue(value, fallback: 1).clamp(1, 999);
        return normalized == 1 ? null : normalized;
      case 'totalStatPoints':
        final int normalized = readIntValue(
          value,
          fallback: defaultTotalStatPoints,
        ).clamp(minTotalStatPoints, maxTotalStatPoints);
        return normalized == defaultTotalStatPoints ? null : normalized;
      case 'personalStatType':
        final String type = normalizePersonalStatType(value);
        final int index = personalStatOptions.indexOf(type);
        return index <= 0 ? null : index;
      case 'personalStatValue':
        final int normalized = readIntValue(value, fallback: 0).clamp(0, 255);
        return normalized == 0 ? null : normalized;
      case 'enhMain':
      case 'enhSub':
      case 'enhArmor':
      case 'enhHelmet':
      case 'enhRing':
        final int normalized = readIntValue(value, fallback: 0).clamp(0, 15);
        return normalized == 0 ? null : normalized;
      case 'armorMode':
        final String normalized = normalizeArmorMode(value);
        switch (normalized) {
          case 'heavy':
            return 1;
          case 'light':
            return 2;
          default:
            return null;
        }
      default:
        final String text = readStringValue(value).trim();
        if (text.isEmpty) {
          return null;
        }
        return text;
    }
  }

  static Map<String, dynamic>? _decodeShareV2FromEncoded(
    String encoded, {
    required Map<String, num> summaryTemplate,
    required int fallbackIndex,
  }) {
    if (encoded.isEmpty) {
      return null;
    }
    try {
      final String normalizedEncoded = base64Url.normalize(encoded);
      final List<int> bytes = base64Url.decode(normalizedEncoded);
      final dynamic decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! List) {
        return null;
      }
      final Map<String, dynamic> rawBuild = _decodeShareV2Payload(decoded);
      return normalizeBuildSnapshot(
        rawBuild,
        fallbackIndex,
        summaryTemplate: summaryTemplate,
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _decodeShareV2Payload(List<dynamic> payload) {
    final Map<String, dynamic> build = <String, dynamic>{};
    final dynamic rawCharacter = payload.isEmpty ? null : payload[0];
    build['character'] = _decodeCharacterCompact(rawCharacter);
    for (int i = 0; i < _shareV2FieldOrder.length; i++) {
      final int payloadIndex = i + 1;
      if (payloadIndex >= payload.length) {
        break;
      }
      final String key = _shareV2FieldOrder[i];
      final dynamic value = _decodeV2FieldValue(key, payload[payloadIndex]);
      if (value == null) {
        continue;
      }
      build[key] = value;
    }
    return build;
  }

  static Map<String, int> _decodeCharacterCompact(dynamic rawCharacter) {
    if (rawCharacter is List) {
      return <String, int>{
        'STR': readIntValue(
          rawCharacter.isNotEmpty ? rawCharacter[0] : null,
          fallback: 1,
        ).clamp(1, 510),
        'DEX': readIntValue(
          rawCharacter.length > 1 ? rawCharacter[1] : null,
          fallback: 1,
        ).clamp(1, 510),
        'INT': readIntValue(
          rawCharacter.length > 2 ? rawCharacter[2] : null,
          fallback: 1,
        ).clamp(1, 510),
        'AGI': readIntValue(
          rawCharacter.length > 3 ? rawCharacter[3] : null,
          fallback: 1,
        ).clamp(1, 510),
        'VIT': readIntValue(
          rawCharacter.length > 4 ? rawCharacter[4] : null,
          fallback: 1,
        ).clamp(1, 510),
      };
    }
    return const <String, int>{
      'STR': 1,
      'DEX': 1,
      'INT': 1,
      'AGI': 1,
      'VIT': 1,
    };
  }

  static dynamic _decodeV2FieldValue(String key, dynamic value) {
    if (value == null) {
      return null;
    }
    switch (key) {
      case 'level':
        return readIntValue(value, fallback: 1).clamp(1, 999);
      case 'totalStatPoints':
        return readIntValue(
          value,
          fallback: defaultTotalStatPoints,
        ).clamp(minTotalStatPoints, maxTotalStatPoints);
      case 'personalStatType':
        final int index = readIntValue(value, fallback: 0);
        if (index >= 0 && index < personalStatOptions.length) {
          return personalStatOptions[index];
        }
        return normalizePersonalStatType(value);
      case 'personalStatValue':
        return readIntValue(value, fallback: 0).clamp(0, 255);
      case 'enhMain':
      case 'enhSub':
      case 'enhArmor':
      case 'enhHelmet':
      case 'enhRing':
        return readIntValue(value, fallback: 0).clamp(0, 15);
      case 'armorMode':
        final int modeCode = readIntValue(value, fallback: 0);
        switch (modeCode) {
          case 1:
            return 'heavy';
          case 2:
            return 'light';
          default:
            return 'normal';
        }
      default:
        final String text = readStringValue(value).trim();
        if (text.isEmpty) {
          return null;
        }
        return text;
    }
  }

  static Map<String, dynamic>? _decodeShareV1FromEncoded(
    String encoded, {
    required Map<String, num> summaryTemplate,
    required int fallbackIndex,
  }) {
    if (encoded.isEmpty) {
      return null;
    }
    try {
      final String normalizedEncoded = base64Url.normalize(encoded);
      final List<int> bytes = base64Url.decode(normalizedEncoded);
      final dynamic decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) {
        return null;
      }
      final Map<String, dynamic> payload = Map<String, dynamic>.from(decoded);
      final int version = readIntValue(payload['v'], fallback: 1);
      if (version > 1) {
        return null;
      }
      final dynamic rawBuild = payload['b'] ?? payload['build'] ?? payload;
      if (rawBuild is! Map) {
        return null;
      }
      return normalizeBuildSnapshot(
        Map<String, dynamic>.from(rawBuild),
        fallbackIndex,
        summaryTemplate: summaryTemplate,
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _normalizeShareBuild(Map<String, dynamic> raw) {
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final String key in _shareBuildKeys) {
      final dynamic value = raw[key];
      if (value == null) {
        continue;
      }
      if (value is String && value.trim().isEmpty) {
        continue;
      }
      result[key] = value;
    }

    final dynamic rawCharacter = raw['character'];
    if (rawCharacter is Map) {
      result['character'] = <String, int>{
        for (final String key in characterStatKeys)
          key: readIntValue(rawCharacter[key]),
      };
    }

    if (!result.containsKey('name') ||
        readStringValue(result['name']).trim().isEmpty) {
      result['name'] = 'Shared Build';
    }
    return result;
  }
}
