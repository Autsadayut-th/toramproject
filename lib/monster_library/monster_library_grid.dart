part of 'monster_library_page.dart';

extension _MonsterLibraryGrid on _MonsterLibraryDataViewState {
  Widget _buildItemsGrid({
    required List<MonsterLibraryItem> pagedItems,
    required int columnCount,
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
        final MonsterLibraryItem item = pagedItems[index];
        final List<String> previewDrops = item.drops
            .take(2)
            .toList(growable: false);
        return InkWell(
          onTap: () => _openDetails(item),
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
                      _pill(text: item.element),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.id} - Lv ${item.level}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _buildMonsterImagePlaceholder(height: 64),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      _pill(text: 'HP ${item.hp}'),
                      _pill(text: item.family),
                      _pill(text: item.mapName),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (previewDrops.isEmpty)
                    const Text(
                      '-',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    )
                  else
                    Text(
                      'Drops: ${previewDrops.join(', ')}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  if (item.drops.length > previewDrops.length)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '+${item.drops.length - previewDrops.length} more drops',
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

  Widget _buildMonsterImagePlaceholder({required double height}) {
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
          Icon(Icons.pets_outlined, color: Colors.white38, size: 24),
          SizedBox(height: 4),
          Text(
            'Monster',
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
