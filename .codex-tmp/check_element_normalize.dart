import 'dart:convert';
import 'dart:io';

import 'package:toramonline/equipment_library/models/equipment_library_item.dart';

void main() {
  final List<dynamic> rows = jsonDecode(
    File('assets/data/items/equipment/weapon/arrow.json').readAsStringSync(),
  ) as List<dynamic>;

  EquipmentStat? fromElement;
  EquipmentStat? fromWaterElement;

  for (final dynamic raw in rows) {
    if (raw is! Map<String, dynamic>) {
      continue;
    }
    final item = EquipmentLibraryItem.fromJson(raw);
    for (final stat in item.stats) {
      if (stat.statKey == 'water_element' && fromWaterElement == null) {
        fromWaterElement = stat;
      }
      if (stat.statKey == 'fire_element' && fromElement == null) {
        fromElement = stat;
      }
    }
  }

  print('sample from element key => ${fromElement?.statKey}=${fromElement?.value}');
  print('sample from *_element key => ${fromWaterElement?.statKey}=${fromWaterElement?.value}');
}
