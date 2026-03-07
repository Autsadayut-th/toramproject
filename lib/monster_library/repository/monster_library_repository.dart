import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/monster_library_item.dart';

class MonsterLibraryRepository {
  static const String _monstersAssetPath =
      'assets/data/monster_library/monsters.json';
  static const String _mapsAssetPath = 'assets/data/monster_library/maps.json';

  Future<List<MonsterLibraryItem>> loadAll() async {
    final List<dynamic> monstersRaw = await _loadListAsset(_monstersAssetPath);
    final List<dynamic> mapsRaw = await _loadListAsset(_mapsAssetPath);

    final Map<String, String> mapNameByKey = <String, String>{
      for (final Map<String, dynamic> item in mapsRaw.whereType<Map>().map(
        (Map raw) => Map<String, dynamic>.from(raw),
      ))
        _stringValue(item['key']): _stringValue(item['name']),
    };

    final List<MonsterLibraryItem> monsters =
        monstersRaw
            .whereType<Map>()
            .map((Map raw) {
              final Map<String, dynamic> item = Map<String, dynamic>.from(raw);
              final String mapKey = _stringValue(item['mapKey']);
              final String mapName = mapNameByKey[mapKey] ?? mapKey;
              return MonsterLibraryItem.fromJson(item, mapName: mapName);
            })
            .where(
              (MonsterLibraryItem item) =>
                  item.id.isNotEmpty && item.name.isNotEmpty,
            )
            .toList(growable: false)
          ..sort((MonsterLibraryItem a, MonsterLibraryItem b) {
            final int byLevel = a.level.compareTo(b.level);
            if (byLevel != 0) {
              return byLevel;
            }
            return a.name.compareTo(b.name);
          });

    return monsters;
  }

  List<String> familiesFrom(List<MonsterLibraryItem> items) {
    final Set<String> families = items
        .map((MonsterLibraryItem item) => item.family.trim())
        .where((String family) => family.isNotEmpty)
        .toSet();
    final List<String> sortedFamilies = families.toList(growable: false)
      ..sort((String a, String b) => a.compareTo(b));
    return <String>['All', ...sortedFamilies];
  }

  Future<List<dynamic>> _loadListAsset(String path) async {
    final String raw = await rootBundle.loadString(path);
    final dynamic decoded = jsonDecode(raw);
    if (decoded is List<dynamic>) {
      return decoded;
    }
    return const <dynamic>[];
  }

  static String _stringValue(dynamic raw) {
    return raw?.toString().trim() ?? '';
  }
}
