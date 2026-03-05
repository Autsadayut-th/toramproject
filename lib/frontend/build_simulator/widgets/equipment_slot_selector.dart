import 'package:flutter/material.dart';

import '../../equipment_library/equipment_library_page.dart';
import '../services/crystal_library_service.dart';

class EquipmentSlotSelector extends StatefulWidget {
  const EquipmentSlotSelector({
    super.key,
    required this.idLabel,
    required this.idHint,
    required this.selectedId,
    required this.onEquipChanged,
    required this.pickInitialCategory,
    required this.allowedCategories,
    required this.pickTitle,
    required this.statsLabel,
    required this.statPreview,
    required this.enhance,
    required this.onEnhChanged,
    this.allowedItemTypes,
    this.selectedDisplayText,
    this.idFieldReadOnly = false,
    this.crystalCategoryFilters = const <String>[],
    this.crystal1,
    this.crystal2,
    this.onCrystal1Changed,
    this.onCrystal2Changed,
  });

  final String idLabel;
  final String idHint;
  final String? selectedId;
  final ValueChanged<String?> onEquipChanged;
  final String pickInitialCategory;
  final List<String> allowedCategories;
  final String pickTitle;
  final String statsLabel;
  final List<String> statPreview;
  final int enhance;
  final ValueChanged<int> onEnhChanged;
  final List<String>? allowedItemTypes;
  final String? selectedDisplayText;
  final bool idFieldReadOnly;
  final List<String> crystalCategoryFilters;
  final String? crystal1;
  final String? crystal2;
  final ValueChanged<String?>? onCrystal1Changed;
  final ValueChanged<String?>? onCrystal2Changed;

  @override
  State<EquipmentSlotSelector> createState() => _EquipmentSlotSelectorState();
}

class _EquipmentSlotSelectorState extends State<EquipmentSlotSelector> {
  static const int _minEnhance = 0;
  static const int _maxEnhance = 15;

  late final TextEditingController _idController;
  List<CrystalLibraryEntry> _availableCrystals = const <CrystalLibraryEntry>[];
  Map<String, CrystalLibraryEntry> _crystalByKey =
      const <String, CrystalLibraryEntry>{};
  bool _isCrystalLoading = false;
  int _crystalLoadToken = 0;

  bool get _showCrystalSlots =>
      widget.onCrystal1Changed != null && widget.onCrystal2Changed != null;
  bool get _canBrowseCrystals =>
      _showCrystalSlots && widget.crystalCategoryFilters.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: _idFieldText());
    _refreshCrystalLibrary(force: true);
  }

  @override
  void didUpdateWidget(covariant EquipmentSlotSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId ||
        oldWidget.selectedDisplayText != widget.selectedDisplayText ||
        oldWidget.idFieldReadOnly != widget.idFieldReadOnly) {
      _idController.text = _idFieldText();
    }
    if (!_isSameStringList(
      oldWidget.crystalCategoryFilters,
      widget.crystalCategoryFilters,
    )) {
      _refreshCrystalLibrary(force: true);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _commitId() {
    if (widget.idFieldReadOnly) {
      return;
    }
    final String value = _idController.text.trim();
    widget.onEquipChanged(value.isEmpty ? null : value);
  }

  Future<void> _pickFromLibrary() async {
    final String? selectedKey = await EquipmentLibraryScreen.pickItemKey(
      context,
      initialCategory: widget.pickInitialCategory,
      allowedCategories: widget.allowedCategories,
      allowedTypes: widget.allowedItemTypes,
      title: widget.pickTitle,
    );
    if (!mounted || selectedKey == null || selectedKey.isEmpty) {
      return;
    }
    widget.onEquipChanged(selectedKey);
  }

  String _idFieldText() {
    if (widget.idFieldReadOnly) {
      final String display = widget.selectedDisplayText?.trim() ?? '';
      if (display.isNotEmpty) {
        return display;
      }
    }
    return widget.selectedId ?? '';
  }

  Future<void> _refreshCrystalLibrary({bool force = false}) async {
    if (!_canBrowseCrystals) {
      if (force && mounted) {
        setState(() {
          _availableCrystals = const <CrystalLibraryEntry>[];
          _crystalByKey = const <String, CrystalLibraryEntry>{};
          _isCrystalLoading = false;
        });
      }
      return;
    }

    if (!force && _availableCrystals.isNotEmpty) {
      return;
    }

    final int token = ++_crystalLoadToken;
    if (mounted) {
      setState(() {
        _isCrystalLoading = true;
      });
    }

    try {
      final List<CrystalLibraryEntry> entries =
          await CrystalLibraryService.loadByCategories(
            widget.crystalCategoryFilters,
          );
      if (!mounted || token != _crystalLoadToken) {
        return;
      }
      setState(() {
        _availableCrystals = entries;
        _crystalByKey = <String, CrystalLibraryEntry>{
          for (final CrystalLibraryEntry entry in entries)
            entry.normalizedKey: entry,
        };
        _isCrystalLoading = false;
      });
    } catch (_) {
      if (!mounted || token != _crystalLoadToken) {
        return;
      }
      setState(() {
        _availableCrystals = const <CrystalLibraryEntry>[];
        _crystalByKey = const <String, CrystalLibraryEntry>{};
        _isCrystalLoading = false;
      });
    }
  }

  bool _isSameStringList(List<String> a, List<String> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }

  String _displayCrystalName(String? crystalKey) {
    final String rawKey = crystalKey?.trim() ?? '';
    if (rawKey.isEmpty) {
      return '';
    }
    final String normalized = rawKey.toLowerCase();
    return _crystalByKey[normalized]?.name ?? rawKey;
  }

  Future<void> _pickCrystalSlot1() async {
    if (widget.onCrystal1Changed == null) {
      return;
    }
    final CrystalLibraryEntry? selected = await _openCrystalPicker(
      title: 'Select Crystal Slot 1',
      selectedKey: widget.crystal1,
    );
    if (!mounted || selected == null) {
      return;
    }
    widget.onCrystal1Changed!(selected.key);
  }

  Future<void> _pickCrystalSlot2() async {
    if (widget.onCrystal2Changed == null) {
      return;
    }
    final CrystalLibraryEntry? selected = await _openCrystalPicker(
      title: 'Select Crystal Slot 2',
      selectedKey: widget.crystal2,
    );
    if (!mounted || selected == null) {
      return;
    }
    widget.onCrystal2Changed!(selected.key);
  }

  Future<CrystalLibraryEntry?> _openCrystalPicker({
    required String title,
    required String? selectedKey,
  }) async {
    await _refreshCrystalLibrary();
    if (!mounted || _availableCrystals.isEmpty) {
      return null;
    }
    return showDialog<CrystalLibraryEntry>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _CrystalPickerDialog(
          title: title,
          entries: _availableCrystals,
          selectedKey: selectedKey,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _label(widget.idLabel),
        Row(
          children: <Widget>[
            Expanded(
              child: _inputField(
                controller: _idController,
                hint: widget.idHint,
                onSubmitted: _commitId,
                onTapOutside: _commitId,
                readOnly: widget.idFieldReadOnly,
              ),
            ),
            const SizedBox(width: 8),
            _libraryButton(
              onTap: _pickFromLibrary,
              enabled: true,
              tooltip: 'Browse library',
            ),
          ],
        ),
        const SizedBox(height: 10),
        if ((widget.selectedId ?? '').trim().isNotEmpty) ...<Widget>[
          _label(widget.statsLabel),
          if (widget.statPreview.isEmpty)
            Text(
              'No stats data',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.statPreview
                  .map(
                    (String stat) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151515),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        stat,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          const SizedBox(height: 10),
        ],
        Row(
          children: <Widget>[
            const Text(
              'Enhance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '+${widget.enhance}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Slider(
          value: widget.enhance.clamp(_minEnhance, _maxEnhance).toDouble(),
          min: _minEnhance.toDouble(),
          max: _maxEnhance.toDouble(),
          divisions: _maxEnhance - _minEnhance,
          label: '+${widget.enhance}',
          activeColor: Colors.white,
          inactiveColor: Colors.white24,
          onChanged: (double value) {
            widget.onEnhChanged(value.round().clamp(_minEnhance, _maxEnhance));
          },
        ),
        if (_showCrystalSlots) ...<Widget>[
          const SizedBox(height: 10),
          _label('Crystal Slot 1'),
          _crystalSelectionField(
            selectedKey: widget.crystal1,
            onBrowse: _pickCrystalSlot1,
            onClear: widget.onCrystal1Changed == null
                ? null
                : () => widget.onCrystal1Changed!(null),
          ),
          const SizedBox(height: 10),
          _label('Crystal Slot 2'),
          _crystalSelectionField(
            selectedKey: widget.crystal2,
            onBrowse: _pickCrystalSlot2,
            onClear: widget.onCrystal2Changed == null
                ? null
                : () => widget.onCrystal2Changed!(null),
          ),
        ],
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onSubmitted,
    required VoidCallback onTapOutside,
    bool readOnly = false,
    TextAlign textAlign = TextAlign.left,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      textAlign: textAlign,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        filled: true,
        fillColor: const Color(0xFF111111),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.32)),
        ),
      ),
      onSubmitted: (_) => onSubmitted(),
      onTapOutside: (_) => onTapOutside(),
    );
  }

  Widget _crystalSelectionField({
    required String? selectedKey,
    required VoidCallback onBrowse,
    required VoidCallback? onClear,
  }) {
    final String displayName = _displayCrystalName(selectedKey);
    final String rawKey = selectedKey?.trim() ?? '';
    final bool hasValue = rawKey.isNotEmpty;
    final bool canBrowse = _canBrowseCrystals && !_isCrystalLoading;

    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: hasValue
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (displayName.toLowerCase() != rawKey.toLowerCase())
                        Text(
                          rawKey,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  )
                : Text(
                    _isCrystalLoading ? 'Loading crystal data...' : 'Select crystal',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        _libraryButton(
          onTap: onBrowse,
          enabled: canBrowse,
          tooltip: _isCrystalLoading ? 'Loading crystals...' : 'Browse crystals',
        ),
        if (hasValue) ...<Widget>[
          const SizedBox(width: 8),
          _clearButton(onTap: onClear),
        ],
      ],
    );
  }

  Widget _libraryButton({
    required VoidCallback onTap,
    required bool enabled,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: enabled ? 0.22 : 0.10),
            ),
          ),
          child: Icon(
            Icons.menu_book_outlined,
            size: 18,
            color: enabled
                ? Colors.white
                : Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }

  Widget _clearButton({required VoidCallback? onTap}) {
    return Tooltip(
      message: 'Clear crystal',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: const Icon(
            Icons.close,
            size: 16,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _CrystalPickerDialog extends StatefulWidget {
  const _CrystalPickerDialog({
    required this.title,
    required this.entries,
    required this.selectedKey,
  });

  final String title;
  final List<CrystalLibraryEntry> entries;
  final String? selectedKey;

  @override
  State<_CrystalPickerDialog> createState() => _CrystalPickerDialogState();
}

class _CrystalPickerDialogState extends State<_CrystalPickerDialog> {
  String _query = '';
  String? _categoryFilter;

  List<String> get _categories {
    final Set<String> values = widget.entries
        .map((CrystalLibraryEntry entry) => entry.category.trim().toLowerCase())
        .where((String value) => value.isNotEmpty)
        .toSet();
    final List<String> categories = values.toList(growable: false)..sort();
    return categories;
  }

  List<CrystalLibraryEntry> get _filteredEntries {
    final String normalizedQuery = _query.trim().toLowerCase();
    return widget.entries.where((CrystalLibraryEntry entry) {
      if (_categoryFilter != null && entry.category != _categoryFilter) {
        return false;
      }
      if (normalizedQuery.isEmpty) {
        return true;
      }
      return entry.name.toLowerCase().contains(normalizedQuery) ||
          entry.key.toLowerCase().contains(normalizedQuery);
    }).toList(growable: false);
  }

  String _categoryLabel(String category) {
    if (category.isEmpty) {
      return '-';
    }
    return category[0].toUpperCase() + category.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final String selectedKey = widget.selectedKey?.trim().toLowerCase() ?? '';
    final List<String> categories = _categories;
    final List<CrystalLibraryEntry> filtered = _filteredEntries;

    return Dialog(
      backgroundColor: const Color(0xFF101010),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 620),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white70),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white70,
                  decoration: InputDecoration(
                    hintText: 'Search crystal name or key...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFF0F0F0F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0x33FFFFFF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0x33FFFFFF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0x66FFFFFF)),
                    ),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _query = value;
                    });
                  },
                ),
                if (categories.length > 1) ...<Widget>[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _categoryFilter == null,
                        onSelected: (_) {
                          setState(() {
                            _categoryFilter = null;
                          });
                        },
                      ),
                      ...categories.map((String category) {
                        return ChoiceChip(
                          label: Text(_categoryLabel(category)),
                          selected: _categoryFilter == category,
                          onSelected: (_) {
                            setState(() {
                              _categoryFilter = category;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No crystal found.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: Color(0x22FFFFFF)),
                          itemBuilder: (BuildContext context, int index) {
                            final CrystalLibraryEntry entry = filtered[index];
                            final bool isSelected =
                                entry.normalizedKey == selectedKey;
                            return ListTile(
                              dense: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              selected: isSelected,
                              selectedTileColor: const Color(0x2221A366),
                              title: Text(
                                entry.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                '${entry.key} - ${_categoryLabel(entry.category)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.greenAccent,
                                      size: 18,
                                    )
                                  : null,
                              onTap: () => Navigator.of(context).pop(entry),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
