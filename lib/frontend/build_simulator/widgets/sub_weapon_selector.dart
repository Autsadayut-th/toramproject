import 'package:flutter/material.dart';

import '../../equipment_library/models/equipment_library_item.dart';
import 'equipment_slot_selector.dart';

class SubWeaponEquipmentSelector extends StatelessWidget {
  const SubWeaponEquipmentSelector({
    super.key,
    required this.selectedId,
    required this.selectedEquipmentItem,
    required this.statPreview,
    required this.allowedItemTypes,
    required this.onEquipChanged,
    required this.enhance,
    required this.onEnhChanged,
  });

  final String? selectedId;
  final EquipmentLibraryItem? selectedEquipmentItem;
  final List<String> statPreview;
  final List<String>? allowedItemTypes;
  final ValueChanged<String?> onEquipChanged;
  final int enhance;
  final ValueChanged<int> onEnhChanged;

  @override
  Widget build(BuildContext context) {
    return EquipmentSlotSelector(
      idLabel: 'Sub Weapon ID',
      idHint: 'e.g. sub_weapon_001',
      selectedId: selectedId,
      selectedEquipmentItem: selectedEquipmentItem,
      onEquipChanged: onEquipChanged,
      pickInitialCategory: 'Weapon',
      allowedCategories: const <String>['Weapon'],
      allowedItemTypes: allowedItemTypes,
      pickTitle: 'Select Sub Weapon',
      statsLabel: 'Weapon Stats',
      statPreview: statPreview,
      enhance: enhance,
      onEnhChanged: onEnhChanged,
    );
  }
}
