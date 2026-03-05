part of '../app_shell_page.dart';

enum _DrawerSummaryViewMode { metricList, radarGraph }

class _DrawerRadarMetric {
  const _DrawerRadarMetric({
    required this.label,
    required this.value,
    required this.cap,
  });

  final String label;
  final double value;
  final double cap;
}

class _DrawerSummaryRadarPainter extends CustomPainter {
  const _DrawerSummaryRadarPainter({
    required this.normalizedValues,
    required this.gridColor,
    required this.axisColor,
    required this.fillColor,
    required this.strokeColor,
  });

  final List<double> normalizedValues;
  final Color gridColor;
  final Color axisColor;
  final Color fillColor;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (normalizedValues.length < 3) {
      return;
    }

    final Offset center = size.center(Offset.zero);
    final double radius = math.min(size.width, size.height) / 2 - 10;
    final int axisCount = normalizedValues.length;

    final List<Offset> outerPoints = List<Offset>.generate(axisCount, (int i) {
      final double angle = -math.pi / 2 + (2 * math.pi * i / axisCount);
      return Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
    });

    final Paint gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final Paint axisPaint = Paint()
      ..color = axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int level = 1; level <= 4; level++) {
      final double t = level / 4;
      final Path path = Path();
      for (int i = 0; i < axisCount; i++) {
        final Offset p = Offset.lerp(center, outerPoints[i], t)!;
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (final Offset p in outerPoints) {
      canvas.drawLine(center, p, axisPaint);
    }

    final List<Offset> points = List<Offset>.generate(axisCount, (int i) {
      final double value = normalizedValues[i].clamp(0.0, 1.0);
      return Offset.lerp(center, outerPoints[i], value)!;
    });

    final Path areaPath = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        areaPath.moveTo(points[i].dx, points[i].dy);
      } else {
        areaPath.lineTo(points[i].dx, points[i].dy);
      }
    }
    areaPath.close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      areaPath,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _DrawerSummaryRadarPainter oldDelegate) {
    if (oldDelegate.gridColor != gridColor ||
        oldDelegate.axisColor != axisColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.normalizedValues.length != normalizedValues.length) {
      return true;
    }
    for (int i = 0; i < normalizedValues.length; i++) {
      if (oldDelegate.normalizedValues[i] != normalizedValues[i]) {
        return true;
      }
    }
    return false;
  }
}
