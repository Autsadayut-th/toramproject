import 'package:flutter/material.dart';

import '../../equipment_library/equipment_library_page.dart';

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
  late final TextEditingController _crystal1Controller;
  late final TextEditingController _crystal2Controller;

  bool get _showCrystalSlots =>
      widget.onCrystal1Changed != null && widget.onCrystal2Changed != null;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.selectedId ?? '');
    _crystal1Controller = TextEditingController(text: widget.crystal1 ?? '');
    _crystal2Controller = TextEditingController(text: widget.crystal2 ?? '');
  }

  @override
  void didUpdateWidget(covariant EquipmentSlotSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      _idController.text = widget.selectedId ?? '';
    }
    if (oldWidget.crystal1 != widget.crystal1) {
      _crystal1Controller.text = widget.crystal1 ?? '';
    }
    if (oldWidget.crystal2 != widget.crystal2) {
      _crystal2Controller.text = widget.crystal2 ?? '';
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _crystal1Controller.dispose();
    _crystal2Controller.dispose();
    super.dispose();
  }

  void _commitId() {
    final String value = _idController.text.trim();
    widget.onEquipChanged(value.isEmpty ? null : value);
  }

  void _commitCrystal1() {
    if (widget.onCrystal1Changed == null) {
      return;
    }
    final String value = _crystal1Controller.text.trim();
    widget.onCrystal1Changed!(value.isEmpty ? null : value);
  }

  void _commitCrystal2() {
    if (widget.onCrystal2Changed == null) {
      return;
    }
    final String value = _crystal2Controller.text.trim();
    widget.onCrystal2Changed!(value.isEmpty ? null : value);
  }

  Future<void> _pickFromLibrary() async {
    final String? selectedKey = await EquipmentLibraryScreen.pickItemKey(
      context,
      initialCategory: widget.pickInitialCategory,
      allowedCategories: widget.allowedCategories,
      title: widget.pickTitle,
    );
    if (!mounted || selectedKey == null || selectedKey.isEmpty) {
      return;
    }
    _idController.text = selectedKey;
    widget.onEquipChanged(selectedKey);
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
              ),
            ),
            const SizedBox(width: 8),
            _libraryButton(onTap: _pickFromLibrary),
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
          _inputField(
            controller: _crystal1Controller,
            hint: 'Crystal name',
            onSubmitted: _commitCrystal1,
            onTapOutside: _commitCrystal1,
          ),
          const SizedBox(height: 10),
          _label('Crystal Slot 2'),
          _inputField(
            controller: _crystal2Controller,
            hint: 'Crystal name',
            onSubmitted: _commitCrystal2,
            onTapOutside: _commitCrystal2,
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
    TextAlign textAlign = TextAlign.left,
  }) {
    return TextField(
      controller: controller,
      textAlign: textAlign,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

  Widget _libraryButton({required VoidCallback onTap}) {
    return Tooltip(
      message: 'Browse library',
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
            Icons.menu_book_outlined,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
