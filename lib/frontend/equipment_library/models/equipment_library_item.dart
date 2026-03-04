class EquipmentLibraryItem {
  const EquipmentLibraryItem({
    required this.id,
    required this.key,
    required this.name,
    required this.color,
    required this.type,
    required this.stats,
    required this.imageAssetPath,
    this.upgradeFrom,
  });

  final int id;
  final String key;
  final String name;
  final String color;
  final String type;
  final List<EquipmentStat> stats;
  final String imageAssetPath;
  final String? upgradeFrom;

  factory EquipmentLibraryItem.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> display =
        (json['display'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final Map<String, dynamic>? upgrade =
        json['upgrade'] as Map<String, dynamic>?;
    final List<dynamic> statsJson =
        (json['stats'] as List<dynamic>?) ?? <dynamic>[];

    return EquipmentLibraryItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      key: json['key']?.toString().trim() ?? '',
      name: display['name']?.toString().trim() ?? '',
      color: display['color']?.toString().trim() ?? 'unknown',
      type: json['type']?.toString().trim() ?? 'unknown',
      stats: statsJson
          .whereType<Map<String, dynamic>>()
          .map(EquipmentStat.fromJson)
          .toList(growable: false),
      imageAssetPath: _readImageAssetPath(json, display),
      upgradeFrom: upgrade == null ? null : upgrade['from']?.toString().trim(),
    );
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
}

class EquipmentStat {
  const EquipmentStat({
    required this.statKey,
    required this.value,
    required this.valueType,
  });

  final String statKey;
  final num value;
  final String valueType;

  factory EquipmentStat.fromJson(Map<String, dynamic> json) {
    return EquipmentStat(
      statKey: json['stat_key']?.toString() ?? '',
      value: (json['value'] as num?) ?? 0,
      valueType: json['value_type']?.toString() ?? 'flat',
    );
  }
}
