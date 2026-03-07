import 'package:flutter/material.dart';

import '../../equipment_library/equipment_library_page.dart';
import '../../equipment_library/models/equipment_library_item.dart';
import '../../equipment_library/services/equipment_library_query_service.dart';
import '../services/crystal_library_service.dart';

const Map<String, Color> _crystalAccentColors = <String, Color>{
  'red': Color(0xFFE57373),
  'green': Color(0xFF81C784),
  'blue': Color(0xFF64B5F6),
  'yellow': Color(0xFFFFD54F),
  'purple': Color(0xFFBA68C8),
};

Color _crystalAccentColor(CrystalLibraryEntry? entry) {
  final String colorKey = entry?.colorKey ?? 'blue';
  return _crystalAccentColors[colorKey] ?? const Color(0xFF64B5F6);
}

String _crystalIconPath(CrystalLibraryEntry? entry) {
  return entry?.iconAssetPath ?? 'assets/data/icon/blue_crysta.png';
}

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
    this.selectedEquipmentItem,
    this.idFieldReadOnly = false,
    this.forceTextInput = false,
    this.enableInlineNameSearch = false,
    this.inlineSearchByNameOnly = false,
    this.inlineSearchCandidates = const <EquipmentLibraryItem>[],
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
  final EquipmentLibraryItem? selectedEquipmentItem;
  final bool idFieldReadOnly;
  final bool forceTextInput;
  final bool enableInlineNameSearch;
  final bool inlineSearchByNameOnly;
  final List<EquipmentLibraryItem> inlineSearchCandidates;
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
  late final FocusNode _idFocusNode;
  late final TextEditingController _crystal1Controller;
  late final TextEditingController _crystal2Controller;
  late final FocusNode _crystal1FocusNode;
  late final FocusNode _crystal2FocusNode;
  List<CrystalLibraryEntry> _availableCrystals = const <CrystalLibraryEntry>[];
  Map<String, CrystalLibraryEntry> _crystalByKey =
      const <String, CrystalLibraryEntry>{};
  bool _isCrystalLoading = false;
  int _crystalLoadToken = 0;
  bool _isInlineEditing = false;
  bool _isCrystal1InlineEditing = false;
  bool _isCrystal2InlineEditing = false;

  bool get _showCrystalSlots =>
      widget.onCrystal1Changed != null && widget.onCrystal2Changed != null;
  bool get _canBrowseCrystals =>
      _showCrystalSlots && widget.crystalCategoryFilters.isNotEmpty;
  bool get _canInlineNameSearch =>
      widget.enableInlineNameSearch &&
      widget.inlineSearchCandidates.isNotEmpty &&
      !widget.idFieldReadOnly;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: _idFieldText());
    _idFocusNode = FocusNode();
    _crystal1Controller = TextEditingController();
    _crystal2Controller = TextEditingController();
    _crystal1FocusNode = FocusNode();
    _crystal2FocusNode = FocusNode();
    _crystal1FocusNode.addListener(_onCrystalFocusChanged);
    _crystal2FocusNode.addListener(_onCrystalFocusChanged);
    _syncCrystalInputText();
    _refreshCrystalLibrary(force: true);
  }

  @override
  void didUpdateWidget(covariant EquipmentSlotSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId ||
        oldWidget.selectedDisplayText != widget.selectedDisplayText ||
        oldWidget.selectedEquipmentItem?.key !=
            widget.selectedEquipmentItem?.key ||
        oldWidget.idFieldReadOnly != widget.idFieldReadOnly ||
        oldWidget.forceTextInput != widget.forceTextInput ||
        oldWidget.enableInlineNameSearch != widget.enableInlineNameSearch ||
        oldWidget.inlineSearchByNameOnly != widget.inlineSearchByNameOnly) {
      _idController.text = _idFieldText();
      if (oldWidget.selectedId != widget.selectedId) {
        _isInlineEditing = false;
      }
    }
    if (!_isSameStringList(
      oldWidget.crystalCategoryFilters,
      widget.crystalCategoryFilters,
    )) {
      _refreshCrystalLibrary(force: true);
    }
    if (oldWidget.crystal1 != widget.crystal1) {
      _isCrystal1InlineEditing = false;
    }
    if (oldWidget.crystal2 != widget.crystal2) {
      _isCrystal2InlineEditing = false;
    }
    _syncCrystalInputText();
  }

  @override
  void dispose() {
    _idController.dispose();
    _idFocusNode.dispose();
    _crystal1FocusNode.removeListener(_onCrystalFocusChanged);
    _crystal2FocusNode.removeListener(_onCrystalFocusChanged);
    _crystal1Controller.dispose();
    _crystal2Controller.dispose();
    _crystal1FocusNode.dispose();
    _crystal2FocusNode.dispose();
    super.dispose();
  }

  void _onCrystalFocusChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _commitId() {
    if (widget.idFieldReadOnly) {
      return;
    }
    final String value = _idController.text.trim();
    final EquipmentLibraryItem? matched = _matchInlineCandidate(value);
    if (matched != null) {
      widget.onEquipChanged(matched.key);
      _idFocusNode.unfocus();
      if (_isInlineEditing) {
        setState(() {
          _isInlineEditing = false;
        });
      }
      return;
    }
    if (_canInlineNameSearch && widget.inlineSearchByNameOnly) {
      return;
    }
    widget.onEquipChanged(value.isEmpty ? null : value);
  }

  void _startInlineEditing() {
    if (!_canInlineNameSearch || widget.selectedEquipmentItem == null) {
      return;
    }
    setState(() {
      _isInlineEditing = true;
      _idController.text = widget.selectedEquipmentItem!.name;
      _idController.selection = TextSelection.fromPosition(
        TextPosition(offset: _idController.text.length),
      );
    });
    _idFocusNode.requestFocus();
  }

  EquipmentLibraryItem? _matchInlineCandidate(String raw) {
    final String normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty || !_canInlineNameSearch) {
      return null;
    }
    EquipmentLibraryItem? fuzzyMatch;
    for (final EquipmentLibraryItem item in widget.inlineSearchCandidates) {
      final String name = item.name.trim().toLowerCase();
      final String key = item.key.trim().toLowerCase();
      if (name == normalized ||
          (!widget.inlineSearchByNameOnly && key == normalized)) {
        return item;
      }
      if (fuzzyMatch == null &&
          (name.contains(normalized) ||
              (!widget.inlineSearchByNameOnly && key.contains(normalized)))) {
        fuzzyMatch = item;
      }
    }
    return fuzzyMatch;
  }

  List<EquipmentLibraryItem> _inlineCandidates() {
    if (!_canInlineNameSearch || !_idFocusNode.hasFocus) {
      return const <EquipmentLibraryItem>[];
    }
    final String query = _idController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return const <EquipmentLibraryItem>[];
    }

    final List<EquipmentLibraryItem> matches = <EquipmentLibraryItem>[];
    for (final EquipmentLibraryItem item in widget.inlineSearchCandidates) {
      final String name = item.name.trim().toLowerCase();
      final String key = item.key.trim().toLowerCase();
      if (!name.contains(query) &&
          (!key.contains(query) || widget.inlineSearchByNameOnly)) {
        continue;
      }
      matches.add(item);
      if (matches.length >= 8) {
        break;
      }
    }
    return matches;
  }

  void _selectInlineCandidate(EquipmentLibraryItem item) {
    widget.onEquipChanged(item.key);
    _idFocusNode.unfocus();
    if (_isInlineEditing) {
      setState(() {
        _isInlineEditing = false;
      });
    }
  }

  void _onIdTapOutside() {
    if (_canInlineNameSearch) {
      _idFocusNode.unfocus();
      return;
    }
    _commitId();
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
        _syncCrystalInputText();
      });
    } catch (_) {
      if (!mounted || token != _crystalLoadToken) {
        return;
      }
      setState(() {
        _availableCrystals = const <CrystalLibraryEntry>[];
        _crystalByKey = const <String, CrystalLibraryEntry>{};
        _isCrystalLoading = false;
        _syncCrystalInputText();
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

  TextEditingController _crystalController(bool isSlot1) {
    return isSlot1 ? _crystal1Controller : _crystal2Controller;
  }

  FocusNode _crystalFocusNode(bool isSlot1) {
    return isSlot1 ? _crystal1FocusNode : _crystal2FocusNode;
  }

  bool _isCrystalInlineEditing(bool isSlot1) {
    return isSlot1 ? _isCrystal1InlineEditing : _isCrystal2InlineEditing;
  }

  String? _selectedCrystalKey(bool isSlot1) {
    return isSlot1 ? widget.crystal1 : widget.crystal2;
  }

  void _setCrystalInlineEditing(bool isSlot1, bool value) {
    if (isSlot1) {
      _isCrystal1InlineEditing = value;
      return;
    }
    _isCrystal2InlineEditing = value;
  }

  void _syncCrystalInputText() {
    if (!_isCrystal1InlineEditing) {
      final String next = _displayCrystalName(widget.crystal1);
      if (_crystal1Controller.text != next) {
        _crystal1Controller.text = next;
      }
    }
    if (!_isCrystal2InlineEditing) {
      final String next = _displayCrystalName(widget.crystal2);
      if (_crystal2Controller.text != next) {
        _crystal2Controller.text = next;
      }
    }
  }

  CrystalLibraryEntry? _matchCrystalByName(String raw) {
    final String normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty || _availableCrystals.isEmpty) {
      return null;
    }

    CrystalLibraryEntry? fuzzyMatch;
    for (final CrystalLibraryEntry entry in _availableCrystals) {
      final String name = entry.name.trim().toLowerCase();
      if (name == normalized) {
        return entry;
      }
      if (fuzzyMatch == null && name.contains(normalized)) {
        fuzzyMatch = entry;
      }
    }
    return fuzzyMatch;
  }

  List<CrystalLibraryEntry> _crystalInlineCandidates({required bool isSlot1}) {
    final FocusNode focusNode = _crystalFocusNode(isSlot1);
    if (!focusNode.hasFocus || _availableCrystals.isEmpty) {
      return const <CrystalLibraryEntry>[];
    }

    final String query = _crystalController(isSlot1).text.trim().toLowerCase();
    if (query.isEmpty) {
      return const <CrystalLibraryEntry>[];
    }

    final List<CrystalLibraryEntry> matches = <CrystalLibraryEntry>[];
    for (final CrystalLibraryEntry entry in _availableCrystals) {
      final String name = entry.name.trim().toLowerCase();
      if (!name.contains(query)) {
        continue;
      }
      matches.add(entry);
      if (matches.length >= 8) {
        break;
      }
    }
    return matches;
  }

  void _startCrystalInlineEditing(bool isSlot1) {
    final String? key = _selectedCrystalKey(isSlot1);
    if (key == null || key.trim().isEmpty) {
      return;
    }
    final TextEditingController controller = _crystalController(isSlot1);
    final FocusNode focusNode = _crystalFocusNode(isSlot1);
    setState(() {
      _setCrystalInlineEditing(isSlot1, true);
      controller.text = _displayCrystalName(key);
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    });
    focusNode.requestFocus();
  }

  void _selectCrystalInline(bool isSlot1, CrystalLibraryEntry entry) {
    if (isSlot1) {
      widget.onCrystal1Changed?.call(entry.key);
    } else {
      widget.onCrystal2Changed?.call(entry.key);
    }
    _crystalFocusNode(isSlot1).unfocus();
    setState(() {
      _setCrystalInlineEditing(isSlot1, false);
    });
  }

  void _commitCrystalInput(bool isSlot1) {
    final CrystalLibraryEntry? matched = _matchCrystalByName(
      _crystalController(isSlot1).text,
    );
    if (matched == null) {
      return;
    }
    _selectCrystalInline(isSlot1, matched);
  }

  void _onCrystalTapOutside(bool isSlot1) {
    _commitCrystalInput(isSlot1);
    _crystalFocusNode(isSlot1).unfocus();
  }

  void _clearCrystalSelection(bool isSlot1, VoidCallback? onClear) {
    onClear?.call();
    _crystalFocusNode(isSlot1).unfocus();
    setState(() {
      _setCrystalInlineEditing(isSlot1, false);
      _crystalController(isSlot1).clear();
    });
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
    final bool hasSelectedItem = widget.selectedEquipmentItem != null;
    final bool showSelectedCard =
        hasSelectedItem &&
        !widget.forceTextInput &&
        !(_canInlineNameSearch && _isInlineEditing);
    final List<EquipmentLibraryItem> inlineCandidates = _inlineCandidates();
    final bool showInlineSuggestions =
        _canInlineNameSearch &&
        !showSelectedCard &&
        inlineCandidates.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _label(widget.idLabel),
        Row(
          children: <Widget>[
            Expanded(
              child: showSelectedCard
                  ? (_canInlineNameSearch
                        ? InkWell(
                            onTap: _startInlineEditing,
                            borderRadius: BorderRadius.circular(8),
                            child: _selectedEquipmentField(
                              item: widget.selectedEquipmentItem!,
                            ),
                          )
                        : _selectedEquipmentField(
                            item: widget.selectedEquipmentItem!,
                          ))
                  : _inputField(
                      controller: _idController,
                      focusNode: _idFocusNode,
                      hint: widget.idHint,
                      onSubmitted: _commitId,
                      onTapOutside: _onIdTapOutside,
                      onChanged: _canInlineNameSearch
                          ? (_) {
                              setState(() {});
                            }
                          : null,
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
        if (showInlineSuggestions) ...<Widget>[
          const SizedBox(height: 8),
          _buildInlineSuggestions(inlineCandidates),
        ],
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
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Keep both crystal slots on one row for most layouts.
              // Fall back to vertical only on very narrow widths.
              final bool stackVertically = constraints.maxWidth < 560;
              final Widget slot1 = _crystalSlotField(
                isSlot1: true,
                label: 'Crystal Slot 1',
                selectedKey: widget.crystal1,
                onBrowse: _pickCrystalSlot1,
                onClear: widget.onCrystal1Changed == null
                    ? null
                    : () => widget.onCrystal1Changed!(null),
              );
              final Widget slot2 = _crystalSlotField(
                isSlot1: false,
                label: 'Crystal Slot 2',
                selectedKey: widget.crystal2,
                onBrowse: _pickCrystalSlot2,
                onClear: widget.onCrystal2Changed == null
                    ? null
                    : () => widget.onCrystal2Changed!(null),
              );

              if (stackVertically) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[slot1, const SizedBox(height: 10), slot2],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: slot1),
                  const SizedBox(width: 12),
                  Expanded(child: slot2),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildInlineSuggestions(List<EquipmentLibraryItem> candidates) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 6),
        shrinkWrap: true,
        itemCount: candidates.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.10)),
        itemBuilder: (BuildContext context, int index) {
          final EquipmentLibraryItem item = candidates[index];
          return ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -1.2),
            title: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              item.key,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
            onTap: () => _selectInlineCandidate(item),
          );
        },
      ),
    );
  }

  Widget _crystalSlotField({
    required bool isSlot1,
    required String label,
    required String? selectedKey,
    required VoidCallback onBrowse,
    required VoidCallback? onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _label(label),
        _crystalSelectionField(
          isSlot1: isSlot1,
          selectedKey: selectedKey,
          onBrowse: onBrowse,
          onClear: onClear,
        ),
      ],
    );
  }

  String _normalizeEquipmentTypeKey(String type) {
    return EquipmentLibraryQueryService.normalizeTypeKey(type);
  }

  String _resolveEquipmentDisplayTypeKey(EquipmentLibraryItem item) {
    String normalized = _normalizeEquipmentTypeKey(item.type);
    if (normalized != 'armor') {
      return normalized;
    }

    final String slotCategory = widget.pickInitialCategory.trim().toLowerCase();
    if (slotCategory == 'additional') {
      return 'additional';
    }
    if (slotCategory == 'special') {
      return 'special';
    }

    final String key = item.key.trim().toLowerCase();
    if (key.contains('_special_')) {
      return 'special';
    }
    if (key.contains('_additional_')) {
      return 'additional';
    }
    return normalized;
  }

  Color _equipmentTypeAccentColorForTypeKey(String typeKey) {
    switch (typeKey) {
      case '1h_sword':
      case '2h_sword':
      case 'katana':
      case 'dagger':
      case 'halberd':
        return const Color(0xFFFFCC80);
      case 'bow':
      case 'bowgun':
      case 'arrow':
        return const Color(0xFF90CAF9);
      case 'staff':
      case 'magic_device':
      case 'ninjutsu_scroll':
        return const Color(0xFFB39DDB);
      case 'shield':
      case 'armor':
        return const Color(0xFFA5D6A7);
      case 'additional':
        return const Color(0xFFFFAB91);
      case 'special':
        return const Color(0xFFFFE082);
      default:
        return const Color(0xFFB0BEC5);
    }
  }

  String _equipmentTypeAssetPathForTypeKey(String typeKey) {
    switch (typeKey) {
      case '1h_sword':
        return 'assets/data/icon/1h_sword_icon.png';
      case '2h_sword':
        return 'assets/data/icon/2h_sword_icon.png';
      case 'katana':
        return 'assets/data/icon/katana_icon.png';
      case 'dagger':
        return 'assets/data/icon/dagger_icon.png';
      case 'bow':
        return 'assets/data/icon/bow_icon.png';
      case 'bowgun':
        return 'assets/data/icon/bowgun_icon.png';
      case 'halberd':
        return 'assets/data/icon/halberd_icon.png';
      case 'knuckles':
        return 'assets/data/icon/knuckles_icon.png';
      case 'staff':
        return 'assets/data/icon/staff_icon.png';
      case 'magic_device':
        return 'assets/data/icon/magic_device_icon.png';
      case 'arrow':
        return 'assets/data/icon/arrow_icon.png';
      case 'shield':
        return 'assets/data/icon/shield_icon.png';
      case 'ninjutsu_scroll':
        return 'assets/data/icon/ninjut_suscroll_icon.png';
      case 'armor':
        return 'assets/data/icon/armor_icon.png';
      case 'additional':
        return 'assets/data/icon/add_icon.png';
      case 'special':
        return 'assets/data/icon/special_ring_icon.png';
      default:
        return '';
    }
  }

  String _normalizeAssetPath(String raw) {
    String path = raw.trim().replaceAll('\\', '/');
    if (path.startsWith('./')) {
      path = path.substring(2);
    }
    if (path.startsWith('/assets/')) {
      path = path.substring(1);
    }
    if (path.startsWith('assets/assets/')) {
      path = path.replaceFirst('assets/', '');
    }
    if (path.startsWith('data/')) {
      return 'assets/$path';
    }
    return path;
  }

  String _resolveEquipmentIconAssetPath(
    EquipmentLibraryItem item, {
    required String typeKey,
  }) {
    final String imagePath = _normalizeAssetPath(item.imageAssetPath);
    if (imagePath.isNotEmpty) {
      if (imagePath.startsWith('assets/')) {
        return imagePath;
      }
      if (imagePath.startsWith('data/')) {
        return 'assets/$imagePath';
      }
      return imagePath;
    }
    return _equipmentTypeAssetPathForTypeKey(typeKey);
  }

  Widget _selectedEquipmentField({required EquipmentLibraryItem item}) {
    final String typeKey = _resolveEquipmentDisplayTypeKey(item);
    final Color accentColor = _equipmentTypeAccentColorForTypeKey(typeKey);
    final String assetPath = _resolveEquipmentIconAssetPath(
      item,
      typeKey: typeKey,
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.48)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withValues(alpha: 0.45)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: assetPath.isEmpty
                  ? Icon(
                      Icons.sports_martial_arts,
                      size: 14,
                      color: accentColor,
                    )
                  : Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return Icon(
                          Icons.sports_martial_arts,
                          size: 14,
                          color: accentColor,
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.key,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
    FocusNode? focusNode,
    required String hint,
    required VoidCallback onSubmitted,
    required VoidCallback onTapOutside,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
    TextAlign textAlign = TextAlign.left,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
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
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted(),
      onTapOutside: (_) => onTapOutside(),
    );
  }

  String _crystalCategoryLabel(String category) {
    final String normalized = category.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '-';
    }
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  String _crystalStatLabel(EquipmentStat stat) {
    final String normalizedKey = stat.statKey.trim().toLowerCase();
    final bool isBase = stat.valueType.trim().toLowerCase() == 'base';
    if (isBase) {
      switch (normalizedKey) {
        case 'weapon_atk':
          return 'Base ATK';
        case 'def':
          return 'Base DEF';
        case 'mdef':
          return 'Base MDEF';
        case 'stability':
          return 'Base Stability %';
      }
      return 'Base ${_humanizeCrystalStatKey(normalizedKey)}';
    }

    switch (normalizedKey) {
      case 'weapon_atk':
        return 'Weapon ATK';
      case 'attack_mp_recovery':
        return 'Attack MP Recovery';
      case 'critical_rate':
        return 'Critical Rate';
      case 'critical_damage':
        return 'Critical Damage';
      case 'physical_pierce':
        return 'Physical Pierce';
      case 'magic_pierce':
        return 'Magic Pierce';
      case 'guard_power':
        return 'Guard Power';
      case 'guard_recharge':
        return 'Guard Recharge';
      case 'maxhp':
        return 'MaxHP';
      case 'maxmp':
        return 'MaxMP';
    }
    return _humanizeCrystalStatKey(normalizedKey);
  }

  String _humanizeCrystalStatKey(String key) {
    if (key.isEmpty) {
      return '-';
    }
    const Set<String> uppercaseTokens = <String>{
      'atk',
      'matk',
      'def',
      'mdef',
      'str',
      'dex',
      'int',
      'agi',
      'vit',
      'aspd',
      'cspd',
      'hp',
      'mp',
      'ampr',
      'exp',
    };

    return key
        .replaceAll('_', ' ')
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .map((String part) {
          final String token = part.toLowerCase();
          if (token == 'pct') {
            return '%';
          }
          if (uppercaseTokens.contains(token)) {
            return token.toUpperCase();
          }
          if (token.length == 1) {
            return token.toUpperCase();
          }
          return '${token[0].toUpperCase()}${token.substring(1)}';
        })
        .join(' ');
  }

  String _formatCrystalNumber(num value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    final String fixed = value.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _crystalStatValue(EquipmentStat stat) {
    final String sign = stat.value >= 0 ? '+' : '';
    final String suffix = stat.valueType.trim().toLowerCase() == 'percent'
        ? '%'
        : '';
    return '$sign${_formatCrystalNumber(stat.value)}$suffix';
  }

  Widget _selectedCrystalField({
    required CrystalLibraryEntry? entry,
    required String rawKey,
    required VoidCallback onTap,
  }) {
    final String displayName = _displayCrystalName(rawKey);
    final Color accentColor = _crystalAccentColor(entry);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentColor.withValues(alpha: 0.48)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withValues(alpha: 0.45)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  _crystalIconPath(entry),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return Icon(
                      Icons.diamond_outlined,
                      size: 14,
                      color: accentColor,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrystalInlineSuggestions({
    required bool isSlot1,
    required List<CrystalLibraryEntry> candidates,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 6),
        shrinkWrap: true,
        itemCount: candidates.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.10)),
        itemBuilder: (BuildContext context, int index) {
          final CrystalLibraryEntry entry = candidates[index];
          final Color accentColor = _crystalAccentColor(entry);
          return ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -1.2),
            leading: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withValues(alpha: 0.45)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  _crystalIconPath(entry),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return Icon(
                      Icons.diamond_outlined,
                      size: 14,
                      color: accentColor,
                    );
                  },
                ),
              ),
            ),
            title: Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${entry.key} - ${_crystalCategoryLabel(entry.category)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
            onTap: () => _selectCrystalInline(isSlot1, entry),
          );
        },
      ),
    );
  }

  Widget _buildCrystalStatPreview(CrystalLibraryEntry entry) {
    if (entry.stats.isEmpty) {
      return Text(
        'No crystal stats data',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 11,
        ),
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: entry.stats
          .map(
            (EquipmentStat stat) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Text(
                '${_crystalStatLabel(stat)} ${_crystalStatValue(stat)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _crystalSelectionField({
    required bool isSlot1,
    required String? selectedKey,
    required VoidCallback onBrowse,
    required VoidCallback? onClear,
  }) {
    final String rawKey = selectedKey?.trim() ?? '';
    final bool hasValue = rawKey.isNotEmpty;
    final CrystalLibraryEntry? selectedEntry = hasValue
        ? _crystalByKey[rawKey.toLowerCase()]
        : null;
    final bool isEditing = _isCrystalInlineEditing(isSlot1) || !hasValue;
    final bool canBrowse = _canBrowseCrystals && !_isCrystalLoading;
    final List<CrystalLibraryEntry> inlineCandidates = _crystalInlineCandidates(
      isSlot1: isSlot1,
    );
    final bool showInlineSuggestions = isEditing && inlineCandidates.isNotEmpty;
    final VoidCallback? onClearSelection = onClear == null
        ? null
        : () => _clearCrystalSelection(isSlot1, onClear);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: isEditing
                  ? _inputField(
                      controller: _crystalController(isSlot1),
                      focusNode: _crystalFocusNode(isSlot1),
                      hint: _isCrystalLoading
                          ? 'Loading crystal data...'
                          : 'Search crystal name...',
                      onSubmitted: () => _commitCrystalInput(isSlot1),
                      onTapOutside: () => _onCrystalTapOutside(isSlot1),
                      onChanged: (_) {
                        setState(() {});
                      },
                    )
                  : _selectedCrystalField(
                      entry: selectedEntry,
                      rawKey: rawKey,
                      onTap: () => _startCrystalInlineEditing(isSlot1),
                    ),
            ),
            const SizedBox(width: 8),
            _libraryButton(
              onTap: onBrowse,
              enabled: canBrowse,
              tooltip: _isCrystalLoading
                  ? 'Loading crystals...'
                  : 'Browse crystals',
            ),
            if (hasValue) ...<Widget>[
              const SizedBox(width: 8),
              _clearButton(onTap: onClearSelection),
            ],
          ],
        ),
        if (showInlineSuggestions) ...<Widget>[
          const SizedBox(height: 8),
          _buildCrystalInlineSuggestions(
            isSlot1: isSlot1,
            candidates: inlineCandidates,
          ),
        ],
        if (hasValue && selectedEntry != null) ...<Widget>[
          const SizedBox(height: 8),
          _buildCrystalStatPreview(selectedEntry),
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
          child: const Icon(Icons.close, size: 16, color: Colors.white70),
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
    return widget.entries
        .where((CrystalLibraryEntry entry) {
          if (_categoryFilter != null && entry.category != _categoryFilter) {
            return false;
          }
          if (normalizedQuery.isEmpty) {
            return true;
          }
          return entry.name.toLowerCase().contains(normalizedQuery) ||
              entry.key.toLowerCase().contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  String _categoryLabel(String category) {
    if (category.isEmpty) {
      return '-';
    }
    return category[0].toUpperCase() + category.substring(1).toLowerCase();
  }

  Color _categoryAccentColor(String category) {
    switch (category.trim().toLowerCase()) {
      case 'weapon':
        return _crystalAccentColors['red']!;
      case 'armor':
        return _crystalAccentColors['green']!;
      case 'additional':
        return _crystalAccentColors['yellow']!;
      case 'special':
        return _crystalAccentColors['purple']!;
      case 'normal':
        return _crystalAccentColors['blue']!;
      default:
        return const Color(0xFF64B5F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String selectedKey = widget.selectedKey?.trim().toLowerCase() ?? '';
    final List<String> categories = _categories;
    final List<CrystalLibraryEntry> filtered = _filteredEntries;
    final MediaQueryData media = MediaQuery.of(context);
    final double topInset = (media.padding.top + 12).toDouble();
    final double availableHeight = media.size.height - topInset - 20;
    final double maxDialogHeight = availableHeight
        .clamp(360.0, 760.0)
        .toDouble();

    return Dialog(
      backgroundColor: const Color(0xFF101010),
      clipBehavior: Clip.antiAlias,
      insetPadding: EdgeInsets.fromLTRB(20, topInset, 20, 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 760, maxHeight: maxDialogHeight),
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
                      final Color accentColor = _categoryAccentColor(category);
                      return ChoiceChip(
                        label: Text(_categoryLabel(category)),
                        selected: _categoryFilter == category,
                        selectedColor: accentColor.withValues(alpha: 0.28),
                        backgroundColor: const Color(0xFF161A1D),
                        side: BorderSide(
                          color: _categoryFilter == category
                              ? accentColor.withValues(alpha: 0.72)
                              : accentColor.withValues(alpha: 0.36),
                        ),
                        labelStyle: const TextStyle(color: Colors.white),
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
                          final Color accentColor = _crystalAccentColor(entry);
                          return ListTile(
                            dense: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? accentColor.withValues(alpha: 0.75)
                                    : accentColor.withValues(alpha: 0.28),
                              ),
                            ),
                            selected: isSelected,
                            selectedTileColor: accentColor.withValues(
                              alpha: 0.18,
                            ),
                            leading: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.42),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Image.asset(
                                  _crystalIconPath(entry),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) {
                                    return Icon(
                                      Icons.diamond_outlined,
                                      size: 14,
                                      color: accentColor,
                                    );
                                  },
                                ),
                              ),
                            ),
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
                                ? Icon(
                                    Icons.check_circle,
                                    color: accentColor,
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
    );
  }
}
