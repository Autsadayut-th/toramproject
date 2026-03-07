import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CriticalSimulatorPage extends StatefulWidget {
  const CriticalSimulatorPage({super.key});

  @override
  State<CriticalSimulatorPage> createState() => _CriticalSimulatorPageState();
}

class _CriticalSimulatorPageState extends State<CriticalSimulatorPage> {
  static const String _rulesAssetPath = 'assets/data/rules/critical_rules.json';

  final TextEditingController _crtController = TextEditingController(text: '0');
  final TextEditingController _flatRateController = TextEditingController(
    text: '0',
  );
  final TextEditingController _percentRateController = TextEditingController(
    text: '0',
  );
  final TextEditingController _strController = TextEditingController(text: '0');
  final TextEditingController _flatDamageController = TextEditingController(
    text: '0',
  );
  final TextEditingController _percentDamageController = TextEditingController(
    text: '0',
  );
  final TextEditingController _baseDamageController = TextEditingController(
    text: '1000',
  );

  _CriticalRules _rules = const _CriticalRules();
  bool _isLoadingRules = true;
  String? _rulesError;

  double _crt = 0;
  double _flatCriticalRate = 0;
  double _percentCriticalRate = 0;
  double _str = 0;
  double _flatCriticalDamage = 0;
  double _percentCriticalDamage = 0;
  double _baseDamage = 1000;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  @override
  void dispose() {
    _crtController.dispose();
    _flatRateController.dispose();
    _percentRateController.dispose();
    _strController.dispose();
    _flatDamageController.dispose();
    _percentDamageController.dispose();
    _baseDamageController.dispose();
    super.dispose();
  }

  Future<void> _loadRules() async {
    try {
      final String raw = await rootBundle.loadString(_rulesAssetPath);
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw const FormatException('critical_rules.json is not a JSON object');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _rules = _CriticalRules.fromJson(Map<String, dynamic>.from(decoded));
        _isLoadingRules = false;
        _rulesError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _rules = const _CriticalRules();
        _isLoadingRules = false;
        _rulesError = 'Failed to load rules, using fallback values.';
      });
    }
  }

  double get _criticalRate =>
      _rules.criticalRateBase +
      (_crt * _rules.crtRatio) +
      _flatCriticalRate +
      _percentCriticalRate;

  double get _rawCriticalDamage =>
      _rules.criticalDamageBase +
      (_str * _rules.strRatio) +
      _flatCriticalDamage +
      _percentCriticalDamage;

  double get _finalCriticalDamage {
    if (_rawCriticalDamage <= _rules.softCapThreshold) {
      return _rawCriticalDamage;
    }
    return _rules.softCapThreshold +
        ((_rawCriticalDamage - _rules.softCapThreshold) / 2);
  }

  double get _criticalMultiplier => _finalCriticalDamage / 100;

  double get _criticalHitDamage => _baseDamage * _criticalMultiplier;

  void _onChanged(String value, ValueChanged<double> onParsed) {
    onParsed(_parseDouble(value));
    setState(() {});
  }

  double _parseDouble(String value) {
    return double.tryParse(value.trim().replaceAll(',', '')) ?? 0;
  }

  String _formatNumber(double value, {int precision = 2}) {
    final double rounded = double.parse(value.toStringAsFixed(precision));
    if (rounded == rounded.truncateToDouble()) {
      return rounded.toInt().toString();
    }
    return rounded.toStringAsFixed(precision);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
        title: const Text('Critical Simulator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_isLoadingRules) ...<Widget>[
                  const LinearProgressIndicator(minHeight: 2),
                  const SizedBox(height: 10),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1216),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0x33FFFFFF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Rule source: $_rulesAssetPath',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      if (_rulesError != null) ...<Widget>[
                        const SizedBox(height: 6),
                        Text(
                          _rulesError!,
                          style: const TextStyle(
                            color: Color(0xFFFFB3B3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: '1. Critical Rate',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Critical Rate = ${_formatNumber(_rules.criticalRateBase)} + '
                        '(CRT x ${_formatNumber(_rules.crtRatio)}) + Flat + Percent',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: <Widget>[
                          _NumberField(
                            width: 220,
                            label: 'CRT',
                            controller: _crtController,
                            onChanged: (String value) =>
                                _onChanged(value, (double parsed) {
                                  _crt = parsed;
                                }),
                          ),
                          _NumberField(
                            width: 220,
                            label: 'Flat Critical Rate',
                            controller: _flatRateController,
                            onChanged: (String value) =>
                                _onChanged(value, (double parsed) {
                                  _flatCriticalRate = parsed;
                                }),
                          ),
                          _NumberField(
                            width: 220,
                            label: 'Percent Critical Rate',
                            controller: _percentRateController,
                            onChanged: (String value) =>
                                _onChanged(value, (double parsed) {
                                  _percentCriticalRate = parsed;
                                }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ResultBox(
                        label: 'Final Critical Rate',
                        value: _formatNumber(_criticalRate),
                        suffix: '%',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: '2. Critical Damage',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Critical Damage = ${_formatNumber(_rules.criticalDamageBase)} + '
                        '(STR x ${_formatNumber(_rules.strRatio)}) + Flat + Percent',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: <Widget>[
                          _NumberField(
                            width: 220,
                            label: 'STR',
                            controller: _strController,
                            onChanged: (String value) =>
                                _onChanged(value, (double parsed) {
                                  _str = parsed;
                                }),
                          ),
                          _NumberField(
                            width: 220,
                            label: 'Flat Critical Damage',
                            controller: _flatDamageController,
                            onChanged: (String value) =>
                                _onChanged(value, (double parsed) {
                                  _flatCriticalDamage = parsed;
                                }),
                          ),
                          _NumberField(
                            width: 220,
                            label: 'Percent Critical Damage',
                            controller: _percentDamageController,
                            onChanged: (String value) =>
                                _onChanged(value, (double parsed) {
                                  _percentCriticalDamage = parsed;
                                }),
                          ),
                          _NumberField(
                            width: 220,
                            label: 'Base Damage',
                            controller: _baseDamageController,
                            onChanged: (String value) =>
                                _onChanged(value, (double parsed) {
                                  _baseDamage = parsed;
                                }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: <Widget>[
                          _ResultBox(
                            label: 'Raw Critical Damage',
                            value: _formatNumber(_rawCriticalDamage),
                            suffix: '%',
                          ),
                          _ResultBox(
                            label: 'Final Critical Damage (Soft Cap)',
                            value: _formatNumber(_finalCriticalDamage),
                            suffix: '%',
                          ),
                          _ResultBox(
                            label: 'Critical Multiplier',
                            value: '${_formatNumber(_criticalMultiplier)}x',
                          ),
                          _ResultBox(
                            label: 'Estimated Critical Hit',
                            value: _formatNumber(_criticalHitDamage),
                          ),
                        ],
                      ),
                    ],
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.width = 200,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          filled: true,
          fillColor: const Color(0xFF0A0F14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0x44FFFFFF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0x66FFFFFF)),
          ),
        ),
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  const _ResultBox({
    required this.label,
    required this.value,
    this.suffix = '',
  });

  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF121821),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            '$value$suffix',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CriticalRules {
  const _CriticalRules({
    this.criticalRateBase = 25,
    this.crtRatio = 0.25,
    this.criticalDamageBase = 150,
    this.strRatio = 0.2,
    this.softCapThreshold = 300,
  });

  final double criticalRateBase;
  final double crtRatio;
  final double criticalDamageBase;
  final double strRatio;
  final double softCapThreshold;

  factory _CriticalRules.fromJson(Map<String, dynamic> source) {
    final Map<String, dynamic> root = _toMap(source['critical_rules']);
    final Map<String, dynamic> rate = _toMap(root['critical_rate']);
    final Map<String, dynamic> rateScaling = _toMap(rate['crt_scaling']);
    final Map<String, dynamic> damage = _toMap(root['critical_damage']);
    final Map<String, dynamic> damageScaling = _toMap(damage['str_scaling']);
    final Map<String, dynamic> softCap = _toMap(root['critical_soft_cap']);

    return _CriticalRules(
      criticalRateBase: _toDouble(rate['base'], fallback: 25),
      crtRatio: _toDouble(rateScaling['ratio'], fallback: 0.25),
      criticalDamageBase: _toDouble(damage['base'], fallback: 150),
      strRatio: _toDouble(damageScaling['ratio'], fallback: 0.2),
      softCapThreshold: _toDouble(softCap['threshold'], fallback: 300),
    );
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  static double _toDouble(dynamic value, {required double fallback}) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }
}
