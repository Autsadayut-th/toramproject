part of 'monster_library_page.dart';

class _MonsterLibraryDataView extends StatefulWidget {
  const _MonsterLibraryDataView();

  @override
  State<_MonsterLibraryDataView> createState() => _MonsterLibraryDataViewState();
}

class _MonsterLibraryDataViewState extends State<_MonsterLibraryDataView> {
  static const int _itemsPerPage = 27;

  final MonsterLibraryRepository _repository = MonsterLibraryRepository();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<MonsterLibraryItem>> _libraryFuture;
  String _selectedFamily = 'All';
  String _searchQuery = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _libraryFuture = _repository.loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _libraryFuture = _repository.loadAll();
      _currentPage = 1;
    });
  }

  void _setLibraryState(VoidCallback action) {
    setState(action);
  }

  Future<void> _openFamilyDialog({
    required List<String> families,
    required String activeFamily,
    required List<MonsterLibraryItem> allItems,
  }) async {
    if (families.isEmpty) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF101010),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760, maxHeight: 600),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: Text(
                              'Select Family',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close, color: Colors.white70),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: families.map((String family) {
                          final int count = family == 'All'
                              ? allItems.length
                              : allItems
                                    .where(
                                      (MonsterLibraryItem item) =>
                                          item.family == family,
                                    )
                                    .length;
                          return ChoiceChip(
                            selectedColor: const Color(0xFF202020),
                            backgroundColor: const Color(0xFF101010),
                            side: const BorderSide(color: Color(0x44FFFFFF)),
                            labelStyle: const TextStyle(color: Colors.white),
                            label: Text('$family ($count)'),
                            selected: activeFamily == family,
                            onSelected: (_) {
                              setState(() {
                                _selectedFamily = family;
                                _currentPage = 1;
                              });
                              Navigator.of(dialogContext).pop();
                            },
                          );
                        }).toList(growable: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MonsterLibraryItem>>(
      future: _libraryFuture,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<MonsterLibraryItem>> snapshot,
      ) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Failed to load monster data.',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final List<MonsterLibraryItem> allItems =
            snapshot.data ?? const <MonsterLibraryItem>[];
        final List<String> families = _repository.familiesFrom(allItems);
        final String activeFamily = families.contains(_selectedFamily)
            ? _selectedFamily
            : 'All';
        final String query = _searchQuery.trim().toLowerCase();
        final List<MonsterLibraryItem> filteredItems = allItems
            .where((MonsterLibraryItem item) {
              if (activeFamily != 'All' && item.family != activeFamily) {
                return false;
              }
              if (query.isEmpty) {
                return true;
              }
              final String haystack =
                  '${item.name} ${item.id} ${item.element} ${item.family} ${item.mapName}'
                      .toLowerCase();
              return haystack.contains(query);
            })
            .toList(growable: false);

        final int totalPages = filteredItems.isEmpty
            ? 1
            : ((filteredItems.length + _itemsPerPage - 1) / _itemsPerPage)
                  .floor();
        final int currentPage = _currentPage.clamp(1, totalPages);
        final int startIndex = filteredItems.isEmpty
            ? 0
            : (currentPage - 1) * _itemsPerPage;
        final int endIndex = filteredItems.isEmpty
            ? 0
            : (startIndex + _itemsPerPage > filteredItems.length
                  ? filteredItems.length
                  : startIndex + _itemsPerPage);
        final List<MonsterLibraryItem> pagedItems = filteredItems.isEmpty
            ? const <MonsterLibraryItem>[]
            : filteredItems.sublist(startIndex, endIndex);

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white70,
                      decoration: InputDecoration(
                        hintText: 'Search by name, id, family, map, element...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0F0F0F),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0x33FFFFFF)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0x33FFFFFF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0x66FFFFFF)),
                        ),
                      ),
                      onChanged: (String value) {
                        setState(() {
                          _searchQuery = value;
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                  if (families.isNotEmpty) ...<Widget>[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: Tooltip(
                        message: 'Family: $activeFamily',
                        child: OutlinedButton(
                          onPressed: () {
                            _openFamilyDialog(
                              families: families,
                              activeFamily: activeFamily,
                              allItems: allItems,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Color(0x33FFFFFF)),
                            backgroundColor: const Color(0xFF0F0F0F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Icon(Icons.tune, size: 18),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No monsters found.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (
                        BuildContext context,
                        BoxConstraints constraints,
                      ) {
                        final double width = constraints.maxWidth;
                        final int columnCount = width >= 960
                            ? 3
                            : width >= 620
                            ? 2
                            : 1;
                        return _buildItemsGrid(
                          pagedItems: pagedItems,
                          columnCount: columnCount,
                        );
                      },
                    ),
            ),
            if (filteredItems.isNotEmpty)
              _buildPaginationBar(
                currentPage: currentPage,
                totalPages: totalPages,
              ),
          ],
        );
      },
    );
  }
}
