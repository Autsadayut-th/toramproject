part of 'equipment_library_page.dart';

extension _EquipmentLibraryDetailsSheet on _EquipmentLibraryDataViewState {
  void _openDetails(
    EquipmentLibraryItem item, {
    required String activeCategory,
  }) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<String> elementLabels = _elementLabelsFromStats(item.stats);
    final List<EquipmentStat> detailStats = item.stats.toList(growable: false);
    final Color accentColor = _itemAccentColor(
      item: item,
      activeCategory: activeCategory,
    );
    final Color miniIconBorderColor =
        Color.lerp(
          colorScheme.outline.withValues(alpha: isLight ? 0.74 : 0.52),
          accentColor,
          isLight ? 0.64 : 0.72,
        ) ??
        accentColor.withValues(alpha: isLight ? 0.76 : 0.62);
    final Color miniIconBackgroundColor = accentColor.withValues(
      alpha: isLight ? 0.22 : 0.16,
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (BuildContext context, ScrollController controller) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.name,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: miniIconBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: miniIconBorderColor,
                            width: 1.2,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: colorScheme.onSurface.withValues(
                                alpha: isLight ? 0.08 : 0.12,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: _buildEquipmentVisual(
                          item,
                          iconSize: 18,
                          imagePadding: 4,
                          overrideAssetPath: _itemVisualAssetPath(
                            item: item,
                            activeCategory: activeCategory,
                          ),
                          accentColorOverride: accentColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_itemTypeDisplayLabel(item: item, activeCategory: activeCategory)} - ${item.key}',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.75,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (elementLabels.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(
                          alpha: isLight ? 0.2 : 0.16,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: accentColor.withValues(
                            alpha: isLight ? 0.72 : 0.62,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.bolt_rounded,
                            size: 14,
                            color: accentColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Element: ${elementLabels.join(', ')}',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildEquipmentImageBox(
                    item,
                    height: 160,
                    activeCategory: activeCategory,
                  ),
                  if (item.upgradeFrom != null && item.upgradeFrom!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Upgrade from: ${item.upgradeFrom}',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  if (item.obtainedFrom.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    Divider(
                      color: colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Obtained from',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildObtainedFromRows(item.obtainedFrom),
                  ],
                  const SizedBox(height: 14),
                  Divider(color: colorScheme.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 6),
                  for (final EquipmentStat stat in detailStats)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        _titleCase(stat.statKey),
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      trailing: Text(
                        _formatStatValue(stat),
                        style: TextStyle(
                          color: stat.value >= 0
                              ? colorScheme.primary
                              : colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildObtainedFromRows(List<EquipmentObtainedSource> sources) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    const int previewLimit = 8;
    final List<EquipmentObtainedSource> preview = sources
        .take(previewLimit)
        .toList(growable: false);
    final int remaining = sources.length - preview.length;

    final List<Widget> rows = <Widget>[
      for (final EquipmentObtainedSource source in preview)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                source.source.isEmpty ? 'Unknown source' : source.source,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (source.map.isNotEmpty) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  source.map,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
    ];

    if (remaining > 0) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 6),
          child: Text(
            '+$remaining more sources',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.54),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return rows;
  }
}
