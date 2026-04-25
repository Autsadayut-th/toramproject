import 'custom_equipment_stat.dart';

class CustomEquipmentItem {
  const CustomEquipmentItem({
    required this.id,
    required this.key,
    required this.name,
    required this.category,
    required this.type,
    required this.stats,
    required this.createdAt,
    required this.updatedAt,
    this.imageAssetPath = '',
    this.color = 'custom',
    this.notes,
    this.isFavorite = false,
    this.source = 'custom',
  });

  final String id;
  final String key;
  final String name;
  final String category;
  final String type;
  final List<CustomEquipmentStat> stats;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String imageAssetPath;
  final String color;
  final String? notes;
  final bool isFavorite;
  final String source;

  factory CustomEquipmentItem.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawStats = json['stats'] as List<dynamic>? ?? <dynamic>[];
    return CustomEquipmentItem(
      id: json['id']?.toString().trim() ?? '',
      key: json['key']?.toString().trim() ?? '',
      name: json['name']?.toString().trim() ?? '',
      category: json['category']?.toString().trim() ?? '',
      type: json['type']?.toString().trim() ?? '',
      stats: rawStats
          .whereType<Map>()
          .map(
            (Map raw) => CustomEquipmentStat.fromJson(
              Map<String, dynamic>.from(raw),
            ),
          )
          .toList(growable: false),
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
      imageAssetPath: json['imageAssetPath']?.toString().trim() ?? '',
      color: json['color']?.toString().trim() ?? 'custom',
      notes: _readOptionalString(json['notes']),
      isFavorite: json['isFavorite'] == true,
      source: json['source']?.toString().trim() ?? 'custom',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'key': key,
      'name': name,
      'category': category,
      'type': type,
      'stats': stats.map((CustomEquipmentStat stat) => stat.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageAssetPath': imageAssetPath,
      'color': color,
      'notes': notes,
      'isFavorite': isFavorite,
      'source': source,
    };
  }

  CustomEquipmentItem copyWith({
    String? id,
    String? key,
    String? name,
    String? category,
    String? type,
    List<CustomEquipmentStat>? stats,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageAssetPath,
    String? color,
    String? notes,
    bool? isFavorite,
    String? source,
  }) {
    return CustomEquipmentItem(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      category: category ?? this.category,
      type: type ?? this.type,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageAssetPath: imageAssetPath ?? this.imageAssetPath,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      source: source ?? this.source,
    );
  }

  bool get isValid {
    return id.trim().isNotEmpty &&
        key.trim().isNotEmpty &&
        name.trim().isNotEmpty &&
        category.trim().isNotEmpty &&
        type.trim().isNotEmpty;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static String? _readOptionalString(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
