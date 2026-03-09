part of 'skill_menu_page.dart';

extension _SkillMenuPageUI on _SkillMenuPageState {
  Widget _buildErrorState(Object error) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 36,
              color: colorScheme.onSurface.withValues(alpha: 0.75),
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load skill data.',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.62),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillTreeView({
    required SkillLibraryData data,
    required List<String> availableTrees,
    required String activeTree,
    required List<SkillEntry> visibleSkills,
  }) {
    if (availableTrees.isEmpty || activeTree.isEmpty) {
      final ColorScheme colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Text(
          'No skill tree available for selected category.',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
      );
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${data.categoryForTree(activeTree)} / $activeTree | ${visibleSkills.length} skill(s)',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.75),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: SkillTreeWidgets.buildSkillTreeCanvas(
            treeName: activeTree,
            skills: visibleSkills,
            onTapSkill: (SkillEntry skill) {
              SkillCardWidgets.showSkillDetails(
                context,
                skill: skill,
                categoryName: data.categoryForTree(activeTree),
                treeName: activeTree,
                present: _present,
              );
            },
            context: context,
          ),
        ),
      ],
    );
  }
}
