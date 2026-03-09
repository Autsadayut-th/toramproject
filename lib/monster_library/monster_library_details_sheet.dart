part of 'monster_library_page.dart';

extension _MonsterLibraryDetailsSheet on _MonsterLibraryDataViewState {
  void _openDetails(MonsterLibraryItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (BuildContext context, ScrollController controller) {
            final ColorScheme colorScheme = Theme.of(context).colorScheme;
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
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
                  Text(
                    'Lv ${item.level} - ${item.family}',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMonsterImagePlaceholder(height: 160),
                  const SizedBox(height: 14),
                  Divider(color: colorScheme.onSurface.withValues(alpha: 0.2)),
                  const SizedBox(height: 6),
                  _detailRow('Element', item.element),
                  _detailRow('HP', item.hp.toString()),
                  _detailRow('Map', item.mapName),
                  _detailRow('Map Key', item.mapKey),
                  _detailRow('Monster ID', item.id),
                  const SizedBox(height: 10),
                  Text(
                    'Drops',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (item.drops.isEmpty)
                    Text(
                      '-',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.drops
                          .map((String drop) => _pill(text: drop))
                          .toList(growable: false),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
