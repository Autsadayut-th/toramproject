part of '../compare_builds_page.dart';

extension _CompareBuildsRadarSection on _CompareBuildsPageState {
  Widget _buildCompareRadarCard({
    required Map<String, dynamic>? firstBuild,
    required Map<String, dynamic>? secondBuild,
  }) {
    final List<double> firstValues = _CompareBuildsPageState._radarMetrics
        .map(
          (MapEntry<String, String> metric) =>
              _summaryValue(firstBuild, metric.key).toDouble(),
        )
        .toList(growable: false);
    final List<double> secondValues = _CompareBuildsPageState._radarMetrics
        .map(
          (MapEntry<String, String> metric) =>
              _summaryValue(secondBuild, metric.key).toDouble(),
        )
        .toList(growable: false);

    final List<double> firstNormalized = List<double>.generate(
      _CompareBuildsPageState._radarMetrics.length,
      (int index) => _normalizeRadar(
        key: _CompareBuildsPageState._radarMetrics[index].key,
        left: firstValues[index],
        right: secondValues[index],
        current: firstValues[index],
      ),
      growable: false,
    );
    final List<double> secondNormalized = List<double>.generate(
      _CompareBuildsPageState._radarMetrics.length,
      (int index) => _normalizeRadar(
        key: _CompareBuildsPageState._radarMetrics[index].key,
        left: firstValues[index],
        right: secondValues[index],
        current: secondValues[index],
      ),
      growable: false,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Build Compare Graph',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: CustomPaint(
                      painter: _CompareRadarPainter(
                        firstValues: firstNormalized,
                        secondValues: secondNormalized,
                        gridColor: const Color(0x66FFFFFF),
                        axisColor: const Color(0x33FFFFFF),
                        firstFillColor: const Color(0x6678A8FF),
                        firstStrokeColor: const Color(0xFFB8D2FF),
                        secondFillColor: const Color(0x66FF8A80),
                        secondStrokeColor: const Color(0xFFFFC5C0),
                      ),
                    ),
                  ),
                ),
                _buildRadarLabel(
                  alignment: const Alignment(0, -0.96),
                  label: _CompareBuildsPageState._radarMetrics[0].value,
                  left: firstValues[0],
                  right: secondValues[0],
                ),
                _buildRadarLabel(
                  alignment: const Alignment(0.9, -0.5),
                  label: _CompareBuildsPageState._radarMetrics[1].value,
                  left: firstValues[1],
                  right: secondValues[1],
                  textAlign: TextAlign.left,
                ),
                _buildRadarLabel(
                  alignment: const Alignment(0.9, 0.5),
                  label: _CompareBuildsPageState._radarMetrics[2].value,
                  left: firstValues[2],
                  right: secondValues[2],
                  textAlign: TextAlign.left,
                ),
                _buildRadarLabel(
                  alignment: const Alignment(0, 0.96),
                  label: _CompareBuildsPageState._radarMetrics[3].value,
                  left: firstValues[3],
                  right: secondValues[3],
                ),
                _buildRadarLabel(
                  alignment: const Alignment(-0.9, 0.5),
                  label: _CompareBuildsPageState._radarMetrics[4].value,
                  left: firstValues[4],
                  right: secondValues[4],
                  textAlign: TextAlign.right,
                ),
                _buildRadarLabel(
                  alignment: const Alignment(-0.9, -0.5),
                  label: _CompareBuildsPageState._radarMetrics[5].value,
                  left: firstValues[5],
                  right: secondValues[5],
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _buildLegendDot(
                color: const Color(0xFFB8D2FF),
                text: 'Build A',
              ),
              _buildLegendDot(
                color: const Color(0xFFFFC5C0),
                text: 'Build B',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot({required Color color, required String text}) {
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
          style: const TextStyle(color: Colors.white70, fontSize: 12),
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
  }) {
    final CrossAxisAlignment axisAlignment = textAlign == TextAlign.left
        ? CrossAxisAlignment.start
        : textAlign == TextAlign.right
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.center;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: 124,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: axisAlignment,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFFFE082),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: textAlign,
            ),
            Text(
              '${_numberText(left)} / ${_numberText(right)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
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
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  double _normalizeRadar({
    required String key,
    required double left,
    required double right,
    required double current,
  }) {
    final double cap = _CompareBuildsPageState._radarCaps[key] ?? 1;
    final double maxRef = math.max(cap, math.max(left.abs(), right.abs()));
    if (maxRef <= 0) {
      return 0;
    }
    return (current / maxRef).clamp(0.0, 1.0);
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
