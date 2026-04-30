import '../../equipment_library/models/equipment_library_item.dart';
import '../models/custom_equipment_item.dart';
import '../models/custom_equipment_stat.dart';

class CustomEquipmentMapper {
  const CustomEquipmentMapper._();

  static EquipmentLibraryItem toEquipmentLibraryItem(CustomEquipmentItem item) {
    return EquipmentLibraryItem(
      id: _stablePositiveInt(item.id),
      key: item.key,
      name: item.name,
      color: item.color,
      type: item.type,
      stats: item.stats
          .map((CustomEquipmentStat stat) {
            return EquipmentStat(
              statKey: stat.statKey,
              value: stat.value,
              valueType: stat.valueType,
            );
          })
          .toList(growable: false),
      imageAssetPath: item.imageAssetPath,
      obtainedFrom: const <EquipmentObtainedSource>[
        EquipmentObtainedSource(
          source: 'Custom Equipment',
          map: 'Player Created',
          sourceType: 'custom',
        ),
      ],
    );
  }

  static String normalizedCategory(String category) {
    final String value = category.trim().toLowerCase();
    switch (value) {
      case 'weapon':
      case 'armor':
        return value;
      default:
        return 'weapon';
    }
  }

  static int _stablePositiveInt(String input) {
    final int hash = input.hashCode & 0x7fffffff;
    return hash == 0 ? 1 : hash;
  }
}
