import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/custom_equipment_item.dart';

class CustomEquipmentStorageService {
  const CustomEquipmentStorageService();

  static const String _storageKey = 'custom_equipment_items_v1';

  Future<List<CustomEquipmentItem>> loadItems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = prefs.getString(_storageKey) ?? '[]';
    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      await prefs.remove(_storageKey);
      return const <CustomEquipmentItem>[];
    }
    if (decoded is! List) {
      await prefs.remove(_storageKey);
      return const <CustomEquipmentItem>[];
    }

    final List<CustomEquipmentItem> items = <CustomEquipmentItem>[];
    for (final dynamic row in decoded) {
      if (row is! Map) {
        continue;
      }
      try {
        final CustomEquipmentItem item = CustomEquipmentItem.fromJson(
          Map<String, dynamic>.from(row),
        );
        if (item.isValid) {
          items.add(item);
        }
      } catch (_) {
        continue;
      }
    }

    return items.toList(growable: false);
  }

  Future<void> saveItems(List<CustomEquipmentItem> items) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = jsonEncode(
      items.map((CustomEquipmentItem item) => item.toJson()).toList(),
    );
    await prefs.setString(_storageKey, raw);
  }

  Future<List<CustomEquipmentItem>> upsertItem(CustomEquipmentItem item) async {
    final List<CustomEquipmentItem> items = await loadItems();
    final List<CustomEquipmentItem> next =
        <CustomEquipmentItem>[
          for (final CustomEquipmentItem existing in items)
            if (existing.id != item.id) existing,
          item.copyWith(updatedAt: DateTime.now()),
        ]..sort((CustomEquipmentItem a, CustomEquipmentItem b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
    await saveItems(next);
    return next;
  }

  Future<List<CustomEquipmentItem>> deleteItem(String id) async {
    final List<CustomEquipmentItem> items = await loadItems();
    final List<CustomEquipmentItem> next = items
        .where((CustomEquipmentItem item) => item.id != id.trim())
        .toList(growable: false);
    await saveItems(next);
    return next;
  }
}
