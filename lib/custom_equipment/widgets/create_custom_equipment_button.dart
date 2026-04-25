import 'package:flutter/material.dart';

import '../dialogs/custom_equipment_editor_dialog.dart';
import '../models/custom_equipment_item.dart';

class CreateCustomEquipmentButton extends StatelessWidget {
  const CreateCustomEquipmentButton({
    super.key,
    required this.onCreated,
    this.initialCategory,
    this.label = 'Create Custom Item',
  });

  final ValueChanged<CustomEquipmentItem> onCreated;
  final String? initialCategory;
  final String label;

  Future<void> _openDialog(BuildContext context) async {
    final CustomEquipmentItem? item =
        await showDialog<CustomEquipmentItem>(
          context: context,
          builder: (BuildContext context) {
            return CustomEquipmentEditorDialog(
              initialCategory: initialCategory,
            );
          },
        );
    if (item == null) {
      return;
    }
    onCreated(item);
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _openDialog(context),
      icon: const Icon(Icons.add),
      label: Text(label),
    );
  }
}
