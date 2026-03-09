part of 'skill_tree_widgets.dart';

class _SkillTreeNode extends StatelessWidget {
  const _SkillTreeNode({required this.skill, required this.onTap});

  final SkillEntry skill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String imageAssetPath = skill.imageAssetPath.trim();
    return Tooltip(
      message: '${skill.name} (Lv ${skill.unlockLevel?.toString() ?? '-'})',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: _SkillTreeLayout.nodeDiameter,
          height: _SkillTreeLayout.nodeDiameter,
          padding: const EdgeInsets.all(2.6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.85),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.12),
                blurRadius: 6,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerHigh,
            ),
            child: ClipOval(
              child: imageAssetPath.isEmpty
                  ? Icon(
                      Icons.auto_awesome,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    )
                  : Image.asset(
                      imageAssetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.auto_awesome,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillTreeConnectorPainter extends CustomPainter {
  const _SkillTreeConnectorPainter({
    required this.edges,
    required this.lineColor,
  });

  final List<_SkillTreeEdgeLayout> edges;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint jointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (final _SkillTreeEdgeLayout edge in edges) {
      final Offset from = Offset(
        edge.from.center.dx + _SkillTreeLayout.nodeRadius - 1,
        edge.from.center.dy,
      );
      final Offset to = Offset(
        edge.to.center.dx - _SkillTreeLayout.nodeRadius + 1,
        edge.to.center.dy,
      );
      final double midX = edge.bendX ?? (from.dx + to.dx) / 2;

      final Path path = Path()
        ..moveTo(from.dx, from.dy)
        ..lineTo(midX, from.dy)
        ..lineTo(midX, to.dy)
        ..lineTo(to.dx, to.dy);
      canvas.drawPath(path, linePaint);
      canvas.drawCircle(Offset(midX, from.dy), 2.6, jointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SkillTreeConnectorPainter oldDelegate) {
    return oldDelegate.edges != edges || oldDelegate.lineColor != lineColor;
  }
}
