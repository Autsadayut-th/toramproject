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
                  Text(
                    '${_titleCase(item.type)} - ${item.key}',
                    style: const TextStyle(color: Colors.white70),
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
}
