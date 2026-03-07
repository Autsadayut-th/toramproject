part of '../skill_menu_page.dart';

class SkillMenuFilterService {
  const SkillMenuFilterService._();

  static List<String> availableCategories({
    required SkillLibraryData data,
    required Map<String, int> categoryOrder,
  }) {
    final List<String> categories =
        data.treeCategoryByTree.values.toSet().toList(growable: false)
          ..sort((String a, String b) {
            final int orderA = categoryOrder[a] ?? 999;
            final int orderB = categoryOrder[b] ?? 999;
            if (orderA != orderB) {
              return orderA.compareTo(orderB);
            }
            return a.compareTo(b);
          });
    return categories;
  }

  static List<String> availableTrees({
    required SkillLibraryData data,
    required String selectedCategory,
    required String allCategoryKey,
  }) {
    return data.skillsByTree.keys
        .where((String treeName) {
          if (selectedCategory == allCategoryKey) {
            return true;
          }
          return data.categoryForTree(treeName) == selectedCategory;
        })
        .toList(growable: false)
      ..sort((String a, String b) => a.compareTo(b));
  }

  static String activeTreeForTreeView({
    required List<String> availableTrees,
    required String selectedTree,
    required String allTreeKey,
  }) {
    if (availableTrees.isEmpty) {
      return '';
    }
    if (selectedTree != allTreeKey && availableTrees.contains(selectedTree)) {
      return selectedTree;
    }
    return availableTrees.first;
  }

  static List<SkillEntry> skillsForTreeView({
    required SkillLibraryData data,
    required String treeName,
    required String query,
  }) {
    if (treeName.isEmpty) {
      return const <SkillEntry>[];
    }

    final String normalizedQuery = query.trim().toLowerCase();
    final List<SkillEntry> source = List<SkillEntry>.from(
      data.skillsByTree[treeName] ?? const <SkillEntry>[],
    )..sort(_compareSkillsByUnlockLevelThenName);

    return source
        .where(
          (SkillEntry skill) => _matchesQuery(
            query: normalizedQuery,
            skill: skill,
            treeName: treeName,
            categoryName: data.categoryForTree(treeName),
          ),
        )
        .toList(growable: false);
  }

  static String activeFilterSummary({
    required String selectedCategory,
    required String selectedTree,
    required String allCategoryKey,
    required String allTreeKey,
  }) {
    final String categoryLabel = selectedCategory == allCategoryKey
        ? 'All Categories'
        : selectedCategory;
    final String treeLabel = selectedTree == allTreeKey
        ? 'All Trees'
        : selectedTree;
    return '$categoryLabel / $treeLabel';
  }

  static bool _matchesQuery({
    required String query,
    required SkillEntry skill,
    required String treeName,
    required String categoryName,
  }) {
    if (query.isEmpty) {
      return true;
    }

    final List<String> searchableFields = <String>[
      skill.name,
      skill.description,
      skill.mp,
      skill.type,
      skill.element,
      skill.combo,
      skill.comboMiddle,
      skill.range,
      treeName,
      categoryName,
      skill.unlockLevel?.toString() ?? '',
    ];
    return searchableFields.any(
      (String field) => field.toLowerCase().contains(query),
    );
  }

  static int _compareSkillsByUnlockLevelThenName(SkillEntry a, SkillEntry b) {
    final int levelDiff = (a.unlockLevel ?? 99).compareTo(b.unlockLevel ?? 99);
    if (levelDiff != 0) {
      return levelDiff;
    }
    return a.name.compareTo(b.name);
  }
}
