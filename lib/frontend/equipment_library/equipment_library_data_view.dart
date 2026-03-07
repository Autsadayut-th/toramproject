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
  static const List<String> _weaponTypeFilterOrder = <String>[
    '1h_sword',
    '2h_sword',
    'bow',
    'bowgun',
    'staff',
    'magic_device',
    'katana',
    'halberd',
    'knuckles',
    'dagger',
    'arrow',
    'shield',
    'ninjutsu_scroll',
  ];
  static const List<String> _crystalTypeFilterOrder = <String>[
    'red',
    'green',
    'blue',
    'yellow',
    'purple',
  ];

  final EquipmentLibraryRepository _repository = EquipmentLibraryRepository();
  final TextEditingController _searchController = TextEditingController();

  late Future<Map<String, List<EquipmentLibraryItem>>> _libraryFuture;
  String? _selectedCategory;
  String _searchQuery = '';
  int _currentPage = 1;
  String? _selectedTypeFilterKey;

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
    final bool allowedCategoriesChanged = !_isSameCategoryList(
      oldWidget.allowedCategories,
      widget.allowedCategories,
    );
    final bool allowedTypesChanged = !_isSameCategoryList(
      oldWidget.allowedTypes,
      widget.allowedTypes,
    );
    if (!initialCategoryChanged &&
        !allowedCategoriesChanged &&
        !allowedTypesChanged) {
      return;
    }
    setState(() {
      _selectedCategory = widget.initialCategory;
      final Set<String>? allowedTypes = _normalizeTypeSet(widget.allowedTypes);
      if (_selectedTypeFilterKey != null &&
          allowedTypes != null &&
          !allowedTypes.contains(_selectedTypeFilterKey)) {
        _selectedTypeFilterKey = null;
      }
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

  void _updateSearchQuery(String value) {
    setState(() {
      _searchQuery = value;
      _currentPage = 1;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _currentPage = 1;
    });
  }

  Set<String>? _normalizeTypeSet(Iterable<String>? values) {
    final Set<String> normalized =
        values
            ?.map(EquipmentLibraryQueryService.normalizeTypeKey)
            .where((String value) => value.isNotEmpty)
            .toSet() ??
        <String>{};
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  bool _isCrystalCategory(String category) {
    return category.trim().toLowerCase() == 'crystal';
  }

  String _normalizedCrystalColor(String colorValue) {
    final String normalized = colorValue.trim().toLowerCase();
    if (_crystalTypeFilterOrder.contains(normalized)) {
      return normalized;
    }
    return 'blue';
  }

  String _itemTypeFilterKey(
    EquipmentLibraryItem item, {
    required String activeCategory,
  }) {
    if (_isCrystalCategory(activeCategory)) {
      return _normalizedCrystalColor(item.color);
    }
    return EquipmentLibraryQueryService.normalizeTypeKey(item.type);
  }

  List<String> _buildTypeFilterKeys({
    required List<EquipmentLibraryItem> items,
    required String activeCategory,
    required Set<String>? widgetAllowedTypes,
  }) {
    final Set<String> available = items
        .map(
          (EquipmentLibraryItem item) =>
              _itemTypeFilterKey(item, activeCategory: activeCategory),
        )
        .where((String value) => value.isNotEmpty)
        .toSet();
    if (widgetAllowedTypes != null && widgetAllowedTypes.isNotEmpty) {
      available.removeWhere(
        (String type) => !widgetAllowedTypes.contains(type),
      );
    }
    if (available.isEmpty) {
      return const <String>[];
    }

    if (_isCrystalCategory(activeCategory)) {
      final Set<String> pending = available.toSet();
      final List<String> ordered = <String>[];
      for (final String color in _crystalTypeFilterOrder) {
        if (pending.remove(color)) {
          ordered.add(color);
        }
      }
      final List<String> extras = pending.toList(growable: false)..sort();
      ordered.addAll(extras);
      return ordered;
    }

    if (activeCategory.trim().toLowerCase() != 'weapon') {
      final List<String> generic = available.toList(growable: false)..sort();
      return generic;
    }

    final Set<String> pending = available.toSet();
    final List<String> ordered = <String>[];
    for (final String type in _weaponTypeFilterOrder) {
      if (pending.remove(type)) {
        ordered.add(type);
      }
    }
    final List<String> extras = pending.toList(growable: false)..sort();
    ordered.addAll(extras);
    return ordered;
  }

  Set<String>? _resolveEffectiveAllowedTypes({
    required Set<String>? widgetAllowedTypes,
    required String? selectedTypeFilterKey,
  }) {
    final bool hasWidgetTypes =
        widgetAllowedTypes != null && widgetAllowedTypes.isNotEmpty;
    if (!hasWidgetTypes && selectedTypeFilterKey == null) {
      return null;
    }
    if (selectedTypeFilterKey == null) {
      return widgetAllowedTypes;
    }
    if (!hasWidgetTypes) {
      return <String>{selectedTypeFilterKey};
    }
    if (widgetAllowedTypes.contains(selectedTypeFilterKey)) {
      return <String>{selectedTypeFilterKey};
    }
    return <String>{};
  }

  void _applyFilterSelection({
    required String category,
    required String? typeKey,
  }) {
    setState(() {
      _selectedCategory = category;
      _selectedTypeFilterKey = typeKey;
      _currentPage = 1;
    });
  }

  String _formatTypeFilterLabel(String typeKey, {required String category}) {
    if (_isCrystalCategory(category)) {
      final String normalized = _normalizedCrystalColor(typeKey);
      return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
    }
    return typeKey
        .split('_')
        .where((String part) => part.isNotEmpty)
        .map((String part) {
          return part[0].toUpperCase() + part.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Future<void> _openFilterDialog({
    required List<String> categories,
    required Map<String, List<EquipmentLibraryItem>> allCategories,
    required String activeCategory,
    required List<String> typeFilterKeys,
    required String? activeTypeFilterKey,
  }) async {
    if (categories.length <= 1 && typeFilterKeys.length <= 1) {
      return;
    }

    final Set<String>? widgetAllowedTypes = _normalizeTypeSet(
      widget.allowedTypes,
    );
    String selectedCategory = activeCategory;
    String? selectedTypeKey = activeTypeFilterKey;

    final bool hasCategoryChoices = categories.length > 1;

    final ({String category, String? typeKey})? selection =
        await showDialog<({String category, String? typeKey})>(
          context: context,
          builder: (BuildContext dialogContext) {
            return Dialog(
              backgroundColor: const Color(0xFF101010),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setDialogState) {
                    final List<EquipmentLibraryItem> selectedCategoryItems =
                        allCategories[selectedCategory] ??
                        const <EquipmentLibraryItem>[];
                    final List<String> availableTypeKeys = _buildTypeFilterKeys(
                      items: selectedCategoryItems,
                      activeCategory: selectedCategory,
                      widgetAllowedTypes: widgetAllowedTypes,
                    );
                    if (selectedTypeKey != null &&
                        !availableTypeKeys.contains(selectedTypeKey)) {
                      selectedTypeKey = null;
                    }
                    final bool hasTypeChoices = availableTypeKeys.length > 1;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                const Expanded(
                                  child: Text(
                                    'Filter Library',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  child: const Text(
                                    'Close',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                            if (hasCategoryChoices) ...<Widget>[
                              const SizedBox(height: 4),
                              const Text(
                                'Category',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: categories
                                    .map((String category) {
                                      return ChoiceChip(
                                        selectedColor: const Color(0xFF2E74FF),
                                        backgroundColor: const Color(
                                          0xFF161B22,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0x44FFFFFF),
                                        ),
                                        labelStyle: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        selected: selectedCategory == category,
                                        label: Text(category),
                                        onSelected: (_) {
                                          setDialogState(() {
                                            selectedCategory = category;
                                          });
                                        },
                                      );
                                    })
                                    .toList(growable: false),
                              ),
                              const SizedBox(height: 14),
                            ],
                            if (hasTypeChoices) ...<Widget>[
                              const Text(
                                'Type',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  ChoiceChip(
                                    selectedColor: const Color(0xFF2E74FF),
                                    backgroundColor: const Color(0xFF161B22),
                                    side: const BorderSide(
                                      color: Color(0x44FFFFFF),
                                    ),
                                    labelStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    selected: selectedTypeKey == null,
                                    label: const Text('All'),
                                    onSelected: (_) {
                                      setDialogState(() {
                                        selectedTypeKey = null;
                                      });
                                    },
                                  ),
                                  ...availableTypeKeys.map((String typeKey) {
                                    final bool selected =
                                        selectedTypeKey == typeKey;
                                    return ChoiceChip(
                                      selectedColor: const Color(0xFF2E74FF),
                                      backgroundColor: const Color(0xFF161B22),
                                      side: const BorderSide(
                                        color: Color(0x44FFFFFF),
                                      ),
                                      labelStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      selected: selected,
                                      label: Text(
                                        _formatTypeFilterLabel(
                                          typeKey,
                                          category: selectedCategory,
                                        ),
                                      ),
                                      onSelected: (_) {
                                        setDialogState(() {
                                          selectedTypeKey = typeKey;
                                        });
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      selectedCategory = categories.isEmpty
                                          ? activeCategory
                                          : categories.first;
                                      selectedTypeKey = null;
                                    });
                                  },
                                  child: const Text(
                                    'Reset',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop((
                                      category: selectedCategory,
                                      typeKey: selectedTypeKey,
                                    ));
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E74FF),
                                  ),
                                  child: const Text('Apply'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );

    if (!mounted || selection == null) {
      return;
    }
    _applyFilterSelection(
      category: selection.category,
      typeKey: selection.typeKey,
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
                      TextButton(
                        onPressed: _reload,
                        child: const Text('Retry'),
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
            final Set<String>? widgetAllowedTypes = _normalizeTypeSet(
              widget.allowedTypes,
            );
            final List<String> typeFilterKeys = _buildTypeFilterKeys(
              items: allItems,
              activeCategory: activeCategory,
              widgetAllowedTypes: widgetAllowedTypes,
            );
            final String? activeTypeFilterKey =
                typeFilterKeys.contains(_selectedTypeFilterKey)
                ? _selectedTypeFilterKey
                : null;
            final Set<String>? effectiveAllowedTypes =
                _resolveEffectiveAllowedTypes(
                  widgetAllowedTypes: widgetAllowedTypes,
                  selectedTypeFilterKey: activeTypeFilterKey,
                );
            final List<EquipmentLibraryItem> filteredItems =
                EquipmentLibraryQueryService.filterItems(
                  items: allItems,
                  query: _searchQuery,
                  allowedTypes: effectiveAllowedTypes,
                  typeKeyResolver: (EquipmentLibraryItem item) {
                    return _itemTypeFilterKey(
                      item,
                      activeCategory: activeCategory,
                    );
                  },
                );
            final EquipmentLibraryPageSlice pagedResult =
                EquipmentLibraryQueryService.paginateItems(
                  filteredItems: filteredItems,
                  currentPage: _currentPage,
                  itemsPerPage: _itemsPerPage,
                );

            return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    widget.pickMode ? 16 : 20,
                    16,
                    14,
                  ),
                  child: _buildSearchToolbar(
                    categories: categories,
                    allCategories: allCategories,
                    activeCategory: activeCategory,
                    typeFilterKeys: typeFilterKeys,
                    activeTypeFilterKey: activeTypeFilterKey,
                  ),
                ),
                Expanded(
                  child: filteredItems.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: _buildEmptyState(
                            activeCategory: activeCategory,
                          ),
                        )
                      : LayoutBuilder(
                          builder:
                              (
                                BuildContext context,
                                BoxConstraints constraints,
                              ) {
                                final double width = constraints.maxWidth;
                                final int columnCount = width >= 1500
                                    ? 5
                                    : width >= 1240
                                    ? 4
                                    : width >= 960
                                    ? 3
                                    : width >= 620
                                    ? 2
                                    : 1;
                                final int previewLimit = columnCount >= 5
                                    ? 0
                                    : columnCount >= 4
                                    ? 1
                                    : columnCount >= 3
                                    ? 2
                                    : 1;

                                return _buildItemsGrid(
                                  pagedItems: pagedResult.items,
                                  columnCount: columnCount,
                                  previewLimit: previewLimit,
                                  activeCategory: activeCategory,
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

extension _EquipmentLibraryDataViewLayout on _EquipmentLibraryDataViewState {
  Widget _buildSearchToolbar({
    required List<String> categories,
    required Map<String, List<EquipmentLibraryItem>> allCategories,
    required String activeCategory,
    required List<String> typeFilterKeys,
    required String? activeTypeFilterKey,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF15110E), Color(0xFF0B0D10)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxWidth < 720;
            final bool canOpenFilter =
                categories.length > 1 || typeFilterKeys.length > 1;
            final bool hasTypeFilter = activeTypeFilterKey != null;
            final String activeTypeFilterLabel = activeTypeFilterKey == null
                ? ''
                : _formatTypeFilterLabel(
                    activeTypeFilterKey,
                    category: activeCategory,
                  );
            final bool hasCategoryFilter =
                categories.isNotEmpty && activeCategory != categories.first;
            final int activeFilterCount =
                (hasCategoryFilter ? 1 : 0) + (hasTypeFilter ? 1 : 0);
            final Widget filterButton = Tooltip(
              message: activeFilterCount == 0
                  ? 'Filter category and type'
                  : hasCategoryFilter && hasTypeFilter
                  ? 'Category: $activeCategory, Type: $activeTypeFilterLabel'
                  : hasCategoryFilter
                  ? 'Category: $activeCategory'
                  : 'Type: $activeTypeFilterLabel',
              child: SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned.fill(
                      child: OutlinedButton(
                        onPressed: canOpenFilter
                            ? () {
                                _openFilterDialog(
                                  categories: categories,
                                  allCategories: allCategories,
                                  activeCategory: activeCategory,
                                  typeFilterKeys: typeFilterKeys,
                                  activeTypeFilterKey: activeTypeFilterKey,
                                );
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF10161A),
                          disabledForegroundColor: Colors.white38,
                          disabledBackgroundColor: const Color(0xFF10161A),
                          side: BorderSide(
                            color: activeFilterCount > 0
                                ? const Color(0xFFD8B36A)
                                : const Color(0xFF5D7283),
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Icon(Icons.tune, size: 18),
                      ),
                    ),
                    if (activeFilterCount > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E74FF),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFF8FB4FF)),
                          ),
                          child: Text(
                            '$activeFilterCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (widget.pickMode) ...<Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _libraryWarmAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _libraryWarmAccent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Tap any card to select it for the active equipment slot.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (compact) ...<Widget>[
                  _buildSearchField(),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerRight, child: filterButton),
                ] else
                  Row(
                    children: <Widget>[
                      Expanded(child: _buildSearchField()),
                      const SizedBox(width: 12),
                      filterButton,
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      cursorColor: _libraryWarmAccent,
      decoration: InputDecoration(
        hintText: 'Search by name, key, type, color...',
        hintStyle: const TextStyle(color: Colors.white54),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : TextButton(
                onPressed: _clearSearch,
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
        filled: true,
        fillColor: const Color(0xFF10161A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: _libraryCoolAccent.withValues(alpha: 0.18),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: _libraryCoolAccent.withValues(alpha: 0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: _libraryWarmAccent.withValues(alpha: 0.7),
            width: 1.4,
          ),
        ),
      ),
      onChanged: _updateSearchQuery,
    );
  }

  Widget _buildEmptyState({required String activeCategory}) {
    final bool hasSearchQuery = _searchQuery.trim().isNotEmpty;

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF171311), Color(0xFF0D1115)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x22FFFFFF)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'No items found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearchQuery
                  ? 'No results in $activeCategory match "${_searchQuery.trim()}".'
                  : 'There are no items available in $activeCategory for the current filters.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (hasSearchQuery) ...<Widget>[
              const SizedBox(height: 14),
              TextButton(
                onPressed: _clearSearch,
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 31, 155, 14),
                ),
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
