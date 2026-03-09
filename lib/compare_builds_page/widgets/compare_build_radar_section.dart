part of '../compare_builds_page.dart';

extension _CompareBuildsRadarSection on _CompareBuildsPageState {
  Widget _buildCompareRadarCard({
    required Map<String, dynamic>? firstBuild,
    required Map<String, dynamic>? secondBuild,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Map<String, num> firstSummary = _summaryMap(firstBuild);
    final Map<String, num> secondSummary = _summaryMap(secondBuild);
    final List<ToramRadarMetricSpec> metrics = ToramRadarProfile.metrics;
    final List<double> firstValues = metrics
        .map(
          (ToramRadarMetricSpec metric) =>
              ToramRadarProfile.metricValue(firstSummary, metric.id),
        )
        .toList(growable: false);
    final List<double> secondValues = metrics
        .map(
          (ToramRadarMetricSpec metric) =>
              ToramRadarProfile.metricValue(secondSummary, metric.id),
        )
        .toList(growable: false);

    final List<double> firstNormalized = List<double>.generate(
      metrics.length,
      (int index) => _normalizeRadar(
        metric: metrics[index],
        left: firstValues[index],
        right: secondValues[index],
        current: firstValues[index],
      ),
      growable: false,
    );
    final List<double> secondNormalized = List<double>.generate(
      metrics.length,
      (int index) => _normalizeRadar(
        metric: metrics[index],
        left: firstValues[index],
        right: secondValues[index],
        current: secondValues[index],
      ),
      growable: false,
    );
    final List<ToramRadarLabelAnchor> anchors = ToramRadarProfile.buildLabelAnchors(
      axisCount: metrics.length,
      radius: 1,
      minVerticalGap: 0.24,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Build Compare Graph',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 380,
            child: Stack(
              children: [
                Align(
                  alignment: const Alignment(0, -0.04),
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: CustomPaint(
                      painter: _CompareRadarPainter(
                        firstValues: firstNormalized,
                        secondValues: secondNormalized,
                        gridColor: colorScheme.onSurface.withValues(alpha: 0.4),
                        axisColor: colorScheme.onSurface.withValues(alpha: 0.2),
                        firstFillColor: colorScheme.primary.withValues(
                          alpha: 0.34,
                        ),
                        firstStrokeColor: colorScheme.primary,
                        secondFillColor: colorScheme.secondary.withValues(
                          alpha: 0.34,
                        ),
                        secondStrokeColor: colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                ...List<Widget>.generate(metrics.length, (int index) {
                  final ToramRadarMetricSpec metric = metrics[index];
                  final ToramRadarLabelAnchor anchor = anchors[index];
                  final double width = anchor.textAlign == TextAlign.center
                      ? 80
                      : 96;
                  return _buildRadarLabel(
                    alignment: anchor.alignment,
                    label: metric.label,
                    left: firstValues[index],
                    right: secondValues[index],
                    textAlign: anchor.textAlign,
                    maxWidth: width,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _buildLegendDot(
                color: colorScheme.primary,
                text: 'Build A',
              ),
              _buildLegendDot(
                color: colorScheme.secondary,
                text: 'Build B',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot({required Color color, required String text}) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRadarLabel({
    required Alignment alignment,
    required String label,
    required double left,
    required double right,
    TextAlign textAlign = TextAlign.center,
    double maxWidth = 124,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final CrossAxisAlignment axisAlignment = textAlign == TextAlign.left
        ? CrossAxisAlignment.start
        : textAlign == TextAlign.right
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.center;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: maxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: axisAlignment,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              textAlign: textAlign,
            ),
            Text(
              '${_numberText(left)} / ${_numberText(right)}',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              textAlign: textAlign,
            ),
          ],
        ),
      ),
    );
  }

  String _numberText(double value) {
    return ToramRadarProfile.formatValue(value);
  }

  double _normalizeRadar({
    required ToramRadarMetricSpec metric,
    required double left,
    required double right,
    required double current,
  }) {
    final double maxRef = math.max(metric.cap, math.max(left.abs(), right.abs()));
    if (maxRef <= 0) {
      return 0;
    }
    final double ratio = ((current < 0 ? 0 : current) / maxRef).clamp(0.0, 1.0);
    return ToramRadarProfile.normalizeRatio(
      ratio: ratio,
      curve: metric.curve,
    );
  }
}

class _CompareRadarPainter extends CustomPainter {
  const _CompareRadarPainter({
    required this.firstValues,
    required this.secondValues,
    required this.gridColor,
    required this.axisColor,
    required this.firstFillColor,
    required this.firstStrokeColor,
    required this.secondFillColor,
    required this.secondStrokeColor,
  });

  final List<double> firstValues;
  final List<double> secondValues;
  final Color gridColor;
  final Color axisColor;
  final Color firstFillColor;
  final Color firstStrokeColor;
  final Color secondFillColor;
  final Color secondStrokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (firstValues.length < 3 || secondValues.length != firstValues.length) {
      return;
    }

    final int axisCount = firstValues.length;
    final Offset center = size.center(Offset.zero);
    final double radius = math.min(size.width, size.height) / 2 - 10;

    final List<Offset> outer = List<Offset>.generate(axisCount, (int index) {
      final double angle = -math.pi / 2 + (2 * math.pi * index / axisCount);
      return Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
    });

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final Paint axisPaint = Paint()
      ..color = axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= 4; level++) {
      final double factor = level / 4;
      final Path path = Path();
      for (int i = 0; i < axisCount; i++) {
        final Offset p = Offset.lerp(center, outer[i], factor)!;
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (final Offset p in outer) {
      canvas.drawLine(center, p, axisPaint);
    }

    _drawArea(
      canvas: canvas,
      center: center,
      outerPoints: outer,
      values: firstValues,
      fill: firstFillColor,
      stroke: firstStrokeColor,
    );
    _drawArea(
      canvas: canvas,
      center: center,
      outerPoints: outer,
      values: secondValues,
      fill: secondFillColor,
      stroke: secondStrokeColor,
    );
  }

  void _drawArea({
    required Canvas canvas,
    required Offset center,
    required List<Offset> outerPoints,
    required List<double> values,
    required Color fill,
    required Color stroke,
  }) {
    final List<Offset> points = List<Offset>.generate(outerPoints.length, (
      int index,
    ) {
      final double safeValue = values[index].clamp(0.0, 1.0);
      return Offset.lerp(center, outerPoints[index], safeValue)!;
    });

    final Path path = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(points[i].dx, points[i].dy);
      } else {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final Paint pointPaint = Paint()..color = stroke;
    for (final Offset p in points) {
      canvas.drawCircle(p, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CompareRadarPainter oldDelegate) {
    if (oldDelegate.gridColor != gridColor ||
        oldDelegate.axisColor != axisColor ||
        oldDelegate.firstFillColor != firstFillColor ||
        oldDelegate.firstStrokeColor != firstStrokeColor ||
        oldDelegate.secondFillColor != secondFillColor ||
        oldDelegate.secondStrokeColor != secondStrokeColor ||
        oldDelegate.firstValues.length != firstValues.length ||
        oldDelegate.secondValues.length != secondValues.length) {
      return true;
    }
    for (int i = 0; i < firstValues.length; i++) {
      if (oldDelegate.firstValues[i] != firstValues[i] ||
          oldDelegate.secondValues[i] != secondValues[i]) {
        return true;
      }
    }
    return false;
  }
}
