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
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760, maxHeight: 640),
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
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              icon: const Icon(Icons.close, color: Colors.white70),
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
                              final List<String> nextTrees = _availableTrees(data);
                              if (_selectedTree != _SkillMenuPageState._allTreeKey &&
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
    final List<String> categories =
        data.treeCategoryByTree.values.toSet().toList(growable: false)
          ..sort((String a, String b) {
            final int orderA = _categoryOrder[a] ?? 999;
            final int orderB = _categoryOrder[b] ?? 999;
            if (orderA != orderB) {
              return orderA.compareTo(orderB);
            }
            return a.compareTo(b);
          });
    return categories;
  }

  List<String> _availableTrees(SkillLibraryData data) {
    final List<String> trees =
        data.skillsByTree.keys
            .where((String treeName) {
              if (_selectedCategory == _allCategoryKey) {
                return true;
              }
              return data.categoryForTree(treeName) == _selectedCategory;
            })
            .toList(growable: false)
          ..sort((String a, String b) => a.compareTo(b));
    return trees;
  }

  bool _matchesQuery({
    required String query,
    required SkillEntry skill,
    required String treeName,
    required String categoryName,
  }) {
    if (query.isEmpty) {
      return true;
    }
    return skill.name.toLowerCase().contains(query) ||
        skill.description.toLowerCase().contains(query) ||
        skill.mp.toLowerCase().contains(query) ||
        skill.type.toLowerCase().contains(query) ||
        skill.element.toLowerCase().contains(query) ||
        skill.combo.toLowerCase().contains(query) ||
        skill.comboMiddle.toLowerCase().contains(query) ||
        skill.range.toLowerCase().contains(query) ||
        treeName.toLowerCase().contains(query) ||
        categoryName.toLowerCase().contains(query) ||
        (skill.unlockLevel?.toString() ?? '').contains(query);
  }

  String _activeTreeForTreeView(SkillLibraryData data) {
    final List<String> trees = _availableTrees(data);
    if (trees.isEmpty) {
      return '';
    }
    if (_selectedTree != _allTreeKey && trees.contains(_selectedTree)) {
      return _selectedTree;
    }
    return trees.first;
  }

  List<SkillEntry> _skillsForTreeView(SkillLibraryData data, String treeName) {
    if (treeName.isEmpty) {
      return const <SkillEntry>[];
    }
    final List<SkillEntry> source = List<SkillEntry>.from(
      data.skillsByTree[treeName] ?? const <SkillEntry>[],
    );
    source.sort((SkillEntry a, SkillEntry b) {
      final int levelDiff = (a.unlockLevel ?? 99).compareTo(b.unlockLevel ?? 99);
      if (levelDiff != 0) {
        return levelDiff;
      }
      return a.name.compareTo(b.name);
    });
    return source
        .where(
          (SkillEntry skill) => _matchesQuery(
            query: _query.trim().toLowerCase(),
            skill: skill,
            treeName: treeName,
            categoryName: data.categoryForTree(treeName),
          ),
        )
        .toList(growable: false);
  }

  String _present(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '-';
    }
    return trimmed;
  }

  String _activeFilterSummary() {
    final String categoryLabel = _selectedCategory == _allCategoryKey
        ? 'All Categories'
        : _selectedCategory;
    final String treeLabel = _selectedTree == _allTreeKey
        ? 'All Trees'
        : _selectedTree;
    return '$categoryLabel / $treeLabel';
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

    final Widget content = FutureBuilder<SkillLibraryData>(
      future: _libraryFuture,
      builder: (BuildContext context, AsyncSnapshot<SkillLibraryData> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error!);
        }

        final SkillLibraryData data = snapshot.data!;
        final List<String> availableTrees = _availableTrees(data);
        final String activeTree = _activeTreeForTreeView(data);
        final List<SkillEntry> treeSkills = _skillsForTreeView(data, activeTree);

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
                  builder: (BuildContext context, BoxConstraints constraints) {
                  const double filterButtonSize = 52;
                  return Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white70,
                          decoration: InputDecoration(
                            hintText: 'Search in selected skill tree...',
                            hintStyle: const TextStyle(color: Colors.white54),
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
                              side: const BorderSide(color: Color(0x33FFFFFF)),
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
              onOpenBuild: () {
                Navigator.of(context).pop();
                widget.onNavigate?.call(AppNavigationPage.build);
              },
              onOpenEquipment: () {
                Navigator.of(context).pop();
                widget.onNavigate?.call(AppNavigationPage.equipment);
              },
              onOpenSkill: () => Navigator.of(context).pop(),
              onOpenSaved: () {
                Navigator.of(context).pop();
                widget.onNavigate?.call(AppNavigationPage.saved);
              },
              onOpenCompare: () {
                Navigator.of(context).pop();
                widget.onNavigate?.call(AppNavigationPage.compare);
              },
              onOpenSettings: () {
                Navigator.of(context).pop();
                widget.onNavigate?.call(AppNavigationPage.settings);
              },
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
