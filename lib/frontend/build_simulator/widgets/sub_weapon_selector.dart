import 'package:flutter/material.dart';

import 'equipment_slot_selector.dart';

class SubWeaponEquipmentSelector extends StatelessWidget {
  const SubWeaponEquipmentSelector({
    super.key,
    required this.selectedId,
    required this.statPreview,
    required this.onEquipChanged,
    required this.enhance,
    required this.onEnhChanged,
  });

  final String? selectedId;
  final List<String> statPreview;
  final ValueChanged<String?> onEquipChanged;
  final int enhance;
  final ValueChanged<int> onEnhChanged;

  @override
  Widget build(BuildContext context) {
    return EquipmentSlotSelector(
      idLabel: 'Sub Weapon ID',
      idHint: 'e.g. sub_weapon_001',
      selectedId: selectedId,
      onEquipChanged: onEquipChanged,
      pickInitialCategory: 'Weapon',
      allowedCategories: const <String>['Weapon'],
      pickTitle: 'Select Sub Weapon',
      statsLabel: 'Weapon Stats',
      statPreview: statPreview,
      enhance: enhance,
      onEnhChanged: onEnhChanged,
    );
  }
}
