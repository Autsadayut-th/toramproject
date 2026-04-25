import 'package:flutter/material.dart';

import '../../equipment_library/models/equipment_library_item.dart';
import 'equipment_slot_selector.dart';

class MainWeaponEquipmentSelector extends StatelessWidget {
  const MainWeaponEquipmentSelector({
    super.key,
    required this.selectedId,
    required this.selectedDisplayName,
    required this.selectedEquipmentItem,
    required this.searchCandidates,
    required this.allowedItemTypes,
    required this.statPreview,
    required this.onEquipChanged,
    required this.enhance,
    required this.onEnhChanged,
    required this.crystal1,
    required this.crystal2,
    required this.onCrystal1Changed,
    required this.onCrystal2Changed,
    this.onCreateCustomItem,
  });

  final String? selectedId;
  final String? selectedDisplayName;
  final EquipmentLibraryItem? selectedEquipmentItem;
  final List<EquipmentLibraryItem> searchCandidates;
  final List<String>? allowedItemTypes;
  final List<String> statPreview;
  final ValueChanged<String?> onEquipChanged;
  final int enhance;
  final ValueChanged<int> onEnhChanged;
  final String? crystal1;
  final String? crystal2;
  final ValueChanged<String?> onCrystal1Changed;
  final ValueChanged<String?> onCrystal2Changed;
  final VoidCallback? onCreateCustomItem;

  @override
  Widget build(BuildContext context) {
    return EquipmentSlotSelector(
      idLabel: 'Main Weapon',
      idHint: 'Search main weapon name...',
      selectedId: selectedId,
      selectedDisplayText: selectedDisplayName,
      selectedEquipmentItem: selectedEquipmentItem,
      enableInlineNameSearch: true,
      inlineSearchByNameOnly: true,
      inlineSearchCandidates: searchCandidates,
      onEquipChanged: onEquipChanged,
      pickInitialCategory: 'Weapon',
      allowedCategories: const <String>['Weapon'],
      allowedItemTypes: allowedItemTypes,
      pickTitle: 'Select Main Weapon',
      statsLabel: 'Weapon Stats',
      statPreview: statPreview,
      enhance: enhance,
      onEnhChanged: onEnhChanged,
      crystalCategoryFilters: const <String>['weapon', 'normal'],
      crystal1: crystal1,
      crystal2: crystal2,
      onCrystal1Changed: onCrystal1Changed,
      onCrystal2Changed: onCrystal2Changed,
      onCreateCustomItem: onCreateCustomItem,
      createCustomTooltip: 'Create custom main weapon',
    );
  }
}
