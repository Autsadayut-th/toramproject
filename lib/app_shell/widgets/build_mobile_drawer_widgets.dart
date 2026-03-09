part of '../app_shell_page.dart';

class _DrawerSectionCard extends StatelessWidget {
  const _DrawerSectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                icon,
                color: colorScheme.onSurface.withValues(alpha: 0.75),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.index, required this.message});

  final int index;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$index.',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.75),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedBuildTile extends StatelessWidget {
  const _SavedBuildTile({
    required this.name,
    required this.codeLine,
    required this.savedAtLine,
    required this.onTap,
    required this.onLoad,
    required this.onDelete,
    required this.onShare,
  });

  final String name;
  final String codeLine;
  final String savedAtLine;
  final VoidCallback? onTap;
  final VoidCallback? onLoad;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(minHeight: 120),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: <Widget>[
                _SavedBuildActionText(
                  label: 'Load',
                  onTap: onLoad,
                  color: colorScheme.onSurface,
                ),
                _SavedBuildActionText(
                  label: 'Export Code',
                  onTap: onShare,
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
                _SavedBuildActionText(
                  label: 'X',
                  onTap: onDelete,
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    codeLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.65),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    savedAtLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.54),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedBuildActionText extends StatelessWidget {
  const _SavedBuildActionText({
    required this.label,
    required this.onTap,
    required this.color,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isEnabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          constraints: const BoxConstraints(minHeight: 36),
          decoration: BoxDecoration(
            color: isEnabled
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: isEnabled
                  ? colorScheme.onSurface.withValues(alpha: 0.35)
                  : colorScheme.onSurface.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isEnabled
                  ? color
                  : colorScheme.onSurface.withValues(alpha: 0.24),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsCategoryBlock extends StatelessWidget {
  const _StatsCategoryBlock({
    required this.title,
    required this.rows,
    required this.summary,
    required this.percentKeys,
  });

  final String title;
  final List<MapEntry<String, String>> rows;
  final Map<String, num> summary;
  final Set<String> percentKeys;

  String _displayValue(String key) {
    final num value = summary[key] ?? 0;
    if (percentKeys.contains(key)) {
      return '${value.toInt()}%';
    }
    return value.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...rows.map((MapEntry<String, String> row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      row.value,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    _displayValue(row.key),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
