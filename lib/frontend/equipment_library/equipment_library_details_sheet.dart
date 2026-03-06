part of 'equipment_library_page.dart';

extension _EquipmentLibraryDetailsSheet on _EquipmentLibraryDataViewState {
  void _openDetails(EquipmentLibraryItem item) {
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
              decoration: const BoxDecoration(
                color: Color(0xFF090909),
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
                        color: const Color(0x55FFFFFF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _equipmentTypeAccentColor(
                            item.type,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _equipmentTypeAccentColor(
                              item.type,
                            ).withValues(alpha: 0.28),
                          ),
                        ),
                        child: _buildEquipmentVisual(
                          item,
                          iconSize: 16,
                          imagePadding: 4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_titleCase(item.type)} - ${item.key}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildEquipmentImageBox(item, height: 160),
                  if (item.upgradeFrom != null && item.upgradeFrom!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Upgrade from: ${item.upgradeFrom}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  if (item.obtainedFrom.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    const Divider(color: Color(0x33FFFFFF)),
                    const SizedBox(height: 8),
                    const Text(
                      'Obtained from',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildObtainedFromRows(item.obtainedFrom),
                  ],
                  const SizedBox(height: 14),
                  const Divider(color: Color(0x33FFFFFF)),
                  const SizedBox(height: 6),
                  for (final EquipmentStat stat in item.stats)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        _titleCase(stat.statKey),
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        _formatStatValue(stat),
                        style: TextStyle(
                          color: stat.value >= 0
                              ? const Color(0xFF88F7A1)
                              : const Color(0xFFFF9090),
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
            color: const Color(0xFF11161A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                source.source.isEmpty ? 'Unknown source' : source.source,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (source.map.isNotEmpty) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  source.map,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
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
            style: const TextStyle(
              color: Colors.white54,
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
