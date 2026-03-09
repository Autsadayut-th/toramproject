import 'package:flutter/material.dart';

import '../../equipment_library/models/equipment_library_item.dart';
import 'equipment_slot_selector.dart';

class ArmorEquipmentSelector extends StatelessWidget {
  const ArmorEquipmentSelector({
    super.key,
    required this.armorMode,
    required this.onArmorModeChanged,
    required this.selectedId,
    required this.selectedEquipmentItem,
    required this.searchCandidates,
    required this.statPreview,
    required this.onEquipChanged,
    required this.enhance,
    required this.onEnhChanged,
    required this.crystal1,
    required this.crystal2,
    required this.onCrystal1Changed,
    required this.onCrystal2Changed,
  });

  final String armorMode;
  final ValueChanged<String> onArmorModeChanged;
  final String? selectedId;
  final EquipmentLibraryItem? selectedEquipmentItem;
  final List<EquipmentLibraryItem> searchCandidates;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ArmorModeSelector(value: armorMode, onChanged: onArmorModeChanged),
        const SizedBox(height: 10),
        EquipmentSlotSelector(
          idLabel: 'Armor',
          idHint: 'Search armor name...',
          selectedId: selectedId,
          selectedEquipmentItem: selectedEquipmentItem,
          enableInlineNameSearch: true,
          inlineSearchByNameOnly: true,
          inlineSearchCandidates: searchCandidates,
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
        ),
      ],
    );
  }
}

class _ArmorModeSelector extends StatelessWidget {
  const _ArmorModeSelector({required this.value, required this.onChanged});

  static const List<MapEntry<String, String>> _modeOptions =
      <MapEntry<String, String>>[
        MapEntry<String, String>('normal', 'Normal'),
        MapEntry<String, String>('heavy', 'Heavy'),
        MapEntry<String, String>('light', 'Light'),
      ];

  final String value;
  final ValueChanged<String> onChanged;

  String _normalize(String mode) {
    final String normalized = mode.trim().toLowerCase();
    switch (normalized) {
      case 'heavy':
      case 'light':
      case 'normal':
        return normalized;
      default:
        return 'normal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String active = _normalize(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Armor Mode',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _modeOptions
              .map((MapEntry<String, String> option) {
                final bool isSelected = active == option.key;
                return ChoiceChip(
                  label: Text(option.value),
                  selected: isSelected,
                  showCheckmark: true,
                  selectedColor: colorScheme.primaryContainer,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  side: BorderSide(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.34),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  onSelected: (_) => onChanged(option.key),
                );
              })
              .toList(growable: false),
        ),
        const SizedBox(height: 4),
        Text(
          'Empty armor slot uses the in-game no-armor formula automatically.',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.58),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
