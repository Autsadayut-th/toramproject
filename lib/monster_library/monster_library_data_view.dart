part of 'monster_library_page.dart';

class _MonsterLibraryDataView extends StatefulWidget {
  const _MonsterLibraryDataView();

  @override
  State<_MonsterLibraryDataView> createState() =>
      _MonsterLibraryDataViewState();
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
        final ColorScheme colorScheme = Theme.of(dialogContext).colorScheme;
        return Dialog(
          backgroundColor: colorScheme.surfaceContainerHigh,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
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
                          Expanded(
                            child: Text(
                              'Select Family',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: Icon(
                              Icons.close,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.75,
                              ),
                            ),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: families
                            .map((String family) {
                              final int count = family == 'All'
                                  ? allItems.length
                                  : allItems
                                        .where(
                                          (MonsterLibraryItem item) =>
                                              item.family == family,
                                        )
                                        .length;
                              return ChoiceChip(
                                selectedColor: colorScheme.primaryContainer,
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                                side: BorderSide(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.26,
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color: colorScheme.onSurface,
                                ),
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
                            })
                            .toList(growable: false),
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<MonsterLibraryItem>>(
      future: _libraryFuture,
      builder:
          (
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
                      Text(
                        'Failed to load monster data.',
                        style: TextStyle(color: colorScheme.onSurface),
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
                          style: TextStyle(color: colorScheme.onSurface),
                          cursorColor: colorScheme.onSurface.withValues(
                            alpha: 0.75,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Search by name, id, family, map, element...',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.54,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.75,
                              ),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.45,
                                ),
                              ),
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
                                foregroundColor: colorScheme.onSurface
                                    .withValues(alpha: 0.75),
                                side: BorderSide(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
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
                      ? Center(
                          child: Text(
                            'No monsters found.',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.75,
                              ),
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder:
                              (
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
