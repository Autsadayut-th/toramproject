part of 'skill_menu_page.dart';

extension _SkillMenuPageUI on _SkillMenuPageState {
  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 36, color: Colors.white70),
            const SizedBox(height: 12),
            const Text(
              'Failed to load skill data.',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
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
      return const Center(
        child: Text(
          'No skill tree available for selected category.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${data.categoryForTree(activeTree)} / $activeTree | ${visibleSkills.length} skill(s)',
              style: const TextStyle(
                color: Colors.white70,
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
          ),
        ),
      ],
    );
  }
}
