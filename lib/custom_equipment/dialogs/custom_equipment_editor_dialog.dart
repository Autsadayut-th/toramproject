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
  static const List<String> _categories = <String>['weapon', 'armor'];
  static const Map<String, List<String>> _statKeyOptionsByCategory =
      <String, List<String>>{
        'weapon': <String>[
          'weapon_atk',
          'atk',
          'matk',
          'critical_rate',
          'physical_pierce',
          'magic_pierce',
          'stability',
          'accuracy',
          'aspd',
          'cspd',
          'str',
          'dex',
          'int',
          'agi',
          'vit',
          'maxhp',
          'maxmp',
        ],
        'armor': <String>[
          'def',
          'mdef',
          'maxhp',
          'maxmp',
          'critical_rate',
          'physical_pierce',
          'magic_pierce',
          'stability',
          'accuracy',
          'flee',
          'aspd',
          'cspd',
          'str',
          'dex',
          'int',
          'agi',
          'vit',
        ],
      };
  static const Map<String, List<String>> _equipmentTypeOptionsByCategory =
      <String, List<String>>{
        'weapon': <String>[
          '1H_SWORD',
          '2H_SWORD',
          'BOW',
          'BOWGUN',
          'STAFF',
          'MAGIC_DEVICE',
          'KNUCKLES',
          'HALBERD',
          'KATANA',
          'DUAL_SWORD',
        ],
        'armor': <String>['ARMOR'],
      };

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late String _category;
  late String _equipmentType;
  late List<_CustomStatDraft> _statDrafts;

  @override
  void initState() {
    super.initState();
    final CustomEquipmentItem? initial = widget.initialItem;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _notesController = TextEditingController(text: initial?.notes ?? '');
    final String preferredCategory = _isCategoryLockedByTrigger
        ? _triggerCategory
        : initial?.category ?? widget.initialCategory ?? _categories.first;
    _category = CustomEquipmentMapper.normalizedCategory(preferredCategory);
    _equipmentType = _normalizedEquipmentType(
      rawType: initial?.type ?? '',
      category: _category,
    );
    _statDrafts = _buildInitialStatDrafts(initial?.stats);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    for (final _CustomStatDraft draft in _statDrafts) {
      draft.valueController.dispose();
    }
    super.dispose();
  }

  List<_CustomStatDraft> _buildInitialStatDrafts(
    List<CustomEquipmentStat>? initialStats,
  ) {
    final List<CustomEquipmentStat> stats =
        (initialStats ?? const <CustomEquipmentStat>[])
            .where((CustomEquipmentStat stat) => stat.isValid)
            .toList(growable: false);
    if (stats.isEmpty) {
      return <_CustomStatDraft>[
        _CustomStatDraft(
          statKey: _normalizedStatKey(rawStatKey: '', category: _category),
          valueController: TextEditingController(text: '0'),
          valueType: 'flat',
        ),
      ];
    }

    return stats
        .map((CustomEquipmentStat fromStat) {
          return _CustomStatDraft(
            statKey: _normalizedStatKey(
              rawStatKey: fromStat.statKey,
              category: _category,
            ),
            valueController: TextEditingController(
              text: fromStat.value.toString(),
            ),
            valueType: fromStat.valueType.isEmpty ? 'flat' : fromStat.valueType,
          );
        })
        .toList(growable: true);
  }

  void _addStatDraft() {
    setState(() {
      _statDrafts.add(
        _CustomStatDraft(
          statKey: _normalizedStatKey(rawStatKey: '', category: _category),
          valueController: TextEditingController(text: '0'),
          valueType: 'flat',
        ),
      );
    });
  }

  void _removeStatDraft(int index) {
    if (_statDrafts.length <= 1 || index < 0 || index >= _statDrafts.length) {
      return;
    }
    final _CustomStatDraft draft = _statDrafts.removeAt(index);
    draft.valueController.dispose();
    setState(() {});
  }

  bool get _isCategoryLockedByTrigger {
    final String raw = widget.initialCategory?.trim() ?? '';
    if (raw.isEmpty) {
      return false;
    }
    return _categories.contains(CustomEquipmentMapper.normalizedCategory(raw));
  }

  String get _triggerCategory {
    return CustomEquipmentMapper.normalizedCategory(
      widget.initialCategory ?? _categories.first,
    );
  }

  List<String> _statKeyOptionsForCategory(String category) {
    return _statKeyOptionsByCategory[category] ??
        _statKeyOptionsByCategory[_categories.first] ??
        const <String>['weapon_atk'];
  }

  List<String> _equipmentTypeOptionsForCategory(String category) {
    return _equipmentTypeOptionsByCategory[category] ??
        _equipmentTypeOptionsByCategory[_categories.first] ??
        const <String>['1H_SWORD'];
  }

  String _normalizedEquipmentType({
    required String rawType,
    required String category,
  }) {
    final List<String> options = _equipmentTypeOptionsForCategory(category);
    final String normalized = rawType.trim().toUpperCase();
    if (options.contains(normalized)) {
      return normalized;
    }
    return options.first;
  }

  String _normalizedStatKey({
    required String rawStatKey,
    required String category,
  }) {
    final List<String> options = _statKeyOptionsForCategory(category);
    final String normalized = rawStatKey.trim().toLowerCase();
    if (options.contains(normalized)) {
      return normalized;
    }
    return options.first;
  }

  String _statKeyLabel(String key) {
    final String normalized = key.trim().toLowerCase();
    switch (normalized) {
      case 'weapon_atk':
        return 'Weapon ATK';
      case 'atk':
        return 'ATK';
      case 'matk':
        return 'MATK';
      case 'def':
        return 'DEF';
      case 'mdef':
        return 'MDEF';
      case 'critical_rate':
        return 'Critical Rate';
      case 'physical_pierce':
        return 'Physical Pierce';
      case 'magic_pierce':
        return 'Magic Pierce';
      case 'maxhp':
        return 'MaxHP';
      case 'maxmp':
        return 'MaxMP';
      default:
        return normalized.toUpperCase();
    }
  }

  String _equipmentTypeLabel(String value) {
    final String text = value.trim();
    if (text.isEmpty) {
      return '-';
    }
    return text.replaceAll('_', ' ');
  }

  void _submit() {
    final FormState? state = _formKey.currentState;
    if (state == null || !state.validate()) {
      return;
    }

    final DateTime now = DateTime.now();
    final String name = _nameController.text.trim();
    final String key = _buildKey(name, _category);
    final List<CustomEquipmentStat> stats = _statDrafts
        .map((_CustomStatDraft draft) {
          return CustomEquipmentStat(
            statKey: draft.statKey,
            value: num.tryParse(draft.valueController.text.trim()) ?? 0,
            valueType: draft.valueType,
          );
        })
        .toList(growable: false);
    final CustomEquipmentItem item =
        (widget.initialItem ??
                CustomEquipmentItem(
                  id: 'custom_${now.microsecondsSinceEpoch}',
                  key: key,
                  name: name,
                  category: _category,
                  type: _equipmentType,
                  stats: const <CustomEquipmentStat>[],
                  createdAt: now,
                  updatedAt: now,
                ))
            .copyWith(
              key: key,
              name: name,
              category: _category,
              type: _equipmentType,
              stats: stats,
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
      title: Text(
        widget.initialItem == null ? 'Create Custom Item' : 'Edit Custom Item',
      ),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (_isCategoryLockedByTrigger)
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Category'),
                    child: Text(_category),
                  )
                else
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
                        _equipmentType = _normalizedEquipmentType(
                          rawType: _equipmentType,
                          category: _category,
                        );
                        for (final _CustomStatDraft draft in _statDrafts) {
                          draft.statKey = _normalizedStatKey(
                            rawStatKey: draft.statKey,
                            category: _category,
                          );
                        }
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
                DropdownButtonFormField<String>(
                  initialValue: _equipmentType,
                  decoration: const InputDecoration(
                    labelText: 'Equipment Type Preset',
                  ),
                  items: _equipmentTypeOptionsForCategory(_category)
                      .map(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(_equipmentTypeLabel(value)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (String? value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _equipmentType = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                ...List<Widget>.generate(_statDrafts.length, (int index) {
                  final _CustomStatDraft draft = _statDrafts[index];
                  final String statLabel = index == 0
                      ? 'Primary Stat Key'
                      : 'Stat Key ${index + 1}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: draft.statKey,
                                decoration: InputDecoration(
                                  labelText: statLabel,
                                  border: const OutlineInputBorder(),
                                ),
                                items: _statKeyOptionsForCategory(_category)
                                    .map(
                                      (String key) => DropdownMenuItem<String>(
                                        value: key,
                                        child: Text(
                                          '${_statKeyLabel(key)} ($key)',
                                        ),
                                      ),
                                    )
                                    .toList(growable: false),
                                onChanged: (String? value) {
                                  if (value == null) {
                                    return;
                                  }
                                  setState(() {
                                    draft.statKey = value;
                                  });
                                },
                              ),
                            ),
                            if (_statDrafts.length > 1) ...<Widget>[
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => _removeStatDraft(index),
                                tooltip: 'Remove stat',
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: draft.valueController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Stat Value',
                            border: OutlineInputBorder(),
                          ),
                          validator: (String? value) {
                            return num.tryParse(value?.trim() ?? '') != null
                                ? null
                                : 'Please enter a number.';
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: draft.valueType,
                          decoration: const InputDecoration(
                            labelText: 'Stat Value Type',
                          ),
                          items: const <DropdownMenuItem<String>>[
                            DropdownMenuItem<String>(
                              value: 'flat',
                              child: Text('flat'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'percent',
                              child: Text('percent'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'base',
                              child: Text('base'),
                            ),
                          ],
                          onChanged: (String? value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              draft.valueType = value;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addStatDraft,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Stat'),
                  ),
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

class _CustomStatDraft {
  _CustomStatDraft({
    required this.statKey,
    required this.valueController,
    required this.valueType,
  });

  String statKey;
  TextEditingController valueController;
  String valueType;
}
