import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/map_library_item.dart';

class MapLibraryData {
  const MapLibraryData({required this.maps, required this.monsterById});

  final List<MapLibraryItem> maps;
  final Map<String, MapMonsterInfo> monsterById;
}

class MapLibraryRepository {
  static const String _monstersAssetPath =
      'assets/data/monster_library/monsters.json';
  static const String _mapsAssetPath = 'assets/data/monster_library/maps.json';

  Future<MapLibraryData> loadAll() async {
    final List<dynamic> mapsRaw = await _loadListAsset(_mapsAssetPath);
    final List<dynamic> monstersRaw = await _loadListAsset(_monstersAssetPath);

    final List<MapLibraryItem> maps =
        mapsRaw
            .whereType<Map>()
            .map(
              (Map raw) =>
                  MapLibraryItem.fromJson(Map<String, dynamic>.from(raw)),
            )
            .where(
              (MapLibraryItem item) =>
                  item.key.isNotEmpty && item.name.isNotEmpty,
            )
            .toList(growable: false)
          ..sort(
            (MapLibraryItem a, MapLibraryItem b) => a.name.compareTo(b.name),
          );

    final Map<String, MapMonsterInfo> monsterById = <String, MapMonsterInfo>{
      for (final MapMonsterInfo monster
          in monstersRaw
              .whereType<Map>()
              .map(
                (Map raw) =>
                    MapMonsterInfo.fromJson(Map<String, dynamic>.from(raw)),
              )
              .where((MapMonsterInfo item) => item.id.isNotEmpty))
        monster.id: monster,
    };

    return MapLibraryData(maps: maps, monsterById: monsterById);
  }

  List<String> regionsFrom(List<MapLibraryItem> items) {
    final Set<String> regions = items
        .map((MapLibraryItem item) => item.region.trim())
        .where((String region) => region.isNotEmpty)
        .toSet();
    final List<String> sortedRegions = regions.toList(growable: false)
      ..sort((String a, String b) => a.compareTo(b));
    return <String>['All', ...sortedRegions];
  }

  Future<List<dynamic>> _loadListAsset(String path) async {
    final String raw = await rootBundle.loadString(path);
    final dynamic decoded = jsonDecode(raw);
    if (decoded is List<dynamic>) {
      return decoded;
    }
    return const <dynamic>[];
  }
}
