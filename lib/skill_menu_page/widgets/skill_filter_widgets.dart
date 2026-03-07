import 'package:flutter/material.dart';

import '../skill_menu_page.dart';

class SkillFilterWidgets {
  static Widget buildCustomChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [const Color(0xFF4A4A4A), const Color(0xFF3A3A3A)],
                )
              : LinearGradient(
                  colors: [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF888888) : const Color(0xFF666666),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            shadows: selected
                ? [
                    const Shadow(
                      color: Colors.black,
                      offset: Offset(1, 1),
                      blurRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  static Widget buildCategoryFilter(
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
              label: '$label ($count)',
              selected: selected == category,
              onSelected: () => onCategorySelected(category),
            );
          })
          .toList(growable: false),
    );
  }

  static Widget buildTreeFilter(
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
              label: '$label ($count)',
              selected: selected == tree,
              onSelected: () => onTreeSelected(tree),
            );
          })
          .toList(growable: false),
    );
  }

  static Widget buildMetaPanel(
    SkillLibraryData data,
    int resultCount,
    int currentPage,
    int totalPages,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF666666), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total Skills: ${data.totalSkills} | Showing: $resultCount | Page: $currentPage/$totalPages',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
