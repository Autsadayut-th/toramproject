part of 'skill_tree_widgets.dart';

typedef _PresetBuilder = _SkillTreeLayout? Function(List<SkillEntry> skills);

class _SkillTreeLayout {
  const _SkillTreeLayout({
    required this.width,
    required this.height,
    required this.nodes,
    required this.edges,
  });

  static const double nodeDiameter = 58;
  static const double nodeRadius = nodeDiameter / 2;
  static const double horizontalGap = 122;
  static const double verticalGap = 102;
  static const double horizontalPadding = 42;
  static const double verticalPadding = 36;

  final double width;
  final double height;
  final List<_SkillTreeNodeLayout> nodes;
  final List<_SkillTreeEdgeLayout> edges;

  static final Map<String, _PresetBuilder> _presetBuilders =
      <String, _PresetBuilder>{
        'blade': _buildBladePresetLayout,
        'shot': _buildShotPresetLayout,
        'crusher': _buildCrusherPresetLayout,
        'magic': _buildMagicPresetLayout,
        'dualsword': _buildDualSwordPresetLayout,
        'halberd': _buildHalberdPresetLayout,
        'mononofu': _buildMononofuPresetLayout,
        'sprite': _buildSpritePresetLayout,
        'martial': _buildMartialPresetLayout,
        'barehand': _buildBarehandPresetLayout,
      };

  factory _SkillTreeLayout.fromSkills(
    List<SkillEntry> skills, {
    required String treeName,
  }) {
    final String normalizedTreeName = _normalizeSkillName(treeName);
    final _PresetBuilder? presetBuilder = _presetBuilders[normalizedTreeName];
    if (presetBuilder != null) {
      final _SkillTreeLayout? presetLayout = presetBuilder(skills);
      if (presetLayout != null) {
        return presetLayout;
      }
    }
    return _buildAutoLayout(skills);
  }

  static _SkillTreeLayout _buildAutoLayout(List<SkillEntry> skills) {
    final Map<int, List<SkillEntry>> skillsByLevel = <int, List<SkillEntry>>{};
    for (final SkillEntry skill in skills) {
      final int level = skill.unlockLevel ?? 99;
      skillsByLevel.putIfAbsent(level, () => <SkillEntry>[]).add(skill);
    }

    final List<int> sortedLevels = skillsByLevel.keys.toList(growable: false)
      ..sort((int a, int b) => a.compareTo(b));
    if (sortedLevels.isEmpty) {
      return const _SkillTreeLayout(
        width: nodeDiameter,
        height: nodeDiameter,
        nodes: <_SkillTreeNodeLayout>[],
        edges: <_SkillTreeEdgeLayout>[],
      );
    }

    for (final int level in sortedLevels) {
      skillsByLevel[level] = _sortedByUnlockThenName(skillsByLevel[level]!);
    }

    final int maxNodesInLevel = sortedLevels
        .map((int level) => skillsByLevel[level]!.length)
        .fold<int>(1, math.max);

    final double width =
        horizontalPadding * 2 +
        nodeDiameter +
        (sortedLevels.length - 1) * horizontalGap;
    final double height =
        verticalPadding * 2 +
        nodeDiameter +
        (maxNodesInLevel - 1) * verticalGap;

    final List<_SkillTreeNodeLayout> nodes = <_SkillTreeNodeLayout>[];
    final Map<int, List<_SkillTreeNodeLayout>> nodesByColumn =
        <int, List<_SkillTreeNodeLayout>>{};

    for (int colIndex = 0; colIndex < sortedLevels.length; colIndex++) {
      final int level = sortedLevels[colIndex];
      final List<SkillEntry> levelSkills = skillsByLevel[level]!;
      final double laneHeight = (levelSkills.length - 1) * verticalGap;
      final double maxLaneHeight = (maxNodesInLevel - 1) * verticalGap;
      final double startY =
          verticalPadding + nodeRadius + (maxLaneHeight - laneHeight) / 2;
      final double centerX =
          horizontalPadding + nodeRadius + colIndex * horizontalGap;

      final List<_SkillTreeNodeLayout> columnNodes = <_SkillTreeNodeLayout>[];
      for (int rowIndex = 0; rowIndex < levelSkills.length; rowIndex++) {
        final _SkillTreeNodeLayout node = _SkillTreeNodeLayout(
          skill: levelSkills[rowIndex],
          center: Offset(centerX, startY + rowIndex * verticalGap),
          column: colIndex,
        );
        columnNodes.add(node);
        nodes.add(node);
      }
      nodesByColumn[colIndex] = columnNodes;
    }

    final List<_SkillTreeEdgeLayout> edges = <_SkillTreeEdgeLayout>[];
    final Set<String> seenEdges = <String>{};
    for (int colIndex = 0; colIndex < sortedLevels.length - 1; colIndex++) {
      final List<_SkillTreeNodeLayout> currentColumn =
          nodesByColumn[colIndex] ?? const <_SkillTreeNodeLayout>[];
      final List<_SkillTreeNodeLayout> nextColumn =
          nodesByColumn[colIndex + 1] ?? const <_SkillTreeNodeLayout>[];
      if (currentColumn.isEmpty || nextColumn.isEmpty) {
        continue;
      }

      for (int nextIndex = 0; nextIndex < nextColumn.length; nextIndex++) {
        final int sourceIndex = _sourceIndexForEdge(
          nextIndex: nextIndex,
          sourceCount: currentColumn.length,
          targetCount: nextColumn.length,
        );
        final _SkillTreeNodeLayout source = currentColumn[sourceIndex];
        final _SkillTreeNodeLayout target = nextColumn[nextIndex];
        final String key = '${source.skill.name}->${target.skill.name}';
        if (seenEdges.add(key)) {
          edges.add(_SkillTreeEdgeLayout(from: source, to: target));
        }
      }
    }

    return _SkillTreeLayout(
      width: width,
      height: height,
      nodes: nodes,
      edges: edges,
    );
  }

  static Offset _centerFromGrid(Offset gridPoint) {
    return Offset(
      horizontalPadding + nodeRadius + gridPoint.dx * horizontalGap,
      verticalPadding + nodeRadius + gridPoint.dy * verticalGap,
    );
  }

  static double _centerXFromGrid(double gridX) {
    return horizontalPadding + nodeRadius + gridX * horizontalGap;
  }

  static String _normalizeSkillName(String value) {
    return value.trim().toLowerCase();
  }

  static int _sourceIndexForEdge({
    required int nextIndex,
    required int sourceCount,
    required int targetCount,
  }) {
    return (((nextIndex + 0.5) * sourceCount) / targetCount).floor().clamp(
      0,
      sourceCount - 1,
    );
  }

  static List<SkillEntry> _sortedByUnlockThenName(Iterable<SkillEntry> skills) {
    final List<SkillEntry> sorted = List<SkillEntry>.from(skills)
      ..sort((SkillEntry a, SkillEntry b) {
        final int byLevel = (a.unlockLevel ?? 99).compareTo(
          b.unlockLevel ?? 99,
        );
        if (byLevel != 0) {
          return byLevel;
        }
        return a.name.compareTo(b.name);
      });
    return sorted;
  }
}

class _SkillTreeNodeLayout {
  const _SkillTreeNodeLayout({
    required this.skill,
    required this.center,
    required this.column,
  });

  final SkillEntry skill;
  final Offset center;
  final int column;
}

class _SkillTreeEdgeLayout {
  const _SkillTreeEdgeLayout({
    required this.from,
    required this.to,
    this.bendX,
  });

  final _SkillTreeNodeLayout from;
  final _SkillTreeNodeLayout to;
  final double? bendX;
}
