import 'package:flutter/material.dart';

class SaveBuildEntry {
  const SaveBuildEntry({
    required this.name,
    required this.codeLine,
    required this.savedAtLine,
    this.onTap,
    this.onLoad,
    this.onDelete,
    this.onShare,
  });

  final String name;
  final String codeLine;
  final String savedAtLine;
  final VoidCallback? onTap;
  final VoidCallback? onLoad;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
}

class SaveLoadBuildContent extends StatelessWidget {
  const SaveLoadBuildContent({
    super.key,
    required this.hasSaveLimit,
    required this.canSaveBuild,
    required this.saveLimitMessage,
    required this.buildNameController,
    required this.onSaveBuild,
    required this.onImportCode,
    required this.savedBuilds,
    this.maxVisibleSavedBuilds = 5,
  });

  final bool hasSaveLimit;
  final bool canSaveBuild;
  final String saveLimitMessage;
  final TextEditingController buildNameController;
  final VoidCallback onSaveBuild;
  final VoidCallback onImportCode;
  final List<SaveBuildEntry> savedBuilds;
  final int maxVisibleSavedBuilds;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final int visibleSavedBuildCount =
        savedBuilds.length > maxVisibleSavedBuilds
        ? maxVisibleSavedBuilds
        : savedBuilds.length;
    final List<SaveBuildEntry> visibleSavedBuilds = savedBuilds
        .take(visibleSavedBuildCount)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (hasSaveLimit) ...<Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              saveLimitMessage,
              style: TextStyle(
                color: canSaveBuild
                    ? colorScheme.onSurface.withValues(alpha: 0.75)
                    : colorScheme.error,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: buildNameController,
          onSubmitted: (_) => onSaveBuild(),
          style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Enter build name...',
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.54),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.24),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canSaveBuild ? onSaveBuild : null,
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Save Build'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(
                    color: colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onImportCode,
                icon: const Icon(Icons.download_for_offline, size: 16),
                label: const Text('Import Code'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurface.withValues(
                    alpha: 0.75,
                  ),
                  side: BorderSide(
                    color: colorScheme.onSurface.withValues(alpha: 0.24),
                  ),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (visibleSavedBuilds.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.24),
              ),
            ),
            child: Text(
              'No saved builds yet.',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.75),
                fontSize: 12,
              ),
            ),
          )
        else
          Column(
            children: visibleSavedBuilds
                .map((SaveBuildEntry build) {
                  return _SavedBuildTile(
                    name: build.name,
                    codeLine: build.codeLine,
                    savedAtLine: build.savedAtLine,
                    onTap: build.onTap,
                    onLoad: build.onLoad,
                    onDelete: build.onDelete,
                    onShare: build.onShare,
                  );
                })
                .toList(growable: false),
          ),
        if (savedBuilds.length > visibleSavedBuildCount)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Showing first $maxVisibleSavedBuilds builds.',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.54),
                fontSize: 11,
              ),
            ),
          ),
      ],
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
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.24),
          ),
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
