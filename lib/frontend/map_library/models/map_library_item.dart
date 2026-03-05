class MapLibraryItem {
  const MapLibraryItem({
    required this.key,
    required this.name,
    required this.region,
    required this.recommendedLevelMin,
    required this.recommendedLevelMax,
    required this.monsterIds,
  });

  final String key;
  final String name;
  final String region;
  final int recommendedLevelMin;
  final int recommendedLevelMax;
  final List<String> monsterIds;

  factory MapLibraryItem.fromJson(Map<String, dynamic> json) {
    return MapLibraryItem(
      key: _stringValue(json['key']),
      name: _stringValue(json['name']),
      region: _stringValue(json['region']),
      recommendedLevelMin: _intValue(json['recommendedLevelMin']),
      recommendedLevelMax: _intValue(json['recommendedLevelMax']),
      monsterIds: _stringListValue(json['monsterIds']),
    );
  }

  static String _stringValue(dynamic raw) {
    return raw?.toString().trim() ?? '';
  }

  static int _intValue(dynamic raw) {
    if (raw is int) {
      return raw;
    }
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is String) {
      return int.tryParse(raw.trim()) ?? 0;
    }
    return 0;
  }

  static List<String> _stringListValue(dynamic raw) {
    if (raw is! List) {
      return const <String>[];
    }
    return raw
        .map((dynamic item) => _stringValue(item))
        .where((String item) {
          return item.isNotEmpty;
        })
        .toList(growable: false);
  }
}

class MapMonsterInfo {
  const MapMonsterInfo({
    required this.id,
    required this.name,
    required this.level,
    required this.element,
    required this.family,
  });

  final String id;
  final String name;
  final int level;
  final String element;
  final String family;

  factory MapMonsterInfo.fromJson(Map<String, dynamic> json) {
    return MapMonsterInfo(
      id: MapLibraryItem._stringValue(json['id']),
      name: MapLibraryItem._stringValue(json['name']),
      level: MapLibraryItem._intValue(json['level']),
      element: MapLibraryItem._stringValue(json['element']),
      family: MapLibraryItem._stringValue(json['family']),
    );
  }
}
