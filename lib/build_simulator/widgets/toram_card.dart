import 'package:flutter/material.dart';

class ToramCard extends StatelessWidget {
  const ToramCard({
    required this.title,
    required this.icon,
    required this.child,
    this.titleColor,
    super.key,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;
    final double borderAlpha = isLight ? 0.24 : 0.16;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: borderAlpha),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(
              alpha: isLight ? 0.10 : 0.16,
            ),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: colorScheme.onSurface, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: titleColor ?? colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
