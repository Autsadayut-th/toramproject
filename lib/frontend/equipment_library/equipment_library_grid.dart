part of 'equipment_library_page.dart';

extension _EquipmentLibraryGrid on _EquipmentLibraryDataViewState {
  Widget _buildItemsGrid({
    required List<EquipmentLibraryItem> pagedItems,
    required int columnCount,
    required int previewLimit,
  }) {
    if (columnCount == 1) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: pagedItems.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          return _buildGridCard(
            context: context,
            item: pagedItems[index],
            previewLimit: previewLimit,
          );
        },
      );
    }

    final List<List<EquipmentLibraryItem?>> rows =
        <List<EquipmentLibraryItem?>>[];
    for (int index = 0; index < pagedItems.length; index += columnCount) {
      final List<EquipmentLibraryItem?> rowItems = pagedItems
          .skip(index)
          .take(columnCount)
          .cast<EquipmentLibraryItem?>()
          .toList(growable: true);
      while (rowItems.length < columnCount) {
        rowItems.add(null);
      }
      rows.add(rowItems);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: rows.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final List<EquipmentLibraryItem?> rowItems = rows[index];
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (
                int itemIndex = 0;
                itemIndex < rowItems.length;
                itemIndex++
              ) ...<Widget>[
                Expanded(
                  child: rowItems[itemIndex] == null
                      ? const SizedBox.shrink()
                      : _buildGridCard(
                          context: context,
                          item: rowItems[itemIndex]!,
                          previewLimit: previewLimit,
                        ),
                ),
                if (itemIndex < rowItems.length - 1) const SizedBox(width: 10),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridCard({
    required BuildContext context,
    required EquipmentLibraryItem item,
    required int previewLimit,
  }) {
    final List<EquipmentStat> previewStats = item.stats
        .take(previewLimit)
        .toList(growable: false);
    final Color accentColor = _equipmentTypeAccentColor(item.type);
    final String actionLabel = widget.pickMode
        ? 'Tap to equip'
        : 'Open details';

    return InkWell(
      onTap: () {
        if (widget.pickMode) {
          Navigator.of(context).pop(item);
          return;
        }
        _openDetails(item);
      },
      onLongPress: widget.pickMode ? () => _openDetails(item) : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF17191C), Color(0xFF0C0E11)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accentColor.withValues(alpha: 0.22)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.32),
                          ),
                        ),
                        child: _buildEquipmentVisual(
                          item,
                          iconSize: 22,
                          imagePadding: 8,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _titleCase(item.type),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _buildMetaPill(
                        text: '${item.stats.length} tracked',
                        borderColor: accentColor.withValues(alpha: 0.24),
                        backgroundColor: accentColor.withValues(alpha: 0.08),
                      ),
                      if (item.upgradeFrom != null &&
                          item.upgradeFrom!.isNotEmpty)
                        _buildMetaPill(
                          text: 'Upgradeable',
                          borderColor: _libraryCoolAccent.withValues(
                            alpha: 0.24,
                          ),
                          backgroundColor: _libraryCoolAccent.withValues(
                            alpha: 0.08,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (previewStats.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        ...previewStats.map((EquipmentStat stat) {
                          return _buildStatChip(
                            text:
                                '${_titleCase(stat.statKey)} ${_formatStatValue(stat)}',
                            accentColor: accentColor,
                          );
                        }),
                        if (item.stats.length > previewStats.length)
                          _buildStatChip(
                            text:
                                '+${item.stats.length - previewStats.length} more',
                            accentColor: _libraryWarmAccent,
                          ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1418),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _libraryCoolAccent.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            actionLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '>',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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

  Widget _buildMetaPill({
    required String text,
    required Color borderColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStatChip({required String text, required Color accentColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            accentColor.withValues(alpha: 0.14),
            const Color(0xFF161A1E),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.24)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
