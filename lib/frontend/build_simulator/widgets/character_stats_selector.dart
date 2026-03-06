import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CharacterStatsSelector extends StatelessWidget {
  const CharacterStatsSelector({
    super.key,
    required this.character,
    required this.level,
    required this.personalStatType,
    required this.personalStatValue,
    required this.usedStatPoints,
    required this.totalStatPoints,
    required this.onStatChanged,
    required this.onLevelChanged,
    required this.onPersonalStatTypeChanged,
    required this.onPersonalStatValueChanged,
    required this.onRecalculate,
  });

  final Map<String, dynamic> character;
  final int level;
  final String personalStatType;
  final int personalStatValue;
  final int usedStatPoints;
  final int totalStatPoints;
  final void Function(String key, int value) onStatChanged;
  final ValueChanged<int> onLevelChanged;
  final ValueChanged<String> onPersonalStatTypeChanged;
  final ValueChanged<int> onPersonalStatValueChanged;
  final VoidCallback onRecalculate;

  static const int _minStat = 0;
  static const int _maxStat = 512;
  static const int _minLevel = 1;
  static const int _maxLevel = 300;
  static const int _minPersonalStat = 0;
  static const int _maxPersonalStat = 255;
  static const List<String> _personalStatOptions = <String>[
    'CRT',
    'LUK',
    'TEC',
    'MNT',
  ];

  int _valueOf(String key) {
    final value = character[key];
    if (value is num) {
      return value.toInt().clamp(_minStat, _maxStat);
    }
    return _minStat;
  }

  String _normalizedPersonalStatType() {
    final String normalized = personalStatType.trim().toUpperCase();
    if (_personalStatOptions.contains(normalized)) {
      return normalized;
    }
    return _personalStatOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    final String selectedPersonalType = _normalizedPersonalStatType();
    final int safeUsed = usedStatPoints < 0 ? 0 : usedStatPoints;
    final int safeTotal = totalStatPoints <= 0 ? 1 : totalStatPoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Character Properties ($safeUsed / $safeTotal stat points used)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Maximum stat value can be changed from your profile's setting",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _StatRow(
          label: 'Lv',
          value: level.clamp(_minLevel, _maxLevel).toInt(),
          min: _minLevel,
          max: _maxLevel,
          onChanged: onLevelChanged,
        ),
        const SizedBox(height: 8),
        _StatRow(
          label: 'STR',
          value: _valueOf('STR'),
          min: _minStat,
          max: _maxStat,
          onChanged: (value) => onStatChanged('STR', value),
        ),
        const SizedBox(height: 8),
        _StatRow(
          label: 'DEX',
          value: _valueOf('DEX'),
          min: _minStat,
          max: _maxStat,
          onChanged: (value) => onStatChanged('DEX', value),
        ),
        const SizedBox(height: 8),
        _StatRow(
          label: 'INT',
          value: _valueOf('INT'),
          min: _minStat,
          max: _maxStat,
          onChanged: (value) => onStatChanged('INT', value),
        ),
        const SizedBox(height: 8),
        _StatRow(
          label: 'AGI',
          value: _valueOf('AGI'),
          min: _minStat,
          max: _maxStat,
          onChanged: (value) => onStatChanged('AGI', value),
        ),
        const SizedBox(height: 8),
        _StatRow(
          label: 'VIT',
          value: _valueOf('VIT'),
          min: _minStat,
          max: _maxStat,
          onChanged: (value) => onStatChanged('VIT', value),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF101010),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Personal Stat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedPersonalType,
                dropdownColor: const Color(0xFF141414),
                iconEnabledColor: Colors.white70,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF141414),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                items: _personalStatOptions
                    .map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    })
                    .toList(growable: false),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }
                  onPersonalStatTypeChanged(value);
                },
              ),
              const SizedBox(height: 8),
              _StatRow(
                label: selectedPersonalType,
                value: personalStatValue
                    .clamp(_minPersonalStat, _maxPersonalStat)
                    .toInt(),
                min: _minPersonalStat,
                max: _maxPersonalStat,
                onChanged: onPersonalStatValueChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onRecalculate,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Recalculate'),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatefulWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  State<_StatRow> createState() => _StatRowState();
}

class _StatRowState extends State<_StatRow> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _StatRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commitCurrentText() {
    final parsed = int.tryParse(_controller.text);
    if (parsed == null) {
      _controller.text = widget.value.toString();
      return;
    }
    final clamped = parsed.clamp(widget.min, widget.max);
    widget.onChanged(clamped);
    _controller.text = clamped.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 42,
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              _SquareIconButton(
                icon: Icons.remove,
                onTap: () => widget.onChanged(
                  (widget.value - 1).clamp(widget.min, widget.max),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 56,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF141414),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                  onSubmitted: (_) => _commitCurrentText(),
                  onTapOutside: (_) => _commitCurrentText(),
                ),
              ),
              const SizedBox(width: 8),
              _SquareIconButton(
                icon: Icons.add,
                onTap: () => widget.onChanged(
                  (widget.value + 1).clamp(widget.min, widget.max),
                ),
              ),
            ],
          ),
          Slider(
            value: widget.value.clamp(widget.min, widget.max).toDouble(),
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            divisions: widget.max - widget.min,
            label: widget.value.toString(),
            activeColor: Colors.white,
            inactiveColor: Colors.white24,
            onChanged: (double value) {
              widget.onChanged(value.round().clamp(widget.min, widget.max));
            },
          ),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Ink(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}
