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
    required this.onTotalStatPointsChanged,
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
  final ValueChanged<int> onTotalStatPointsChanged;
  final void Function(String key, int value) onStatChanged;
  final ValueChanged<int> onLevelChanged;
  final ValueChanged<String> onPersonalStatTypeChanged;
  final ValueChanged<int> onPersonalStatValueChanged;
  final VoidCallback onRecalculate;

  static const int _minStat = 0;
  static const int _maxStat = 510;
  static const int _minLevel = 1;
  static const int _maxLevel = 999;
  static const int _minTotalStatPoints = 1;
  static const int _maxTotalStatPoints = 9999;
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

  int _maxAllowedMainStatValue({
    required String key,
    required int safeUsed,
    required int safeTotal,
  }) {
    final int currentValue = _valueOf(key);
    final int currentCost = (currentValue - 1).clamp(0, _maxStat).toInt();
    final int usedWithoutCurrent = (safeUsed - currentCost).clamp(0, 999999);
    final int remainingPoints = (safeTotal - usedWithoutCurrent)
        .clamp(0, _maxStat)
        .toInt();
    return (remainingPoints + 1).clamp(_minStat, _maxStat).toInt();
  }

  int _maxAllowedPersonalStatValue({
    required int safeUsed,
    required int safeTotal,
  }) {
    final int usedWithoutPersonal =
        (safeUsed - personalStatValue.clamp(0, _maxPersonalStat).toInt()).clamp(
          0,
          999999,
        );
    return (safeTotal - usedWithoutPersonal).clamp(0, _maxPersonalStat).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String selectedPersonalType = _normalizedPersonalStatType();
    final int safeUsed = usedStatPoints < 0 ? 0 : usedStatPoints;
    final int safeTotal = totalStatPoints <= 0 ? 1 : totalStatPoints;
    final bool isOverPoints = safeUsed > safeTotal;
    final int exceededPoints = isOverPoints ? safeUsed - safeTotal : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Character Properties ($safeUsed / $safeTotal stat points used)',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lv max 999, each main stat max 510',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.54),
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                    if (isOverPoints)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Stat points exceeded by $exceededPoints points.',
                          style: TextStyle(
                            color: colorScheme.error,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _InlineNumberAdjuster(
                value: safeTotal,
                min: _minTotalStatPoints,
                max: _maxTotalStatPoints,
                onChanged: onTotalStatPointsChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _StatRow(
          key: const ValueKey<String>('stat_row_level'),
          label: 'Lv',
          value: level.clamp(_minLevel, _maxLevel).toInt(),
          min: _minLevel,
          max: _maxLevel,
          effectiveMax: _maxLevel,
          onChanged: onLevelChanged,
          deferSliderCommit: true,
        ),
        const SizedBox(height: 8),
        _StatRow(
          key: const ValueKey<String>('stat_row_str'),
          label: 'STR',
          value: _valueOf('STR'),
          min: _minStat,
          max: _maxStat,
          effectiveMax: _maxAllowedMainStatValue(
            key: 'STR',
            safeUsed: safeUsed,
            safeTotal: safeTotal,
          ),
          onChanged: (value) => onStatChanged('STR', value),
          deferSliderCommit: true,
        ),
        const SizedBox(height: 8),
        _StatRow(
          key: const ValueKey<String>('stat_row_dex'),
          label: 'DEX',
          value: _valueOf('DEX'),
          min: _minStat,
          max: _maxStat,
          effectiveMax: _maxAllowedMainStatValue(
            key: 'DEX',
            safeUsed: safeUsed,
            safeTotal: safeTotal,
          ),
          onChanged: (value) => onStatChanged('DEX', value),
          deferSliderCommit: true,
        ),
        const SizedBox(height: 8),
        _StatRow(
          key: const ValueKey<String>('stat_row_int'),
          label: 'INT',
          value: _valueOf('INT'),
          min: _minStat,
          max: _maxStat,
          effectiveMax: _maxAllowedMainStatValue(
            key: 'INT',
            safeUsed: safeUsed,
            safeTotal: safeTotal,
          ),
          onChanged: (value) => onStatChanged('INT', value),
          deferSliderCommit: true,
        ),
        const SizedBox(height: 8),
        _StatRow(
          key: const ValueKey<String>('stat_row_agi'),
          label: 'AGI',
          value: _valueOf('AGI'),
          min: _minStat,
          max: _maxStat,
          effectiveMax: _maxAllowedMainStatValue(
            key: 'AGI',
            safeUsed: safeUsed,
            safeTotal: safeTotal,
          ),
          onChanged: (value) => onStatChanged('AGI', value),
          deferSliderCommit: true,
        ),
        const SizedBox(height: 8),
        _StatRow(
          key: const ValueKey<String>('stat_row_vit'),
          label: 'VIT',
          value: _valueOf('VIT'),
          min: _minStat,
          max: _maxStat,
          effectiveMax: _maxAllowedMainStatValue(
            key: 'VIT',
            safeUsed: safeUsed,
            safeTotal: safeTotal,
          ),
          onChanged: (value) => onStatChanged('VIT', value),
          deferSliderCommit: true,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Personal Stat',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedPersonalType,
                dropdownColor: colorScheme.surfaceContainerHigh,
                iconEnabledColor: colorScheme.onSurface.withValues(alpha: 0.75),
                style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.18),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.18),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.35),
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
                key: ValueKey<String>(
                  'stat_row_personal_$selectedPersonalType',
                ),
                label: selectedPersonalType,
                value: personalStatValue
                    .clamp(_minPersonalStat, _maxPersonalStat)
                    .toInt(),
                min: _minPersonalStat,
                max: _maxPersonalStat,
                effectiveMax: _maxAllowedPersonalStatValue(
                  safeUsed: safeUsed,
                  safeTotal: safeTotal,
                ),
                onChanged: onPersonalStatValueChanged,
                deferSliderCommit: true,
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
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Recalculate'),
          ),
        ),
      ],
    );
  }
}

class _InlineNumberAdjuster extends StatefulWidget {
  const _InlineNumberAdjuster({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  State<_InlineNumberAdjuster> createState() => _InlineNumberAdjusterState();
}

class _InlineNumberAdjusterState extends State<_InlineNumberAdjuster> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _InlineNumberAdjuster oldWidget) {
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
    final int? parsed = int.tryParse(_controller.text);
    if (parsed == null) {
      _controller.text = widget.value.toString();
      return;
    }
    final int clamped = parsed.clamp(widget.min, widget.max).toInt();
    widget.onChanged(clamped);
    _controller.text = clamped.toString();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _HeaderIconButton(
          icon: Icons.remove,
          onTap: () => widget.onChanged(
            (widget.value - 1).clamp(widget.min, widget.max),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 66,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 7,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.18),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.18),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ),
            ),
            onSubmitted: (_) => _commitCurrentText(),
            onTapOutside: (_) => _commitCurrentText(),
          ),
        ),
        const SizedBox(width: 8),
        _HeaderIconButton(
          icon: Icons.add,
          onTap: () => widget.onChanged(
            (widget.value + 1).clamp(widget.min, widget.max),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 20,
        height: 20,
        child: Icon(icon, size: 16, color: colorScheme.onSurface),
      ),
    );
  }
}

class _StatRow extends StatefulWidget {
  const _StatRow({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.effectiveMax,
    required this.onChanged,
    this.deferSliderCommit = false,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int effectiveMax;
  final ValueChanged<int> onChanged;
  final bool deferSliderCommit;

  @override
  State<_StatRow> createState() => _StatRowState();
}

class _StatRowState extends State<_StatRow> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  int? _dragValue;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _StatRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_dragValue != null && oldWidget.value != widget.value) {
      _dragValue = null;
    }

    final int nextEffectiveValue = _effectiveValue;
    final String nextText = nextEffectiveValue.toString();
    if (!_focusNode.hasFocus && _controller.text != nextText) {
      _controller.text = nextText;
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
    final int effectiveMax = _effectiveMax;
    if (parsed == null) {
      _controller.text = _effectiveValue.toString();
      return;
    }
    final int clamped = parsed.clamp(widget.min, effectiveMax).toInt();
    _dragValue = null;
    widget.onChanged(clamped);
    _controller.text = clamped.toString();
  }

  int get _effectiveMax {
    return widget.effectiveMax.clamp(widget.min, widget.max).toInt();
  }

  int get _effectiveValue =>
      (_dragValue ?? widget.value).clamp(widget.min, _effectiveMax).toInt();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final int effectiveValue = _effectiveValue;
    final int effectiveMax = _effectiveMax;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 42,
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              _SquareIconButton(
                icon: Icons.remove,
                onTap: () => widget.onChanged(
                  (effectiveValue - 1).clamp(widget.min, effectiveMax),
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
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: colorScheme.onSurface.withValues(alpha: 0.18),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: colorScheme.onSurface.withValues(alpha: 0.18),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: colorScheme.onSurface.withValues(alpha: 0.35),
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
                  (effectiveValue + 1).clamp(widget.min, effectiveMax),
                ),
              ),
            ],
          ),
          Slider(
            value: effectiveValue.toDouble(),
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            divisions: (widget.max - widget.min).clamp(1, 99999),
            label: effectiveValue.toString(),
            activeColor: colorScheme.primary,
            inactiveColor: colorScheme.onSurface.withValues(alpha: 0.24),
            onChanged: (double value) {
              final int nextValue = value.round().clamp(
                widget.min,
                effectiveMax,
              );
              if (widget.deferSliderCommit) {
                setState(() {
                  _dragValue = nextValue;
                  _controller.text = nextValue.toString();
                });
                return;
              }
              widget.onChanged(nextValue);
            },
            onChangeEnd: widget.deferSliderCommit
                ? (double value) {
                    final int nextValue = value.round().clamp(
                      widget.min,
                      effectiveMax,
                    );
                    _dragValue = null;
                    widget.onChanged(nextValue);
                  }
                : null,
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Ink(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.24),
          ),
        ),
        child: Icon(icon, size: 16, color: colorScheme.onSurface),
      ),
    );
  }
}
