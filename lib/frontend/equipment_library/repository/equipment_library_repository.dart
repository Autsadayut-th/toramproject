import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/equipment_library_item.dart';

class EquipmentLibraryRepository {
  static const Map<String, String> _categoryAssetPaths = <String, String>{
    'Weapon': 'assets/data/equipment_library/weapon_structured.json',
    'Armor': 'assets/data/equipment_library/armor_structured.json',
    'Additional': 'assets/data/equipment_library/additional_structured.json',
    'Special': 'assets/data/equipment_library/special_structured.json',
    'Normal': 'assets/data/equipment_library/normal_structured.json',
  };

  List<String> get categories =>
      _categoryAssetPaths.keys.toList(growable: false);

  Future<Map<String, List<EquipmentLibraryItem>>> loadAllCategories() async {
    final Iterable<Future<MapEntry<String, List<EquipmentLibraryItem>>>>
    loadTasks = _categoryAssetPaths.entries.map((
      MapEntry<String, String> entry,
    ) async {
      final List<EquipmentLibraryItem> items = await _loadFromAsset(
        entry.value,
      );
      return MapEntry<String, List<EquipmentLibraryItem>>(entry.key, items);
    });

    final List<MapEntry<String, List<EquipmentLibraryItem>>> loadedEntries =
        await Future.wait(loadTasks);
    return Map<String, List<EquipmentLibraryItem>>.fromEntries(loadedEntries);
  }

  Future<List<EquipmentLibraryItem>> _loadFromAsset(String assetPath) async {
    final String rawJson = await rootBundle.loadString(assetPath);
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! List<dynamic>) {
      return const <EquipmentLibraryItem>[];
    }

    final Iterable<EquipmentLibraryItem> parsedItems = decoded
        .whereType<Map<String, dynamic>>()
        .map(EquipmentLibraryItem.fromJson);

    return _sanitizeItems(parsedItems);
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
