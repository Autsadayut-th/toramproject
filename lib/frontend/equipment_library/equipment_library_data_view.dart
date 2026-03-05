part of 'equipment_library_page.dart';

class _EquipmentLibraryDataView extends StatefulWidget {
  const _EquipmentLibraryDataView({
    required this.pickMode,
    required this.initialCategory,
    required this.allowedCategories,
    required this.allowedTypes,
  });

  final bool pickMode;
  final String? initialCategory;
  final List<String>? allowedCategories;
  final List<String>? allowedTypes;

  @override
  State<_EquipmentLibraryDataView> createState() =>
      _EquipmentLibraryDataViewState();
}

class _EquipmentLibraryDataViewState extends State<_EquipmentLibraryDataView> {
  static const int _itemsPerPage = 27;

  final EquipmentLibraryRepository _repository = EquipmentLibraryRepository();
  final TextEditingController _searchController = TextEditingController();

  late Future<Map<String, List<EquipmentLibraryItem>>> _libraryFuture;
  String? _selectedCategory;
  String _searchQuery = '';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _libraryFuture = _repository.loadAllCategories();
  }

  @override
  void didUpdateWidget(covariant _EquipmentLibraryDataView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool initialCategoryChanged =
        oldWidget.initialCategory != widget.initialCategory;
    final bool allowedCategoriesChanged =
        !_isSameCategoryList(oldWidget.allowedCategories, widget.allowedCategories);
    final bool allowedTypesChanged =
        !_isSameCategoryList(oldWidget.allowedTypes, widget.allowedTypes);
    if (!initialCategoryChanged &&
        !allowedCategoriesChanged &&
        !allowedTypesChanged) {
      return;
    }
    setState(() {
      _selectedCategory = widget.initialCategory;
      _currentPage = 1;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isSameCategoryList(List<String>? a, List<String>? b) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return a == b;
    }
    if (a.length != b.length) {
      return false;
    }
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }

  void _reload() {
    setState(() {
      _libraryFuture = _repository.loadAllCategories();
      _currentPage = 1;
    });
  }

  void _setCurrentPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _openCategoryDialog({
    required List<String> categories,
    required Map<String, List<EquipmentLibraryItem>> allCategories,
    required String activeCategory,
  }) async {
    if (categories.isEmpty) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF101010),
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
                          const Expanded(
                            child: Text(
                              'Select Category',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories
                            .map((String category) {
                              return ChoiceChip(
                                selectedColor: const Color(0xFF202020),
                                backgroundColor: const Color(0xFF101010),
                                side: const BorderSide(
                                  color: Color(0x44FFFFFF),
                                ),
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                                label: Text(
                                  '$category (${allCategories[category]?.length ?? 0})',
                                ),
                                selected: activeCategory == category,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedCategory = category;
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
    return FutureBuilder<Map<String, List<EquipmentLibraryItem>>>(
      future: _libraryFuture,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<Map<String, List<EquipmentLibraryItem>>> snapshot,
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
                        'Failed to load equipment data.',
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

            final Map<String, List<EquipmentLibraryItem>> allCategories =
                snapshot.data ?? <String, List<EquipmentLibraryItem>>{};
            final List<String> categories =
                EquipmentLibraryQueryService.availableCategories(
                  repositoryCategories: _repository.categories,
                  allCategories: allCategories,
                  allowedCategories: widget.allowedCategories?.toSet(),
                );
            final String activeCategory =
                EquipmentLibraryQueryService.resolveActiveCategory(
                  selectedCategory: _selectedCategory,
                  categories: categories,
                );
            final List<EquipmentLibraryItem> allItems =
                allCategories[activeCategory] ?? const <EquipmentLibraryItem>[];
            final List<EquipmentLibraryItem> filteredItems =
                EquipmentLibraryQueryService.filterItems(
                  items: allItems,
                  query: _searchQuery,
                  allowedTypes: widget.allowedTypes?.toSet(),
                );
            final EquipmentLibraryPageSlice pagedResult =
                EquipmentLibraryQueryService.paginateItems(
                  filteredItems: filteredItems,
                  currentPage: _currentPage,
                  itemsPerPage: _itemsPerPage,
                );

            return Column(
              children: <Widget>[
                if (widget.pickMode)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101010),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: const Text(
                      'Tap an item to apply it to the selected equipment slot.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    widget.pickMode ? 12 : 16,
                    16,
                    12,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white70,
                          decoration: InputDecoration(
                            hintText: 'Search by name, key, type...',
                            hintStyle: const TextStyle(
                              color: Colors.white54,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0F0F0F),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0x33FFFFFF),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0x33FFFFFF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0x66FFFFFF),
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
                      if (categories.isNotEmpty) ...<Widget>[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: Tooltip(
                            message:
                                '$activeCategory (${allCategories[activeCategory]?.length ?? 0})',
                            child: OutlinedButton(
                              onPressed: () {
                                _openCategoryDialog(
                                  categories: categories,
                                  allCategories: allCategories,
                                  activeCategory: activeCategory,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: const BorderSide(
                                  color: Color(0x33FFFFFF),
                                ),
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
                            'No items found.',
                            style: TextStyle(color: Colors.white70),
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
                                final int previewLimit = columnCount >= 3
                                    ? 2
                                    : 1;

                                return _buildItemsGrid(
                                  pagedItems: pagedResult.items,
                                  columnCount: columnCount,
                                  previewLimit: previewLimit,
                                );
                              },
                        ),
                ),
                if (filteredItems.isNotEmpty)
                  _buildPaginationBar(
                    currentPage: pagedResult.currentPage,
                    totalPages: pagedResult.totalPages,
                  ),
              ],
            );
          },
    );
  }
}
