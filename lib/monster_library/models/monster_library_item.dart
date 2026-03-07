class MonsterLibraryItem {
  const MonsterLibraryItem({
    required this.id,
    required this.name,
    required this.level,
    required this.hp,
    required this.element,
    required this.family,
    required this.mapKey,
    required this.mapName,
    required this.drops,
  });

  final String id;
  final String name;
  final int level;
  final int hp;
  final String element;
  final String family;
  final String mapKey;
  final String mapName;
  final List<String> drops;

  factory MonsterLibraryItem.fromJson(
    Map<String, dynamic> json, {
    required String mapName,
  }) {
    return MonsterLibraryItem(
      id: _stringValue(json['id']),
      name: _stringValue(json['name']),
      level: _intValue(json['level']),
      hp: _intValue(json['hp']),
      element: _stringValue(json['element']),
      family: _stringValue(json['family']),
      mapKey: _stringValue(json['mapKey']),
      mapName: mapName,
      drops: _stringListValue(json['drops']),
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
