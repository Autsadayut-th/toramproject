import 'package:flutter/material.dart';

import '../models/custom_equipment_item.dart';
import '../models/custom_equipment_stat.dart';
import '../services/custom_equipment_mapper.dart';

class CustomEquipmentEditorDialog extends StatefulWidget {
  const CustomEquipmentEditorDialog({
    super.key,
    this.initialItem,
    this.initialCategory,
  });

  final CustomEquipmentItem? initialItem;
  final String? initialCategory;

  @override
  State<CustomEquipmentEditorDialog> createState() =>
      _CustomEquipmentEditorDialogState();
}

class _CustomEquipmentEditorDialogState
    extends State<CustomEquipmentEditorDialog> {
  static const List<String> _categories = <String>[
    'weapon',
    'armor',
    'additional',
    'special',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _notesController;
  late final TextEditingController _statKeyController;
  late final TextEditingController _statValueController;
  late String _category;
  late String _valueType;

  @override
  void initState() {
    super.initState();
    final CustomEquipmentItem? initial = widget.initialItem;
    final CustomEquipmentStat? firstStat =
        initial != null && initial.stats.isNotEmpty ? initial.stats.first : null;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _typeController = TextEditingController(text: initial?.type ?? '');
    _notesController = TextEditingController(text: initial?.notes ?? '');
    _statKeyController = TextEditingController(
      text: firstStat?.statKey ?? 'weapon_atk',
    );
    _statValueController = TextEditingController(
      text: firstStat?.value.toString() ?? '0',
    );
    _category = CustomEquipmentMapper.normalizedCategory(
      initial?.category ?? widget.initialCategory ?? _categories.first,
    );
    _valueType = firstStat?.valueType ?? 'flat';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _notesController.dispose();
    _statKeyController.dispose();
    _statValueController.dispose();
    super.dispose();
  }

  void _submit() {
    final FormState? state = _formKey.currentState;
    if (state == null || !state.validate()) {
      return;
    }

    final DateTime now = DateTime.now();
    final String name = _nameController.text.trim();
    final String key = _buildKey(name, _category);
    final CustomEquipmentItem item =
        (widget.initialItem ??
                CustomEquipmentItem(
                  id: 'custom_${now.microsecondsSinceEpoch}',
                  key: key,
                  name: name,
                  category: _category,
                  type: _typeController.text.trim(),
                  stats: const <CustomEquipmentStat>[],
                  createdAt: now,
                  updatedAt: now,
                ))
            .copyWith(
              key: key,
              name: name,
              category: _category,
              type: _typeController.text.trim(),
              stats: <CustomEquipmentStat>[
                CustomEquipmentStat(
                  statKey: _statKeyController.text.trim(),
                  value: num.tryParse(_statValueController.text.trim()) ?? 0,
                  valueType: _valueType,
                ),
              ],
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
              updatedAt: now,
            );

    Navigator.of(context).pop(item);
  }

  String _buildKey(String name, String category) {
    final String normalizedName = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return 'custom_${category}_$normalizedName';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialItem == null ? 'Create Custom Item' : 'Edit Custom Item'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .map(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (String? value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _category = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  validator: (String? value) {
                    return (value?.trim().isNotEmpty ?? false)
                        ? null
                        : 'Please enter an item name.';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _typeController,
                  decoration: const InputDecoration(labelText: 'Equipment Type'),
                  validator: (String? value) {
                    return (value?.trim().isNotEmpty ?? false)
                        ? null
                        : 'Please enter an equipment type.';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _statKeyController,
                  decoration: const InputDecoration(labelText: 'Primary Stat Key'),
                  validator: (String? value) {
                    return (value?.trim().isNotEmpty ?? false)
                        ? null
                        : 'Please enter a stat key.';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _statValueController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Primary Stat Value'),
                  validator: (String? value) {
                    return num.tryParse(value?.trim() ?? '') != null
                        ? null
                        : 'Please enter a number.';
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _valueType,
                  decoration: const InputDecoration(labelText: 'Stat Value Type'),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(value: 'flat', child: Text('flat')),
                    DropdownMenuItem<String>(
                      value: 'percent',
                      child: Text('percent'),
                    ),
                    DropdownMenuItem<String>(value: 'base', child: Text('base')),
                  ],
                  onChanged: (String? value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _valueType = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional description or reminder',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.initialItem == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}
