import 'package:flutter/material.dart';

import '../skill_menu_page.dart';

class SkillFilterWidgets {
  static Widget buildCustomChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: <Color>[
                    scheme.primaryContainer,
                    scheme.primaryContainer.withValues(alpha: 0.82),
                  ],
                )
              : LinearGradient(
                  colors: <Color>[
                    scheme.surfaceContainerHigh,
                    scheme.surfaceContainerHighest,
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.7)
                : scheme.onSurface.withValues(alpha: 0.32),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.onSurface.withValues(alpha: 0.24),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? scheme.onPrimaryContainer
                : scheme.onSurface.withValues(alpha: 0.82),
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Widget buildCategoryFilter(
    BuildContext context,
    SkillLibraryData data,
    String selectedCategory,
    List<String> availableCategories,
    Function(String) onCategorySelected,
  ) {
    const String allCategoryKey = '__all_category__';
    final List<String> options = <String>[
      allCategoryKey,
      ...availableCategories,
    ];
    final String selected = options.contains(selectedCategory)
        ? selectedCategory
        : allCategoryKey;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options
          .map((String category) {
            final bool isAll = category == allCategoryKey;
            final String label = isAll ? 'All Categories' : category;
            final int count = isAll
                ? data.totalSkills
                : data.totalSkillsInCategory(category);
            return buildCustomChip(
              context: context,
              label: '$label ($count)',
              selected: selected == category,
              onSelected: () => onCategorySelected(category),
            );
          })
          .toList(growable: false),
    );
  }

  static Widget buildTreeFilter(
    BuildContext context,
    SkillLibraryData data,
    String selectedCategory,
    String selectedTree,
    List<String> availableTrees,
    Function(String) onTreeSelected,
  ) {
    const String allTreeKey = '__all_tree__';
    final List<String> options = <String>[allTreeKey, ...availableTrees];
    final String selected = options.contains(selectedTree)
        ? selectedTree
        : allTreeKey;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options
          .map((String tree) {
            final bool isAll = tree == allTreeKey;
            final String label = isAll ? 'All Trees' : tree;
            final int count = isAll
                ? (selectedCategory == '__all_category__'
                      ? data.totalSkills
                      : data.totalSkillsInCategory(selectedCategory))
                : (data.skillsByTree[tree]?.length ?? 0);
            return buildCustomChip(
              context: context,
              label: '$label ($count)',
              selected: selected == tree,
              onSelected: () => onTreeSelected(tree),
            );
          })
          .toList(growable: false),
    );
  }

  static Widget buildMetaPanel(
    BuildContext context,
    SkillLibraryData data,
    int resultCount,
    int currentPage,
    int totalPages,
  ) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            scheme.surfaceContainerHigh,
            scheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.onSurface.withValues(alpha: 0.32),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withValues(alpha: 0.26),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skill Library',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total Skills: ${data.totalSkills} | Showing: $resultCount | Page: $currentPage/$totalPages',
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.75),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
