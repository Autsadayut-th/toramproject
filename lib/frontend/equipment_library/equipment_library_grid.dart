part of 'equipment_library_page.dart';

extension _EquipmentLibraryGrid on _EquipmentLibraryDataViewState {
  Widget _buildItemsGrid({
    required List<EquipmentLibraryItem> pagedItems,
    required int columnCount,
    required int previewLimit,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: pagedItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: widget.pickMode ? 246 : 276,
      ),
      itemBuilder: (BuildContext context, int index) {
        final EquipmentLibraryItem item = pagedItems[index];
        final List<EquipmentStat> previewStats = item.stats
            .take(previewLimit)
            .toList(growable: false);
        return InkWell(
          onTap: () {
            if (widget.pickMode) {
              Navigator.of(context).pop(item);
              return;
            }
            _openDetails(item);
          },
          onLongPress: widget.pickMode ? () => _openDetails(item) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF666666)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4A4A4A),
                              const Color(0xFF3A3A3A),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFF888888)),
                        ),
                        child: Text(
                          item.color.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.key} - ${item.stats.length} stats',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _buildEquipmentImageBox(item, height: 64),
                  if (widget.pickMode)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Tap to select',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      ...previewStats.map((EquipmentStat stat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3A3A3A), Color(0xFF2A2A2A)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF666666)),
                          ),
                          child: Text(
                            '${_titleCase(stat.statKey)} ${_formatStatValue(stat)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                      if (item.stats.length > previewStats.length)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3A3A3A), Color(0xFF2A2A2A)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF666666)),
                          ),
                          child: Text(
                            '+${item.stats.length - previewStats.length} more',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (item.upgradeFrom != null && item.upgradeFrom!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Upgrade from ${item.upgradeFrom}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
