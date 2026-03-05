import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/equipment_library_item.dart';

class EquipmentLibraryRepository {
  static const Map<String, List<String>> _categoryAssetCandidates =
      <String, List<String>>{
        'Weapon': <String>[
          'assets/data/equipment_library/weapon/1h_sword.json',
          'assets/data/equipment_library/weapon/2h_sword.json',
          'assets/data/equipment_library/weapon/bow.json',
          'assets/data/equipment_library/weapon/bowgun.json',
          'assets/data/equipment_library/weapon/halberd.json',
          'assets/data/equipment_library/weapon/katana.json',
          'assets/data/equipment_library/weapon/knuckles.json',
          'assets/data/equipment_library/weapon/staff.json',
          'assets/data/equipment_library/weapon/magic_device.json',
          'assets/data/equipment_library/weapon/dagger.json',
          'assets/data/equipment_library/weapon/arrow.json',
          'assets/data/equipment_library/weapon/shield.json',
          'assets/data/equipment_library/weapon/ninjutsu_scroll.json',
        ],
        'Armor': <String>[
          'assets/data/equipment_library/armor/armor.json',
        ],
        'Additional': <String>[
          'assets/data/equipment_library/additional/additional.json',
        ],
        'Special': <String>[
          'assets/data/equipment_library/special/special.json',
        ],
      };

  List<String> get categories =>
      _categoryAssetCandidates.keys.toList(growable: false);

  Future<Map<String, List<EquipmentLibraryItem>>> loadAllCategories() async {
    final Map<String, List<EquipmentLibraryItem>> allCategories =
        <String, List<EquipmentLibraryItem>>{};

    for (final MapEntry<String, List<String>> entry
        in _categoryAssetCandidates.entries) {
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
    List<String> assetPaths,
  ) async {
    final List<EquipmentLibraryItem> mergedItems = <EquipmentLibraryItem>[];
    final List<String> errors = <String>[];
    bool hasLoadedAnyAsset = false;

    for (final String assetPath in assetPaths) {
      try {
        final List<EquipmentLibraryItem> items = await _loadFromAsset(assetPath);
        hasLoadedAnyAsset = true;
        if (items.isNotEmpty) {
          mergedItems.addAll(items);
        }
      } catch (error) {
        errors.add('$assetPath -> $error');
      }
    }

    if (!hasLoadedAnyAsset) {
      throw StateError(
        'Failed to load equipment assets.\n${errors.join('\n')}',
      );
    }

    return _sanitizeItems(mergedItems);
  }

  Future<List<EquipmentLibraryItem>> _loadFromAsset(String assetPath) async {
    final String rawJson = await rootBundle.loadString(assetPath);
    final dynamic decoded = jsonDecode(rawJson);
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
