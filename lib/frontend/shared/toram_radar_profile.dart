import 'dart:math' as math;

import 'package:flutter/painting.dart';

enum ToramRadarScaleCurve { linear, sqrt, log }

class ToramRadarMetricSpec {
  const ToramRadarMetricSpec({
    required this.id,
    required this.label,
    required this.cap,
    this.curve = ToramRadarScaleCurve.linear,
  });

  final String id;
  final String label;
  final double cap;
  final ToramRadarScaleCurve curve;
}

class ToramRadarLabelAnchor {
  const ToramRadarLabelAnchor({
    required this.index,
    required this.alignment,
    required this.textAlign,
  });

  final int index;
  final Alignment alignment;
  final TextAlign textAlign;
}

class ToramRadarProfile {
  const ToramRadarProfile._();

  static const String _metricPhysicalAtk = 'physical_atk';
  static const String _metricMagicAtk = 'magic_atk';
  static const String _metricDef = 'def';
  static const String _metricMdef = 'mdef';
  static const String _metricAspd = 'aspd';
  static const String _metricCspd = 'cspd';
  static const String _metricHit = 'hit';
  static const String _metricFlee = 'flee';

  static const List<ToramRadarMetricSpec> metrics = <ToramRadarMetricSpec>[
    // Toram-like combat panel focus: ATK/MATK/DEF/MDEF/HIT/FLEE/ASPD/CSPD.
    ToramRadarMetricSpec(
      id: _metricPhysicalAtk,
      label: 'ATK',
      cap: 6000,
      curve: ToramRadarScaleCurve.sqrt,
    ),
    ToramRadarMetricSpec(
      id: _metricMagicAtk,
      label: 'MATK',
      cap: 6000,
      curve: ToramRadarScaleCurve.sqrt,
    ),
    ToramRadarMetricSpec(
      id: _metricHit,
      label: 'HIT',
      cap: 1000,
      curve: ToramRadarScaleCurve.sqrt,
    ),
    ToramRadarMetricSpec(
      id: _metricFlee,
      label: 'FLEE',
      cap: 1000,
      curve: ToramRadarScaleCurve.sqrt,
    ),
    ToramRadarMetricSpec(
      id: _metricAspd,
      label: 'ASPD',
      cap: 10000,
      curve: ToramRadarScaleCurve.log,
    ),
    ToramRadarMetricSpec(
      id: _metricCspd,
      label: 'CSPD',
      cap: 3000,
      curve: ToramRadarScaleCurve.log,
    ),
    ToramRadarMetricSpec(
      id: _metricDef,
      label: 'DEF',
      cap: 5000,
      curve: ToramRadarScaleCurve.sqrt,
    ),
    ToramRadarMetricSpec(
      id: _metricMdef,
      label: 'MDEF',
      cap: 5000,
      curve: ToramRadarScaleCurve.sqrt,
    ),
  ];

  static double metricValue(Map<String, num> summary, String metricId) {
    switch (metricId) {
      case _metricPhysicalAtk:
        return _summary(summary, 'ATK');
      case _metricMagicAtk:
        return _summary(summary, 'MATK');
      case _metricDef:
        return _summary(summary, 'DEF');
      case _metricMdef:
        return _summary(summary, 'MDEF');
      case _metricAspd:
        return _summary(summary, 'ASPD');
      case _metricCspd:
        return _summary(summary, 'CSPD');
      case _metricHit:
        return _summary(summary, 'Accuracy');
      case _metricFlee:
        return _summary(summary, 'FLEE');
      default:
        return 0;
    }
  }

  static double normalizedValue({
    required Map<String, num> summary,
    required ToramRadarMetricSpec metric,
  }) {
    final double raw = metricValue(summary, metric.id);
    return normalizedFromRaw(raw: raw, metric: metric);
  }

  static double normalizedFromRaw({
    required double raw,
    required ToramRadarMetricSpec metric,
  }) {
    final double safeRaw = raw < 0 ? 0 : raw;
    if (metric.cap <= 0) {
      return 0;
    }
    final double ratio = (safeRaw / metric.cap).clamp(0.0, 1.0);
    return normalizeRatio(ratio: ratio, curve: metric.curve);
  }

  static double normalizeRatio({
    required double ratio,
    required ToramRadarScaleCurve curve,
  }) {
    final double safeRatio = ratio.clamp(0.0, 1.0);
    switch (curve) {
      case ToramRadarScaleCurve.linear:
        return safeRatio;
      case ToramRadarScaleCurve.sqrt:
        return math.sqrt(safeRatio);
      case ToramRadarScaleCurve.log:
        // Map [0,1] to [0,1] with stronger lift for low-mid values.
        return math.log(1 + (safeRatio * 9)) / math.log(10);
    }
  }

  static List<ToramRadarLabelAnchor> buildLabelAnchors({
    required int axisCount,
    double radius = 0.98,
    double minVerticalGap = 0.18,
  }) {
    if (axisCount <= 0) {
      return const <ToramRadarLabelAnchor>[];
    }

    final List<_AnchorNode> nodes = List<_AnchorNode>.generate(axisCount, (
      int index,
    ) {
      final double angle = -math.pi / 2 + (2 * math.pi * index / axisCount);
      final double x = math.cos(angle) * radius;
      final double y = math.sin(angle) * radius;
      final int side = x > 0.25
          ? 1
          : x < -0.25
          ? -1
          : 0;
      return _AnchorNode(index: index, x: x, y: y, side: side);
    });

    _resolveVerticalCollisions(nodes, side: -1, minGap: minVerticalGap);
    _resolveVerticalCollisions(nodes, side: 0, minGap: minVerticalGap);
    _resolveVerticalCollisions(nodes, side: 1, minGap: minVerticalGap);

    return nodes
        .map((node) {
          final double displayX = node.side > 0
              ? math.max(node.x, 0.86)
              : node.side < 0
              ? math.min(node.x, -0.86)
              : node.x;
          final TextAlign align = node.side > 0
              ? TextAlign.left
              : node.side < 0
              ? TextAlign.right
              : TextAlign.center;
          return ToramRadarLabelAnchor(
            index: node.index,
            alignment: Alignment(displayX, node.adjustedY),
            textAlign: align,
          );
        })
        .toList(growable: false);
  }

  static String formatValue(double value) {
    if (value.abs() >= 1000) {
      final double kilo = value / 1000;
      final String text = kilo.abs() >= 10
          ? kilo.toStringAsFixed(0)
          : kilo.toStringAsFixed(1);
      return '${text}k';
    }
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  static double _summary(Map<String, num> summary, String key) {
    return (summary[key] ?? 0).toDouble();
  }

  static void _resolveVerticalCollisions(
    List<_AnchorNode> nodes, {
    required int side,
    required double minGap,
  }) {
    final List<_AnchorNode> bucket = nodes
        .where((node) => node.side == side)
        .toList(growable: false)
      ..sort((a, b) => a.adjustedY.compareTo(b.adjustedY));
    if (bucket.length <= 1) {
      return;
    }

    for (int i = 1; i < bucket.length; i++) {
      final double previous = bucket[i - 1].adjustedY;
      final double current = bucket[i].adjustedY;
      if (current - previous < minGap) {
        bucket[i].adjustedY = previous + minGap;
      }
    }
    for (int i = bucket.length - 2; i >= 0; i--) {
      final double next = bucket[i + 1].adjustedY;
      final double current = bucket[i].adjustedY;
      if (next - current < minGap) {
        bucket[i].adjustedY = next - minGap;
      }
    }

    double minY = bucket.first.adjustedY;
    double maxY = bucket.last.adjustedY;
    if (minY < -1.04) {
      final double shift = -1.04 - minY;
      for (final _AnchorNode node in bucket) {
        node.adjustedY += shift;
      }
    }
    minY = bucket.first.adjustedY;
    maxY = bucket.last.adjustedY;
    if (maxY > 1.04) {
      final double shift = maxY - 1.04;
      for (final _AnchorNode node in bucket) {
        node.adjustedY -= shift;
      }
    }

    for (final _AnchorNode node in bucket) {
      node.adjustedY = node.adjustedY.clamp(-1.08, 1.08);
    }
  }
}

class _AnchorNode {
  _AnchorNode({
    required this.index,
    required this.x,
    required this.y,
    required this.side,
  }) : adjustedY = y;

  final int index;
  final double x;
  final double y;
  final int side;
  double adjustedY;
}
