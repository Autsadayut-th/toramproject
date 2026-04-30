part of 'equipment_library_page.dart';

class _EquipmentLibraryDataView extends StatefulWidget {
  const _EquipmentLibraryDataView({
    required this.pickMode,
    required this.initialCategory,
    required this.allowedCategories,
    required this.allowedTypes,
    required this.inMemoryItemsByCategory,
  });

  final bool pickMode;
  final String? initialCategory;
  final List<String>? allowedCategories;
  final List<String>? allowedTypes;
  final Map<String, List<EquipmentLibraryItem>>? inMemoryItemsByCategory;

  @override
  State<_EquipmentLibraryDataView> createState() =>
      _EquipmentLibraryDataViewState();
}

class _EquipmentLibraryDataViewState extends State<_EquipmentLibraryDataView> {
  static const int _itemsPerPage = 27;
  static const List<_SearchModeOption> _searchModeOptions = <_SearchModeOption>[
    _SearchModeOption(
      token: 'all',
      label: 'All',
      description: 'Search all fields',
    ),
    _SearchModeOption(
      token: 'name',
      label: 'Name',
      description: 'Search item name',
    ),
    _SearchModeOption(
      token: 'key',
      label: 'Key',
      description: 'Search item key',
    ),
    _SearchModeOption(
      token: 'type',
      label: 'Type',
      description: 'Search equipment type',
    ),
    _SearchModeOption(
      token: 'color',
      label: 'Color',
      description: 'Search crystal color',
    ),
    _SearchModeOption(
      token: 'stat',
      label: 'Stat',
      description: 'Search stat_key',
    ),
    _SearchModeOption(
      token: 'element',
      label: 'Element',
      description: 'Search elemental attribute',
    ),
  ];
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

  static const String _sourceFilterAll = 'all_sources';
  static const String _sourceFilterPlayerCreated = 'player_created';

  late Future<Map<String, List<EquipmentLibraryItem>>> _libraryFuture;
  String? _selectedCategory;
  String _searchQuery = '';
  int _currentPage = 1;
  String? _selectedTypeFilterKey;
  String _sourceFilterKey = _sourceFilterAll;

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

  List<_SearchModeOption> _matchingSearchModes(String query) {
    final String trimmed = query.trimLeft();
    if (!trimmed.startsWith('@')) {
      return const <_SearchModeOption>[];
    }
    final String rawKeyword = trimmed.substring(1);
    if (rawKeyword.contains(' ')) {
      return const <_SearchModeOption>[];
    }

    final String keyword = rawKeyword.trim().toLowerCase();
    if (keyword.isEmpty) {
      return _searchModeOptions;
    }
    return _searchModeOptions
        .where((_SearchModeOption option) {
          return option.token.startsWith(keyword) ||
              option.label.toLowerCase().startsWith(keyword);
        })
        .toList(growable: false);
  }

  void _applySearchMode(_SearchModeOption option) {
    final String nextQuery = '@${option.token} ';
    _searchController.value = TextEditingValue(
      text: nextQuery,
      selection: TextSelection.collapsed(offset: nextQuery.length),
    );
    _updateSearchQuery(nextQuery);
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

  bool _isPlayerCreatedItem(EquipmentLibraryItem item) {
    return item.obtainedFrom.any((EquipmentObtainedSource source) {
      final String sourceType = source.sourceType?.trim().toLowerCase() ?? '';
      if (sourceType == 'custom') {
        return true;
      }
      final String sourceName = source.source.trim().toLowerCase();
      return sourceName == 'custom equipment';
    });
  }

  String _resolveCategoryKey(
    String rawCategory,
    Map<String, List<EquipmentLibraryItem>> allCategories,
  ) {
    final String trimmed = rawCategory.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    for (final String key in allCategories.keys) {
      if (key.toLowerCase() == trimmed.toLowerCase()) {
        return key;
      }
    }
    for (final String key in _repository.categories) {
      if (key.toLowerCase() == trimmed.toLowerCase()) {
        return key;
      }
    }
    return trimmed;
  }

  Map<String, List<EquipmentLibraryItem>> _mergeInMemoryItemsByCategory(
    Map<String, List<EquipmentLibraryItem>> repositoryItemsByCategory,
  ) {
    final Map<String, List<EquipmentLibraryItem>> merged =
        <String, List<EquipmentLibraryItem>>{};
    repositoryItemsByCategory.forEach((
      String category,
      List<EquipmentLibraryItem> items,
    ) {
      merged[category] = List<EquipmentLibraryItem>.from(items);
    });

    final Map<String, List<EquipmentLibraryItem>> injected =
        widget.inMemoryItemsByCategory ??
        const <String, List<EquipmentLibraryItem>>{};
    if (injected.isEmpty) {
      return merged;
    }

    injected.forEach((String rawCategory, List<EquipmentLibraryItem> incoming) {
      final String category = _resolveCategoryKey(rawCategory, merged);
      if (category.isEmpty) {
        return;
      }

      final Map<String, EquipmentLibraryItem> byKey =
          <String, EquipmentLibraryItem>{
            for (final EquipmentLibraryItem item
                in (merged[category] ?? const <EquipmentLibraryItem>[]))
              item.key.trim().toLowerCase(): item,
          };
      for (final EquipmentLibraryItem item in incoming) {
        final String key = item.key.trim().toLowerCase();
        if (key.isEmpty) {
          continue;
        }
        byKey[key] = item;
      }

      final List<EquipmentLibraryItem> categoryItems =
          byKey.values.toList(growable: false)
            ..sort((EquipmentLibraryItem a, EquipmentLibraryItem b) {
              return a.name.toLowerCase().compareTo(b.name.toLowerCase());
            });
      merged[category] = categoryItems;
    });

    return merged;
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
    required String sourceFilterKey,
  }) {
    setState(() {
      _selectedCategory = category;
      _selectedTypeFilterKey = typeKey;
      _sourceFilterKey = sourceFilterKey;
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
    required bool customFilterAvailable,
    required String activeSourceFilterKey,
  }) async {
    final Set<String>? widgetAllowedTypes = _normalizeTypeSet(
      widget.allowedTypes,
    );
    if (categories.length <= 1 &&
        typeFilterKeys.length <= 1 &&
        !customFilterAvailable) {
      return;
    }

    String selectedCategory = activeCategory;
    String? selectedTypeKey = activeTypeFilterKey;
    String selectedSourceFilterKey = activeSourceFilterKey;
    final bool hasCategoryChoices = categories.length > 1;

    final ({String category, String? typeKey, String sourceFilterKey})?
    selection =
        await showDialog<
          ({String category, String? typeKey, String sourceFilterKey})
        >(
          context: context,
          builder: (BuildContext dialogContext) {
            final ColorScheme colorScheme = Theme.of(dialogContext).colorScheme;
            return Dialog(
              backgroundColor: colorScheme.surfaceContainerHigh,
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
                                Expanded(
                                  child: Text(
                                    'Filter Library',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  child: Text(
                                    'Close',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (hasCategoryChoices) ...<Widget>[
                              const SizedBox(height: 4),
                              Text(
                                'Category',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.75,
                                  ),
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
                                        selectedColor:
                                            colorScheme.primaryContainer,
                                        backgroundColor:
                                            colorScheme.surfaceContainerHighest,
                                        side: BorderSide(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.24),
                                        ),
                                        labelStyle: TextStyle(
                                          color: colorScheme.onSurface,
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
                              Text(
                                'Type',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.75,
                                  ),
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
                                    selectedColor: colorScheme.primaryContainer,
                                    backgroundColor:
                                        colorScheme.surfaceContainerHighest,
                                    side: BorderSide(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.24,
                                      ),
                                    ),
                                    labelStyle: TextStyle(
                                      color: colorScheme.onSurface,
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
                                      selectedColor:
                                          colorScheme.primaryContainer,
                                      backgroundColor:
                                          colorScheme.surfaceContainerHighest,
                                      side: BorderSide(
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.24,
                                        ),
                                      ),
                                      labelStyle: TextStyle(
                                        color: colorScheme.onSurface,
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
                              const SizedBox(height: 14),
                            ],
                            if (customFilterAvailable) ...<Widget>[
                              Text(
                                'Source',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.75,
                                  ),
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
                                    selectedColor: colorScheme.primaryContainer,
                                    backgroundColor:
                                        colorScheme.surfaceContainerHighest,
                                    side: BorderSide(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.24,
                                      ),
                                    ),
                                    labelStyle: TextStyle(
                                      color: colorScheme.onSurface,
                                    ),
                                    selected:
                                        selectedSourceFilterKey ==
                                        _sourceFilterAll,
                                    label: const Text('All Sources'),
                                    onSelected: (_) {
                                      setDialogState(() {
                                        selectedSourceFilterKey =
                                            _sourceFilterAll;
                                      });
                                    },
                                  ),
                                  ChoiceChip(
                                    selectedColor: colorScheme.primaryContainer,
                                    backgroundColor:
                                        colorScheme.surfaceContainerHighest,
                                    side: BorderSide(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.24,
                                      ),
                                    ),
                                    labelStyle: TextStyle(
                                      color: colorScheme.onSurface,
                                    ),
                                    selected:
                                        selectedSourceFilterKey ==
                                        _sourceFilterPlayerCreated,
                                    label: const Text('Player Created'),
                                    onSelected: (_) {
                                      setDialogState(() {
                                        selectedSourceFilterKey =
                                            _sourceFilterPlayerCreated;
                                      });
                                    },
                                  ),
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
                                      selectedSourceFilterKey =
                                          _sourceFilterAll;
                                    });
                                  },
                                  child: Text(
                                    'Reset',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop((
                                      category: selectedCategory,
                                      typeKey: selectedTypeKey,
                                      sourceFilterKey: selectedSourceFilterKey,
                                    ));
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
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
      sourceFilterKey: selection.sourceFilterKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
                      Text(
                        'Failed to load equipment data.',
                        style: TextStyle(color: colorScheme.onSurface),
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
                _mergeInMemoryItemsByCategory(
                  snapshot.data ?? <String, List<EquipmentLibraryItem>>{},
                );
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
            final bool customFilterAvailable = allItems.any(
              _isPlayerCreatedItem,
            );
            final String activeSourceFilterKey =
                customFilterAvailable &&
                    _sourceFilterKey == _sourceFilterPlayerCreated
                ? _sourceFilterPlayerCreated
                : _sourceFilterAll;
            final List<EquipmentLibraryItem> sourceFilteredItems;
            switch (activeSourceFilterKey) {
              case _sourceFilterPlayerCreated:
                sourceFilteredItems = allItems
                    .where(_isPlayerCreatedItem)
                    .toList(growable: false);
                break;
              default:
                sourceFilteredItems = allItems;
                break;
            }
            final Set<String>? widgetAllowedTypes = _normalizeTypeSet(
              widget.allowedTypes,
            );
            final List<String> typeFilterKeys = _buildTypeFilterKeys(
              items: sourceFilteredItems,
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
                  items: sourceFilteredItems,
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
                    customFilterAvailable: customFilterAvailable,
                    activeSourceFilterKey: activeSourceFilterKey,
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
    required bool customFilterAvailable,
    required String activeSourceFilterKey,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surfaceContainerHigh,
            colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: isLight ? 0.24 : 0.14),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxWidth < 720;
            final bool canOpenFilter =
                categories.length > 1 ||
                typeFilterKeys.length > 1 ||
                customFilterAvailable;
            final bool hasTypeFilter = activeTypeFilterKey != null;
            final String activeTypeFilterLabel = activeTypeFilterKey == null
                ? ''
                : _formatTypeFilterLabel(
                    activeTypeFilterKey,
                    category: activeCategory,
                  );
            final bool hasCategoryFilter =
                categories.isNotEmpty && activeCategory != categories.first;
            final bool hasSourceFilter =
                customFilterAvailable &&
                activeSourceFilterKey !=
                    _EquipmentLibraryDataViewState._sourceFilterAll;
            const String sourceFilterLabel = 'Player Created';
            final int activeFilterCount =
                (hasCategoryFilter ? 1 : 0) +
                (hasTypeFilter ? 1 : 0) +
                (hasSourceFilter ? 1 : 0);
            final Widget filterButton = Tooltip(
              message: activeFilterCount == 0
                  ? 'Filter category, type, and source'
                  : hasCategoryFilter && hasTypeFilter && hasSourceFilter
                  ? 'Category: $activeCategory, Type: $activeTypeFilterLabel, Source: $sourceFilterLabel'
                  : hasCategoryFilter && hasTypeFilter
                  ? 'Category: $activeCategory, Type: $activeTypeFilterLabel'
                  : hasCategoryFilter && hasSourceFilter
                  ? 'Category: $activeCategory, Source: $sourceFilterLabel'
                  : hasTypeFilter && hasSourceFilter
                  ? 'Type: $activeTypeFilterLabel, Source: $sourceFilterLabel'
                  : hasCategoryFilter
                  ? 'Category: $activeCategory'
                  : hasSourceFilter
                  ? 'Source: $sourceFilterLabel'
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
                                  customFilterAvailable: customFilterAvailable,
                                  activeSourceFilterKey: activeSourceFilterKey,
                                );
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          disabledForegroundColor: colorScheme.onSurface
                              .withValues(alpha: 0.38),
                          disabledBackgroundColor:
                              colorScheme.surfaceContainerHighest,
                          side: BorderSide(
                            color: activeFilterCount > 0
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.35),
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
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: colorScheme.onPrimary.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                          child: Text(
                            '$activeFilterCount',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
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
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.35,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Tap any card to select it for the active equipment slot.',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.75,
                              ),
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
                if (compact)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: _buildSearchField()),
                      const SizedBox(width: 10),
                      filterButton,
                    ],
                  )
                else
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final List<_SearchModeOption> matchingModes = _matchingSearchModes(
      _searchQuery,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: _searchController,
          style: TextStyle(color: colorScheme.onSurface),
          cursorColor: colorScheme.primary,
          decoration: InputDecoration(
            hintText:
                'Search by name, key, type, color, stat, element... (type @ to choose)',
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.54),
            ),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : TextButton(
                    onPressed: _clearSearch,
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.54),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(
                  alpha: isLight ? 0.28 : 0.18,
                ),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.onSurface.withValues(
                  alpha: isLight ? 0.28 : 0.18,
                ),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.7),
                width: 1.4,
              ),
            ),
          ),
          onChanged: _updateSearchQuery,
        ),
        if (matchingModes.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.28),
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: matchingModes
                  .map((_SearchModeOption option) {
                    return ActionChip(
                      label: Text('@${option.token}  ${option.label}'),
                      onPressed: () => _applySearchMode(option),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      side: BorderSide(
                        color: colorScheme.onSurface.withValues(alpha: 0.34),
                      ),
                      labelStyle: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      tooltip: option.description,
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState({required String activeCategory}) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final bool hasSearchQuery = _searchQuery.trim().isNotEmpty;

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              colorScheme.surfaceContainerHigh,
              colorScheme.surfaceContainerHighest,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.onSurface.withValues(
              alpha: isLight ? 0.24 : 0.14,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'No items found',
              style: TextStyle(
                color: colorScheme.onSurface,
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
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.75),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (hasSearchQuery) ...<Widget>[
              const SizedBox(height: 14),
              TextButton(
                onPressed: _clearSearch,
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
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

class _SearchModeOption {
  const _SearchModeOption({
    required this.token,
    required this.label,
    required this.description,
  });

  final String token;
  final String label;
  final String description;
}
