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

  Future<void> _openFiltersDialog(SkillLibraryData data) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF101010),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
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
                            const Expanded(
                              child: Text(
                                'Filter Skills',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white70,
                              ),
                              tooltip: 'Close',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Category',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SkillFilterWidgets.buildCategoryFilter(
                          data,
                          _selectedCategory,
                          _availableCategories(data),
                          (String category) {
                            _setUiState(() {
                              _selectedCategory = category;
                              final List<String> nextTrees = _availableTrees(
                                data,
                              );
                              if (_selectedTree !=
                                      _SkillMenuPageState._allTreeKey &&
                                  !nextTrees.contains(_selectedTree)) {
                                _selectedTree = _SkillMenuPageState._allTreeKey;
                              }
                            });
                            setDialogState(() {});
                          },
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Tree',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SkillFilterWidgets.buildTreeFilter(
                          data,
                          _selectedCategory,
                          _selectedTree,
                          _availableTrees(data),
                          (String tree) {
                            _setUiState(() {
                              _selectedTree = tree;
                            });
                            setDialogState(() {});
                          },
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

  @override
  Widget build(BuildContext context) {
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

    final Widget content = FutureBuilder<SkillLibraryData>(
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
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          const double filterButtonSize = 52;
                          return Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: Colors.white70,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search in selected skill tree...',
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
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0x33FFFFFF),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0x33FFFFFF),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0x66FFFFFF),
                                      ),
                                    ),
                                  ),
                                  onChanged: (String value) {
                                    setState(() {
                                      _query = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: filterButtonSize,
                                height: filterButtonSize,
                                child: Tooltip(
                                  message: _activeFilterSummary(),
                                  child: OutlinedButton(
                                    onPressed: () => _openFiltersDialog(data),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white70,
                                      side: const BorderSide(
                                        color: Color(0x33FFFFFF),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: const Color(0xFF0F0F0F),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: const Icon(Icons.tune, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                  ),
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
    );

    if (isEmbeddedInShell) {
      return content;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
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
