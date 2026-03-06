import '../../equipment_library/models/equipment_library_item.dart';
import '../../shared/toram_data_github_service.dart';

class CrystalLibraryEntry {
  const CrystalLibraryEntry({
    required this.key,
    required this.name,
    required this.category,
    required this.stats,
    required this.upgradeFrom,
  });

  final String key;
  final String name;
  final String category;
  final List<EquipmentStat> stats;
  final String? upgradeFrom;

  String get normalizedKey => key.trim().toLowerCase();
}

class CrystalLibraryService {
  const CrystalLibraryService._();

  static const Map<String, List<String>> _categoryRemoteCandidates =
      <String, List<String>>{
        'weapon': <String>['items/crysta/weapon/crysta_weapon.json'],
        'armor': <String>['items/crysta/armor/crysta_armor.json'],
        'additional': <String>[
          'items/crysta/additional/crysta_additional.json',
        ],
        'special': <String>['items/crysta/special/crysta_special.json'],
        'normal': <String>['items/crysta/normal/crysta_normal.json'],
      };

  static final Map<String, List<CrystalLibraryEntry>> _categoryCache =
      <String, List<CrystalLibraryEntry>>{};

  static Future<List<CrystalLibraryEntry>> loadByCategories(
    List<String> categories,
  ) async {
    final Set<String> normalizedCategories = categories
        .map((String value) => value.trim().toLowerCase())
        .where((String value) => value.isNotEmpty)
        .toSet();

    final List<String> validCategories = normalizedCategories
        .where(_categoryRemoteCandidates.containsKey)
        .toList(growable: false);

    if (validCategories.isEmpty) {
      return const <CrystalLibraryEntry>[];
    }

    final List<CrystalLibraryEntry> merged = <CrystalLibraryEntry>[];
    for (final String category in validCategories) {
      final List<CrystalLibraryEntry> loaded = await _loadCategory(category);
      if (loaded.isNotEmpty) {
        merged.addAll(loaded);
      }
    }

    final Map<String, CrystalLibraryEntry> uniqueByKey =
        <String, CrystalLibraryEntry>{};
    for (final CrystalLibraryEntry entry in merged) {
      final String normalizedKey = entry.normalizedKey;
      if (normalizedKey.isEmpty) {
        continue;
      }
      uniqueByKey.putIfAbsent(normalizedKey, () => entry);
    }

    final List<CrystalLibraryEntry> items = uniqueByKey.values.toList(
      growable: false,
    )..sort(
        (CrystalLibraryEntry a, CrystalLibraryEntry b) =>
            a.name.compareTo(b.name),
      );
    return items;
  }

  static Future<List<CrystalLibraryEntry>> _loadCategory(String category) async {
    final List<CrystalLibraryEntry>? cached = _categoryCache[category];
    if (cached != null) {
      return cached;
    }

    final List<String> candidates = _categoryRemoteCandidates[category]!;
    final List<CrystalLibraryEntry> merged = <CrystalLibraryEntry>[];
    bool hasLoadedRemote = false;

    for (final String remotePath in candidates) {
      try {
        final List<CrystalLibraryEntry> parsed = await _loadFromRemote(
          remotePath: remotePath,
          fallbackCategory: category,
        );
        hasLoadedRemote = true;
        if (parsed.isNotEmpty) {
          merged.addAll(parsed);
        }
      } catch (_) {
        continue;
      }
    }

    if (!hasLoadedRemote) {
      throw StateError('Failed to load remote crystal category: $category');
    }

    final List<CrystalLibraryEntry> result = merged.toList(growable: false);
    _categoryCache[category] = result;
    return result;
  }

  static Future<List<CrystalLibraryEntry>> _loadFromRemote({
    required String remotePath,
    required String fallbackCategory,
  }) async {
    final dynamic decoded = await ToramDataGithubService.loadJson(remotePath);
    final List<Map<String, dynamic>> rows = _normalizeRows(decoded);
    if (rows.isEmpty) {
      return const <CrystalLibraryEntry>[];
    }

    final List<CrystalLibraryEntry> entries = <CrystalLibraryEntry>[];
    for (final Map<String, dynamic> row in rows) {
      final String key = row['key']?.toString().trim() ?? '';
      if (key.isEmpty) {
        continue;
      }
      final Map<String, dynamic> display =
          (row['display'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final String displayName = display['name']?.toString().trim() ?? '';
      final String directName = row['name']?.toString().trim() ?? '';
      final String category = row['type']?.toString().trim().toLowerCase() ??
          fallbackCategory;
      final Map<String, dynamic>? upgrade =
          row['upgrade'] is Map ? Map<String, dynamic>.from(row['upgrade'] as Map) : null;
      final List<dynamic> statsJson =
          (row['stats'] as List<dynamic>?) ?? const <dynamic>[];
      final List<EquipmentStat> stats = <EquipmentStat>[];
      for (final Map<String, dynamic> statJson
          in statsJson.whereType<Map<String, dynamic>>()) {
        try {
          stats.add(EquipmentStat.fromJson(statJson));
        } catch (_) {}
      }
      entries.add(
        CrystalLibraryEntry(
          key: key,
          name: displayName.isNotEmpty
              ? displayName
              : (directName.isNotEmpty ? directName : key),
          category: category.isEmpty ? fallbackCategory : category,
          stats: stats.toList(growable: false),
          upgradeFrom: upgrade == null
              ? null
              : upgrade['from']?.toString().trim(),
        ),
      );
    }

    return entries.toList(growable: false);
  }

  static List<Map<String, dynamic>> _normalizeRows(dynamic decoded) {
    if (decoded is List<dynamic>) {
      return decoded
          .whereType<Map>()
          .map((Map map) => Map<String, dynamic>.from(map))
          .toList(growable: false);
    }

    if (decoded is Map<String, dynamic>) {
      final List<Map<String, dynamic>> rows = <Map<String, dynamic>>[];
      for (final MapEntry<String, dynamic> entry in decoded.entries) {
        if (entry.value is! Map) {
          continue;
        }
        final Map<String, dynamic> row = Map<String, dynamic>.from(
          entry.value as Map,
        );
        row.putIfAbsent('key', () => entry.key);
        rows.add(row);
      }
      return rows;
    }

    return const <Map<String, dynamic>>[];
  }
}
