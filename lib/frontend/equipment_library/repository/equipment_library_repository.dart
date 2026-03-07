import '../models/equipment_library_item.dart';
import '../../shared/toram_data_github_service.dart';

class EquipmentLibraryRepository {
  static const Map<String, List<String>> _categoryRemoteCandidates =
      <String, List<String>>{
        'Weapon': <String>[
          'items/equipment/weapon/1h_sword.json',
          'items/equipment/weapon/2h_sword.json',
          'items/equipment/weapon/bow.json',
          'items/equipment/weapon/bowgun.json',
          'items/equipment/weapon/halberd.json',
          'items/equipment/weapon/katana.json',
          'items/equipment/weapon/knuckles.json',
          'items/equipment/weapon/staff.json',
          'items/equipment/weapon/magic_device.json',
          'items/equipment/weapon/dagger.json',
          'items/equipment/weapon/arrow.json',
          'items/equipment/weapon/shield.json',
          'items/equipment/weapon/ninjutsu_scroll.json',
        ],
        'Armor': <String>['items/equipment/armor/armor.json'],
        'Additional': <String>['items/equipment/additional/additional.json'],
        'Special': <String>['items/equipment/special/special.json'],
        'Crystal': <String>[
          'items/crysta/weapon/crysta_weapon.json',
          'items/crysta/armor/crysta_armor.json',
          'items/crysta/additional/crysta_additional.json',
          'items/crysta/special/crysta_special.json',
          'items/crysta/normal/crysta_normal.json',
        ],
      };

  List<String> get categories =>
      _categoryRemoteCandidates.keys.toList(growable: false);

  Future<Map<String, List<EquipmentLibraryItem>>> loadAllCategories() async {
    final Map<String, List<EquipmentLibraryItem>> allCategories =
        <String, List<EquipmentLibraryItem>>{};

    for (final MapEntry<String, List<String>> entry
        in _categoryRemoteCandidates.entries) {
      final List<EquipmentLibraryItem> items = await _loadFromAssets(
        entry.value,
      );
      if (items.isNotEmpty) {
        allCategories[entry.key] = items;
      }
    }

    return allCategories;
  }

  Future<List<EquipmentLibraryItem>> _loadFromAssets(
    List<String> remotePaths,
  ) async {
    final List<EquipmentLibraryItem> mergedItems = <EquipmentLibraryItem>[];
    final List<String> errors = <String>[];
    bool hasLoadedAnyRemote = false;

    for (final String remotePath in remotePaths) {
      try {
        final List<EquipmentLibraryItem> items = await _loadFromRemote(
          remotePath,
        );
        hasLoadedAnyRemote = true;
        if (items.isNotEmpty) {
          mergedItems.addAll(items);
        }
      } catch (error) {
        errors.add('$remotePath -> $error');
      }
    }

    if (!hasLoadedAnyRemote) {
      throw StateError(
        'Failed to load remote equipment data.\n${errors.join('\n')}',
      );
    }

    return _sanitizeItems(mergedItems);
  }

  Future<List<EquipmentLibraryItem>> _loadFromRemote(String remotePath) async {
    final dynamic decoded = await ToramDataGithubService.loadJson(remotePath);
    final List<Map<String, dynamic>> normalizedItems = _normalizeItems(decoded);
    if (normalizedItems.isEmpty) {
      return const <EquipmentLibraryItem>[];
    }

    final List<EquipmentLibraryItem> parsedItems = <EquipmentLibraryItem>[];
    for (final Map<String, dynamic> itemJson in normalizedItems) {
      try {
        parsedItems.add(EquipmentLibraryItem.fromJson(itemJson));
      } catch (_) {}
    }

    return parsedItems;
  }

  List<Map<String, dynamic>> _normalizeItems(dynamic decoded) {
    if (decoded is List<dynamic>) {
      return decoded
          .whereType<Map>()
          .map((Map map) => Map<String, dynamic>.from(map))
          .toList(growable: false);
    }

    if (decoded is Map<String, dynamic>) {
      final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];
      for (final MapEntry<String, dynamic> entry in decoded.entries) {
        if (entry.value is! Map) {
          continue;
        }
        final Map<String, dynamic> normalized = Map<String, dynamic>.from(
          entry.value as Map,
        );
        normalized.putIfAbsent('key', () => entry.key);
        result.add(normalized);
      }
      return result;
    }

    return const <Map<String, dynamic>>[];
  }

  List<EquipmentLibraryItem> _sanitizeItems(
    Iterable<EquipmentLibraryItem> items,
  ) {
    final Map<String, EquipmentLibraryItem> uniqueByIdentity =
        <String, EquipmentLibraryItem>{};

    for (final EquipmentLibraryItem item in items) {
      final String normalizedName = item.name.trim();
      if (normalizedName.isEmpty) {
        continue;
      }

      final String normalizedKey = item.key.trim().toLowerCase();
      final String identity = normalizedKey.isEmpty
          ? 'name:${normalizedName.toLowerCase()}'
          : 'key:$normalizedKey';
      uniqueByIdentity.putIfAbsent(identity, () => item);
    }

    final List<EquipmentLibraryItem> sanitized =
        uniqueByIdentity.values.toList(growable: false)
          ..sort((EquipmentLibraryItem a, EquipmentLibraryItem b) {
            final int byName = a.name.compareTo(b.name);
            if (byName != 0) {
              return byName;
            }
            return a.id.compareTo(b.id);
          });

    return sanitized;
  }
}
