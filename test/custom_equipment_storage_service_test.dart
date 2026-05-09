import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toramonline/custom_equipment/models/custom_equipment_item.dart';
import 'package:toramonline/custom_equipment/models/custom_equipment_stat.dart';
import 'package:toramonline/custom_equipment/services/custom_equipment_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const CustomEquipmentStorageService storage = CustomEquipmentStorageService();
  const String storageKey = 'custom_equipment_items_v1';

  CustomEquipmentItem sampleItem({String id = 'item-1'}) {
    return CustomEquipmentItem(
      id: id,
      key: 'custom_$id',
      name: 'Custom $id',
      category: 'weapon',
      type: '1h_sword',
      stats: const <CustomEquipmentStat>[
        CustomEquipmentStat(statKey: 'atk', value: 10),
      ],
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('loadItems returns empty list and clears corrupted JSON', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      storageKey: '{invalid json',
    });

    final List<CustomEquipmentItem> loaded = await storage.loadItems();
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    expect(loaded, isEmpty);
    expect(prefs.containsKey(storageKey), isFalse);
  });

  test('loadItems ignores malformed rows and keeps valid items', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      storageKey:
          '[{"id":"a","key":"ka","name":"A","category":"weapon","type":"staff","stats":[],"createdAt":"2024-01-01T00:00:00.000Z","updatedAt":"2024-01-01T00:00:00.000Z"},"bad-row",{"id":"","key":"x","name":"Broken","category":"weapon","type":"staff","stats":[],"createdAt":"2024-01-01T00:00:00.000Z","updatedAt":"2024-01-01T00:00:00.000Z"}]',
    });

    final List<CustomEquipmentItem> loaded = await storage.loadItems();

    expect(loaded.length, 1);
    expect(loaded.first.id, 'a');
  });

  test('upsertItem recovers from corrupted storage and saves new item', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      storageKey: 'not-json',
    });

    final List<CustomEquipmentItem> next = await storage.upsertItem(sampleItem());

    expect(next.length, 1);
    expect(next.first.id, 'item-1');
  });
}
