import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shared/app_mobile_bottom_navigation_bar.dart';
import '../shared/app_navigation_drawer.dart';
import 'widgets/skill_filter_widgets.dart';
import 'widgets/skill_card_widgets.dart';
import 'widgets/skill_tree_widgets.dart';

part 'skill_menu_page_ui.dart';
part 'skill_menu_page_data.dart';
part 'skill_image_asset_config.dart';
part 'services/skill_menu_filter_service.dart';

class SkillMenuPage extends StatefulWidget {
  const SkillMenuPage({super.key, this.onNavigate});

  final ValueChanged<AppNavigationPage>? onNavigate;

  @override
  State<SkillMenuPage> createState() => _SkillMenuPageState();
}

class _SkillMenuPageState extends State<SkillMenuPage> {
  static const String _allCategoryKey = '__all_category__';
  static const String _allTreeKey = '__all_tree__';
  static const String _defaultCategory = 'Weapon';
  static const String _defaultTree = 'Blade';
  static const Map<String, int> _categoryOrder = <String, int>{
    'Weapon': 0,
    'Buff': 1,
    'Assist': 2,
    'Other': 3,
  };

  final SkillMenuRepository _repository = const SkillMenuRepository();
  final TextEditingController _searchController = TextEditingController();

  late Future<SkillLibraryData> _libraryFuture;
  String _selectedCategory = _defaultCategory;
  String _selectedTree = _defaultTree;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _libraryFuture = _repository.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _libraryFuture = _repository.load();
    });
  }

  void _setUiState(VoidCallback action) {
    setState(action);
  }

  int _activeFilterCount() {
    int count = 0;
    if (_selectedCategory != _allCategoryKey) {
      count++;
    }
    if (_selectedTree != _allTreeKey) {
      count++;
    }
    return count;
  }

  Future<void> _openFiltersDialog(SkillLibraryData data) async {
    String dialogCategory = _selectedCategory;
    String dialogTree = _selectedTree;

    final ({String category, String tree})? selection =
        await showDialog<({String category, String tree})>(
          context: context,
          builder: (BuildContext dialogContext) {
            final ColorScheme colorScheme = Theme.of(dialogContext).colorScheme;
            return Dialog(
              backgroundColor: colorScheme.surfaceContainerHigh,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setDialogState) {
                  List<String> dialogTrees() {
                    return SkillMenuFilterService.availableTrees(
                      data: data,
                      selectedCategory: dialogCategory,
                      allCategoryKey: _allCategoryKey,
                    );
                  }

                  return ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 760,
                      maxHeight: 640,
                    ),
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
                                    'Filter Skills',
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
                            const SizedBox(height: 8),
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
                            SkillFilterWidgets.buildCategoryFilter(
                              context,
                              data,
                              dialogCategory,
                              _availableCategories(data),
                              (String category) {
                                setDialogState(() {
                                  dialogCategory = category;
                                  final List<String> nextTrees = dialogTrees();
                                  if (dialogTree != _allTreeKey &&
                                      !nextTrees.contains(dialogTree)) {
                                    dialogTree = _allTreeKey;
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Tree',
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.75,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SkillFilterWidgets.buildTreeFilter(
                              context,
                              data,
                              dialogCategory,
                              dialogTree,
                              dialogTrees(),
                              (String tree) {
                                setDialogState(() {
                                  dialogTree = tree;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      dialogCategory = _allCategoryKey;
                                      dialogTree = _allTreeKey;
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
                                      category: dialogCategory,
                                      tree: dialogTree,
                                    ));
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                  ),
                                  child: Text('Apply'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );

    if (!mounted || selection == null) {
      return;
    }

    _setUiState(() {
      _selectedCategory = selection.category;
      _selectedTree = selection.tree;
    });
  }

  List<String> _availableCategories(SkillLibraryData data) {
    return SkillMenuFilterService.availableCategories(
      data: data,
      categoryOrder: _categoryOrder,
    );
  }

  List<String> _availableTrees(SkillLibraryData data) {
    return SkillMenuFilterService.availableTrees(
      data: data,
      selectedCategory: _selectedCategory,
      allCategoryKey: _allCategoryKey,
    );
  }

  String _activeTreeForTreeView(SkillLibraryData data) {
    return SkillMenuFilterService.activeTreeForTreeView(
      availableTrees: _availableTrees(data),
      selectedTree: _selectedTree,
      allTreeKey: _allTreeKey,
    );
  }

  List<SkillEntry> _skillsForTreeView(SkillLibraryData data, String treeName) {
    return SkillMenuFilterService.skillsForTreeView(
      data: data,
      treeName: treeName,
      query: _query,
    );
  }

  String _present(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '-';
    }
    return trimmed;
  }

  String _activeFilterSummary() {
    return SkillMenuFilterService.activeFilterSummary(
      selectedCategory: _selectedCategory,
      selectedTree: _selectedTree,
      allCategoryKey: _allCategoryKey,
      allTreeKey: _allTreeKey,
    );
  }

  Widget _buildSearchToolbar(SkillLibraryData data) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<String> categories = _availableCategories(data);
    final bool canOpenFilter =
        categories.length > 1 || _availableTrees(data).length > 1;
    final int activeFilterCount = _activeFilterCount();

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
          color: colorScheme.onSurface.withValues(alpha: 0.14),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Widget filterButton = Tooltip(
              message: _activeFilterSummary(),
              child: SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned.fill(
                      child: OutlinedButton(
                        onPressed: canOpenFilter
                            ? () => _openFiltersDialog(data)
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
                                : colorScheme.onSurface.withValues(alpha: 0.3),
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
                              color: colorScheme.primary.withValues(
                                alpha: 0.65,
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

            return Row(
              children: <Widget>[
                Expanded(child: _buildSkillSearchField()),
                const SizedBox(width: 12),
                filterButton,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkillSearchField() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: _searchController,
      style: TextStyle(color: colorScheme.onSurface),
      cursorColor: colorScheme.primary,
      decoration: InputDecoration(
        hintText: 'Search in selected skill tree...',
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.54),
        ),
        suffixIcon: _query.isEmpty
            ? null
            : TextButton(
                onPressed: () {
                  _setUiState(() {
                    _searchController.clear();
                    _query = '';
                  });
                },
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: colorScheme.onSurface,
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
            color: colorScheme.onSurface.withValues(alpha: 0.24),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.24),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      onChanged: (String value) {
        _setUiState(() {
          _query = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isMobile = MediaQuery.sizeOf(context).width < 1024;
    final bool isEmbeddedInShell = widget.onNavigate != null;

    void onSelectMobileNav(AppNavigationPage page) {
      if (page == AppNavigationPage.skill) {
        return;
      }
      widget.onNavigate?.call(page);
    }

    void onSelectDrawerPage(AppNavigationPage page) {
      Navigator.of(context).pop();
      if (page != AppNavigationPage.skill) {
        widget.onNavigate?.call(page);
      }
    }

    final Widget content = ColoredBox(
      color: colorScheme.surface,
      child: FutureBuilder<SkillLibraryData>(
        future: _libraryFuture,
        builder:
            (BuildContext context, AsyncSnapshot<SkillLibraryData> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error!);
              }

              final SkillLibraryData data = snapshot.data!;
              final List<String> availableTrees = _availableTrees(data);
              final String activeTree = _activeTreeForTreeView(data);
              final List<SkillEntry> treeSkills = _skillsForTreeView(
                data,
                activeTree,
              );

              return Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      isEmbeddedInShell ? 12 : 0,
                      16,
                      10,
                    ),
                    child: _buildSearchToolbar(data),
                  ),
                  Expanded(
                    child: _buildSkillTreeView(
                      data: data,
                      availableTrees: availableTrees,
                      activeTree: activeTree,
                      visibleSkills: treeSkills,
                    ),
                  ),
                ],
              );
            },
      ),
    );

    if (isEmbeddedInShell) {
      return content;
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      drawer: isMobile
          ? null
          : AppNavigationDrawer(
              currentPage: AppNavigationPage.skill,
              onOpenBuild: () => onSelectDrawerPage(AppNavigationPage.build),
              onOpenEquipment: () =>
                  onSelectDrawerPage(AppNavigationPage.equipment),
              onOpenSkill: () => onSelectDrawerPage(AppNavigationPage.skill),
              onOpenSaved: () => onSelectDrawerPage(AppNavigationPage.saved),
              onOpenCompare: () =>
                  onSelectDrawerPage(AppNavigationPage.compare),
              onOpenSettings: () =>
                  onSelectDrawerPage(AppNavigationPage.settings),
            ),
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        automaticallyImplyLeading: false,
        leading: isMobile
            ? null
            : Builder(
                builder: (BuildContext context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        title: const Text('Skill Menu'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reload',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: content,
      bottomNavigationBar: isMobile
          ? AppMobileBottomNavigationBar(
              currentPage: AppNavigationPage.skill,
              onSelect: onSelectMobileNav,
            )
          : null,
    );
  }
}
