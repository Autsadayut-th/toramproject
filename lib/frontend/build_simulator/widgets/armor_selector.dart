import 'package:flutter/material.dart';

import 'equipment_slot_selector.dart';

class ArmorEquipmentSelector extends StatelessWidget {
  const ArmorEquipmentSelector({
    super.key,
    required this.selectedId,
    required this.statPreview,
    required this.onEquipChanged,
    required this.enhance,
    required this.onEnhChanged,
    required this.crystal1,
    required this.crystal2,
    required this.onCrystal1Changed,
    required this.onCrystal2Changed,
  });

  final String? selectedId;
  final List<String> statPreview;
  final ValueChanged<String?> onEquipChanged;
  final int enhance;
  final ValueChanged<int> onEnhChanged;
  final String? crystal1;
  final String? crystal2;
  final ValueChanged<String?> onCrystal1Changed;
  final ValueChanged<String?> onCrystal2Changed;

  @override
  Widget build(BuildContext context) {
    return EquipmentSlotSelector(
      idLabel: 'Armor ID',
      idHint: 'e.g. armor_001',
      selectedId: selectedId,
      onEquipChanged: onEquipChanged,
      pickInitialCategory: 'Armor',
      allowedCategories: const <String>['Armor'],
      pickTitle: 'Select Armor',
      statsLabel: 'Item Stats',
      statPreview: statPreview,
      enhance: enhance,
      onEnhChanged: onEnhChanged,
      crystalCategoryFilters: const <String>['armor', 'normal'],
      crystal1: crystal1,
      crystal2: crystal2,
      onCrystal1Changed: onCrystal1Changed,
      onCrystal2Changed: onCrystal2Changed,
    );
  }
}

