part of 'map_library_page.dart';

extension _MapLibraryGrid on _MapLibraryDataViewState {
  Widget _buildItemsGrid({
    required List<MapLibraryItem> pagedItems,
    required int columnCount,
    required MapLibraryData data,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: pagedItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 278,
      ),
      itemBuilder: (BuildContext context, int index) {
        final MapLibraryItem item = pagedItems[index];
        final List<MapMonsterInfo> monsters = item.monsterIds
            .map((String id) => data.monsterById[id])
            .whereType<MapMonsterInfo>()
            .toList(growable: false);
        final List<MapMonsterInfo> previewMonsters = monsters
            .take(2)
            .toList(growable: false);

        return InkWell(
          onTap: () => _openDetails(item, monsters),
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
                      _pill(text: item.region),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _buildMapImagePlaceholder(height: 64),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      _pill(
                        text:
                            'Lv ${item.recommendedLevelMin}-${item.recommendedLevelMax}',
                      ),
                      _pill(text: 'Monsters ${monsters.length}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (previewMonsters.isEmpty)
                    const Text(
                      '-',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    )
                  else
                    Text(
                      'Targets: ${previewMonsters.map((MapMonsterInfo monster) => monster.name).join(', ')}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  if (monsters.length > previewMonsters.length)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '+${monsters.length - previewMonsters.length} more monsters',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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

  Widget _pill({required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A3A3A), Color(0xFF2A2A2A)],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF666666)),
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

  Widget _buildMapImagePlaceholder({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF666666)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.map_outlined, color: Colors.white38, size: 24),
          SizedBox(height: 4),
          Text('Map', style: TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}
