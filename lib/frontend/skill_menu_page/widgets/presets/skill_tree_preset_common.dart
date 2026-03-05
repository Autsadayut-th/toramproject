part of '../skill_tree_widgets.dart';

_SkillTreeLayout? _buildGenericPresetLayout({
  required List<SkillEntry> skills,
  required Map<String, Offset> gridBySkill,
  required List<List<String>> edgesByName,
  required Map<String, double> edgeBendGridByPair,
  required int fallbackStartColumn,
  required int fallbackStartRow,
}) {
  if (skills.isEmpty) {
    return null;
  }

  final List<SkillEntry> orderedSkills =
      _SkillTreeLayout._sortedByUnlockThenName(skills);

  final List<_SkillTreeNodeLayout> nodes = <_SkillTreeNodeLayout>[];
  final Map<String, _SkillTreeNodeLayout> nodeByName =
      <String, _SkillTreeNodeLayout>{};
  final List<Offset> usedGridPoints = <Offset>[];
  int fallbackIndex = 0;

  for (final SkillEntry skill in orderedSkills) {
    final String normalizedName = _SkillTreeLayout._normalizeSkillName(
      skill.name,
    );
    final Offset gridPoint =
        gridBySkill[normalizedName] ??
        Offset(
          (fallbackStartColumn + (fallbackIndex % 2)).toDouble(),
          (fallbackStartRow + (fallbackIndex ~/ 2)).toDouble(),
        );
    if (!gridBySkill.containsKey(normalizedName)) {
      fallbackIndex++;
    }
    usedGridPoints.add(gridPoint);
    final _SkillTreeNodeLayout node = _SkillTreeNodeLayout(
      skill: skill,
      center: _SkillTreeLayout._centerFromGrid(gridPoint),
      column: gridPoint.dx.toInt(),
    );
    nodes.add(node);
    nodeByName[normalizedName] = node;
  }

  final List<_SkillTreeEdgeLayout> edges = <_SkillTreeEdgeLayout>[];
  for (final List<String> pair in edgesByName) {
    if (pair.length != 2) {
      continue;
    }
    final _SkillTreeNodeLayout? fromNode = nodeByName[pair[0]];
    final _SkillTreeNodeLayout? toNode = nodeByName[pair[1]];
    if (fromNode == null || toNode == null) {
      continue;
    }
    final String edgeKey = '${pair[0]}->${pair[1]}';
    final double? bendGrid = edgeBendGridByPair[edgeKey];
    edges.add(
      _SkillTreeEdgeLayout(
        from: fromNode,
        to: toNode,
        bendX: bendGrid == null
            ? null
            : _SkillTreeLayout._centerXFromGrid(bendGrid),
      ),
    );
  }

  final int maxCol = usedGridPoints
      .map((Offset point) => point.dx.toInt())
      .fold<int>(0, math.max);
  final int maxRow = usedGridPoints
      .map((Offset point) => point.dy.toInt())
      .fold<int>(0, math.max);

  final double width =
      _SkillTreeLayout.horizontalPadding * 2 +
      _SkillTreeLayout.nodeDiameter +
      maxCol * _SkillTreeLayout.horizontalGap;
  final double height =
      _SkillTreeLayout.verticalPadding * 2 +
      _SkillTreeLayout.nodeDiameter +
      maxRow * _SkillTreeLayout.verticalGap;

  return _SkillTreeLayout(
    width: width,
    height: height,
    nodes: nodes,
    edges: edges,
  );
}
