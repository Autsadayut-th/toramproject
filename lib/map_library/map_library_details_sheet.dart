part of 'map_library_page.dart';

extension _MapLibraryDetailsSheet on _MapLibraryDataViewState {
  void _openDetails(MapLibraryItem item, List<MapMonsterInfo> monsters) {
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
                    item.region,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  _buildMapImagePlaceholder(height: 160),
                  const SizedBox(height: 14),
                  const Divider(color: Color(0x33FFFFFF)),
                  const SizedBox(height: 6),
                  _detailRow('Map Key', item.key),
                  _detailRow('Region', item.region),
                  _detailRow(
                    'Recommended Lv',
                    '${item.recommendedLevelMin}-${item.recommendedLevelMax}',
                  ),
                  _detailRow('Monster Count', monsters.length.toString()),
                  const SizedBox(height: 10),
                  const Text(
                    'Monsters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (monsters.isEmpty)
                    const Text('-', style: TextStyle(color: Colors.white54))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: monsters
                          .map((MapMonsterInfo monster) {
                            return _pill(
                              text: '${monster.name} (Lv ${monster.level})',
                            );
                          })
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
