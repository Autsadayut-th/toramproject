import 'package:flutter/material.dart';

import 'equipment_slot_selector.dart';

class HelmetEquipmentSelector extends StatelessWidget {
  const HelmetEquipmentSelector({
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
      idLabel: 'Helmet ID',
      idHint: 'e.g. helmet_001',
      selectedId: selectedId,
      onEquipChanged: onEquipChanged,
      pickInitialCategory: 'Additional',
      allowedCategories: const <String>['Additional'],
      pickTitle: 'Select Helmet',
      statsLabel: 'Item Stats',
      statPreview: statPreview,
      enhance: enhance,
      onEnhChanged: onEnhChanged,
      crystalCategoryFilters: const <String>['additional', 'normal'],
      crystal1: crystal1,
      crystal2: crystal2,
      onCrystal1Changed: onCrystal1Changed,
      onCrystal2Changed: onCrystal2Changed,
    );
  }
}

