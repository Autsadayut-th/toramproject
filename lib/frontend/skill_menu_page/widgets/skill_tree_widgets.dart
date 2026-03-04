import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../skill_menu_page.dart';

class SkillTreeWidgets {
  static Widget buildTreeSelector({
    required List<String> trees,
    required String activeTree,
    required ValueChanged<String> onSelected,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: trees.map((String treeName) {
          final bool selected = treeName == activeTree;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onSelected(treeName),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [Color(0xFF4A4A4A), Color(0xFF3A3A3A)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                        ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF888888)
                        : const Color(0xFF666666),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Text(
                  treeName,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  static Widget buildSkillTreeCanvas({
    required String treeName,
    required List<SkillEntry> skills,
    required ValueChanged<SkillEntry> onTapSkill,
  }) {
    if (skills.isEmpty) {
      return const Center(
        child: Text(
          'No skills found for this tree.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final _SkillTreeLayout layout = _SkillTreeLayout.fromSkills(
      skills,
      treeName: treeName,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0A0D), Color(0xFF17131D)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x44FFFFFF)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Center(
              child: FractionallySizedBox(
                widthFactor: 0.92,
                heightFactor: 0.92,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: layout.width,
                    height: layout.height,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _SkillTreeConnectorPainter(edges: layout.edges),
                          ),
                        ),
                        ...layout.nodes.map((_SkillTreeNodeLayout node) {
                          return Positioned(
                            left: node.center.dx - _SkillTreeLayout.nodeRadius,
                            top: node.center.dy - _SkillTreeLayout.nodeRadius,
                            child: _SkillTreeNode(
                              skill: node.skill,
                              onTap: () => onTapSkill(node.skill),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SkillTreeNode extends StatelessWidget {
  const _SkillTreeNode({
    required this.skill,
    required this.onTap,
  });

  final SkillEntry skill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String imageAssetPath = skill.imageAssetPath.trim();
    return Tooltip(
      message:
          '${skill.name} (Lv ${skill.unlockLevel?.toString() ?? '-'})',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: _SkillTreeLayout.nodeDiameter,
          height: _SkillTreeLayout.nodeDiameter,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFEDEDED)],
            ),
            border: Border.all(color: const Color(0xFFF5F5F5), width: 1.2),
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFFFFF),
            ),
            child: ClipOval(
              child: imageAssetPath.isEmpty
                  ? const Icon(Icons.auto_awesome, color: Color(0xFF6A6A6A), size: 20)
                  : Image.asset(
                      imageAssetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF6A6A6A),
                        size: 20,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillTreeConnectorPainter extends CustomPainter {
  const _SkillTreeConnectorPainter({required this.edges});

  final List<_SkillTreeEdgeLayout> edges;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFFF2F2F2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final Paint jointPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    for (final _SkillTreeEdgeLayout edge in edges) {
      final Offset from = Offset(
        edge.from.center.dx + _SkillTreeLayout.nodeRadius - 1,
        edge.from.center.dy,
      );
      final Offset to = Offset(
        edge.to.center.dx - _SkillTreeLayout.nodeRadius + 1,
        edge.to.center.dy,
      );
      final double midX = (from.dx + to.dx) / 2;

      final Path path = Path()
        ..moveTo(from.dx, from.dy)
        ..lineTo(midX, from.dy)
        ..lineTo(midX, to.dy)
        ..lineTo(to.dx, to.dy);
      canvas.drawPath(path, linePaint);
      canvas.drawCircle(Offset(midX, from.dy), 2.6, jointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SkillTreeConnectorPainter oldDelegate) {
    return oldDelegate.edges != edges;
  }
}

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

  factory _SkillTreeLayout.fromSkills(
    List<SkillEntry> skills, {
    required String treeName,
  }) {
    if (_isBladeTree(treeName)) {
      final _SkillTreeLayout? presetLayout = _buildBladePresetLayout(skills);
      if (presetLayout != null) {
        return presetLayout;
      }
    }
    if (_isShotTree(treeName)) {
      final _SkillTreeLayout? presetLayout = _buildShotPresetLayout(skills);
      if (presetLayout != null) {
        return presetLayout;
      }
    }
    if (_isCrusherTree(treeName)) {
      final _SkillTreeLayout? presetLayout = _buildCrusherPresetLayout(skills);
      if (presetLayout != null) {
        return presetLayout;
      }
    }
    return _buildAutoLayout(skills);
  }

  static bool _isBladeTree(String treeName) {
    return treeName.trim().toLowerCase() == 'blade';
  }

  static bool _isShotTree(String treeName) {
    return treeName.trim().toLowerCase() == 'shot';
  }

  static bool _isCrusherTree(String treeName) {
    return treeName.trim().toLowerCase() == 'crusher';
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
      skillsByLevel[level]!.sort((SkillEntry a, SkillEntry b) {
        final int byName = a.name.compareTo(b.name);
        if (byName != 0) {
          return byName;
        }
        return (a.unlockLevel ?? 99).compareTo(b.unlockLevel ?? 99);
      });
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
        final int sourceIndex =
            (((nextIndex + 0.5) * currentColumn.length) / nextColumn.length)
                .floor()
                .clamp(0, currentColumn.length - 1);
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

  static _SkillTreeLayout? _buildBladePresetLayout(List<SkillEntry> skills) {
    if (skills.isEmpty) {
      return null;
    }

    const Map<String, Offset> bladeGridBySkill = <String, Offset>{
      'hammer slam': Offset(0, 0),
      'cleaving attack': Offset(2, 0),
      'storm blaze': Offset(3, 0),
      'garde blade': Offset(4, 0),
      'ogre slash': Offset(5, 0),
      'hard hit': Offset(0, 2),
      'astute': Offset(1, 1),
      'trigger slash': Offset(2, 1),
      'rampage': Offset(3, 1),
      'meteor breaker': Offset(6, 1),
      'shut-out': Offset(4, 2),
      'lunar slash': Offset(5, 2),
      'sonic blade': Offset(1, 3),
      'spiral air': Offset(2, 3),
      'sword tempest': Offset(3, 3),
      'buster blade': Offset(4, 4),
      'aura blade': Offset(5, 4),
      'sword mastery': Offset(0, 5),
      'quick slash': Offset(1, 5),
      'sword techniques': Offset(2, 5),
      'war cry': Offset(3, 6),
      'berserk': Offset(4, 6),
      'gladiate': Offset(5, 6),
      'swift attack': Offset(3, 8),
    };

    const List<List<String>> bladeEdgesByName = <List<String>>[
      <String>['hammer slam', 'cleaving attack'],
      <String>['cleaving attack', 'storm blaze'],
      <String>['storm blaze', 'garde blade'],
      <String>['garde blade', 'ogre slash'],
      <String>['hard hit', 'astute'],
      <String>['astute', 'trigger slash'],
      <String>['trigger slash', 'rampage'],
      <String>['rampage', 'meteor breaker'],
      <String>['trigger slash', 'shut-out'],
      <String>['shut-out', 'lunar slash'],
      <String>['hard hit', 'sonic blade'],
      <String>['sonic blade', 'spiral air'],
      <String>['spiral air', 'sword tempest'],
      <String>['sword tempest', 'buster blade'],
      <String>['buster blade', 'aura blade'],
      <String>['sword mastery', 'quick slash'],
      <String>['quick slash', 'sword techniques'],
      <String>['sword techniques', 'war cry'],
      <String>['war cry', 'berserk'],
      <String>['berserk', 'gladiate'],
    ];

    final List<SkillEntry> orderedSkills = List<SkillEntry>.from(skills)
      ..sort((SkillEntry a, SkillEntry b) {
        final int byLevel = (a.unlockLevel ?? 99).compareTo(b.unlockLevel ?? 99);
        if (byLevel != 0) {
          return byLevel;
        }
        return a.name.compareTo(b.name);
      });

    final List<_SkillTreeNodeLayout> nodes = <_SkillTreeNodeLayout>[];
    final Map<String, _SkillTreeNodeLayout> nodeByName = <String, _SkillTreeNodeLayout>{};
    final List<Offset> usedGridPoints = <Offset>[];
    int fallbackIndex = 0;

    for (final SkillEntry skill in orderedSkills) {
      final String normalizedName = _normalizeSkillName(skill.name);
      Offset gridPoint =
          bladeGridBySkill[normalizedName] ??
          Offset(
            (7 + (fallbackIndex % 2)).toDouble(),
            (2 + (fallbackIndex ~/ 2)).toDouble(),
          );
      if (!bladeGridBySkill.containsKey(normalizedName)) {
        fallbackIndex++;
      }
      usedGridPoints.add(gridPoint);
      final _SkillTreeNodeLayout node = _SkillTreeNodeLayout(
        skill: skill,
        center: _centerFromGrid(gridPoint),
        column: gridPoint.dx.toInt(),
      );
      nodes.add(node);
      nodeByName[normalizedName] = node;
    }

    final List<_SkillTreeEdgeLayout> edges = <_SkillTreeEdgeLayout>[];
    for (final List<String> pair in bladeEdgesByName) {
      if (pair.length != 2) {
        continue;
      }
      final _SkillTreeNodeLayout? fromNode = nodeByName[pair[0]];
      final _SkillTreeNodeLayout? toNode = nodeByName[pair[1]];
      if (fromNode == null || toNode == null) {
        continue;
      }
      edges.add(_SkillTreeEdgeLayout(from: fromNode, to: toNode));
    }

    final int maxCol = usedGridPoints
        .map((Offset point) => point.dx.toInt())
        .fold<int>(0, math.max);
    final int maxRow = usedGridPoints
        .map((Offset point) => point.dy.toInt())
        .fold<int>(0, math.max);

    final double width =
        horizontalPadding * 2 + nodeDiameter + maxCol * horizontalGap;
    final double height =
        verticalPadding * 2 + nodeDiameter + maxRow * verticalGap;

    return _SkillTreeLayout(
      width: width,
      height: height,
      nodes: nodes,
      edges: edges,
    );
  }

  static _SkillTreeLayout? _buildShotPresetLayout(List<SkillEntry> skills) {
    if (skills.isEmpty) {
      return null;
    }

    const Map<String, Offset> shotGridBySkill = <String, Offset>{
      'power shot': Offset(0, 2),
      'bullseye': Offset(1, 2),
      'arrow rain': Offset(2, 2),
      'snipe': Offset(4, 2),
      'cross fire': Offset(6, 2),
      'piercing shot': Offset(5, 1),
      'vanquisher': Offset(6, 1),
      'twin storm': Offset(5, 3),
      'retrograde shot': Offset(5, 0),
      'quick loader': Offset(4, 0),
      'moeba shot': Offset(1, 4),
      'paralysis shot': Offset(2, 4),
      'smoke dust': Offset(3, 4),
      'arm break': Offset(4, 4),
      'parabola cannon': Offset(6, 4),
      'spread shot': Offset(5, 5),
      'shot mastery': Offset(0, 6),
      'long range': Offset(2, 6),
      'quick draw': Offset(3, 6),
      'decoy shot': Offset(4, 6),
      'element starter': Offset(6, 6),
      'samurai archery': Offset(5, 7),
      'sneak attack': Offset(1, 8),
      'hunting buddy': Offset(4, 8),
      'fatal shot': Offset(3, 9),
    };

    const List<List<String>> shotEdgesByName = <List<String>>[
      <String>['power shot', 'bullseye'],
      <String>['bullseye', 'arrow rain'],
      <String>['arrow rain', 'snipe'],
      <String>['snipe', 'cross fire'],
      <String>['snipe', 'piercing shot'],
      <String>['piercing shot', 'vanquisher'],
      <String>['snipe', 'twin storm'],
      <String>['quick loader', 'retrograde shot'],
      <String>['bullseye', 'quick loader'],
      <String>['bullseye', 'moeba shot'],
      <String>['moeba shot', 'paralysis shot'],
      <String>['paralysis shot', 'smoke dust'],
      <String>['smoke dust', 'arm break'],
      <String>['arm break', 'parabola cannon'],
      <String>['arm break', 'spread shot'],
      <String>['shot mastery', 'long range'],
      <String>['long range', 'quick draw'],
      <String>['quick draw', 'decoy shot'],
      <String>['decoy shot', 'element starter'],
      <String>['decoy shot', 'samurai archery'],
      <String>['shot mastery', 'sneak attack'],
      <String>['sneak attack', 'hunting buddy'],
      <String>['sneak attack', 'fatal shot'],
    ];

    final List<SkillEntry> orderedSkills = List<SkillEntry>.from(skills)
      ..sort((SkillEntry a, SkillEntry b) {
        final int byLevel = (a.unlockLevel ?? 99).compareTo(b.unlockLevel ?? 99);
        if (byLevel != 0) {
          return byLevel;
        }
        return a.name.compareTo(b.name);
      });

    final List<_SkillTreeNodeLayout> nodes = <_SkillTreeNodeLayout>[];
    final Map<String, _SkillTreeNodeLayout> nodeByName =
        <String, _SkillTreeNodeLayout>{};
    final List<Offset> usedGridPoints = <Offset>[];
    int fallbackIndex = 0;

    for (final SkillEntry skill in orderedSkills) {
      final String normalizedName = _normalizeSkillName(skill.name);
      final Offset gridPoint =
          shotGridBySkill[normalizedName] ??
          Offset(
            (7 + (fallbackIndex % 2)).toDouble(),
            (2 + (fallbackIndex ~/ 2)).toDouble(),
          );
      if (!shotGridBySkill.containsKey(normalizedName)) {
        fallbackIndex++;
      }
      usedGridPoints.add(gridPoint);
      final _SkillTreeNodeLayout node = _SkillTreeNodeLayout(
        skill: skill,
        center: _centerFromGrid(gridPoint),
        column: gridPoint.dx.toInt(),
      );
      nodes.add(node);
      nodeByName[normalizedName] = node;
    }

    final List<_SkillTreeEdgeLayout> edges = <_SkillTreeEdgeLayout>[];
    for (final List<String> pair in shotEdgesByName) {
      if (pair.length != 2) {
        continue;
      }
      final _SkillTreeNodeLayout? fromNode = nodeByName[pair[0]];
      final _SkillTreeNodeLayout? toNode = nodeByName[pair[1]];
      if (fromNode == null || toNode == null) {
        continue;
      }
      edges.add(_SkillTreeEdgeLayout(from: fromNode, to: toNode));
    }

    final int maxCol = usedGridPoints
        .map((Offset point) => point.dx.toInt())
        .fold<int>(0, math.max);
    final int maxRow = usedGridPoints
        .map((Offset point) => point.dy.toInt())
        .fold<int>(0, math.max);

    final double width =
        horizontalPadding * 2 + nodeDiameter + maxCol * horizontalGap;
    final double height =
        verticalPadding * 2 + nodeDiameter + maxRow * verticalGap;

    return _SkillTreeLayout(
      width: width,
      height: height,
      nodes: nodes,
      edges: edges,
    );
  }

  static _SkillTreeLayout? _buildCrusherPresetLayout(List<SkillEntry> skills) {
    if (skills.isEmpty) {
      return null;
    }

    const Map<String, Offset> crusherGridBySkill = <String, Offset>{
      'forefist punch': Offset(0, 0),
      'goliath punch': Offset(1, 0),
      'god hand': Offset(2, 0),
      'divine rigid body': Offset(3, 0),
      'breathwork': Offset(0, 2),
      'combination': Offset(1, 2),
      'terrablast': Offset(3, 2),
      'floating kick': Offset(1, 3),
      'annihilator': Offset(2, 3),
      'geyser kick': Offset(3, 3),
    };

    const List<List<String>> crusherEdgesByName = <List<String>>[
      <String>['forefist punch', 'goliath punch'],
      <String>['goliath punch', 'god hand'],
      <String>['god hand', 'divine rigid body'],
      <String>['breathwork', 'combination'],
      <String>['combination', 'terrablast'],
      <String>['breathwork', 'floating kick'],
      <String>['floating kick', 'annihilator'],
      <String>['annihilator', 'geyser kick'],
    ];

    final List<SkillEntry> orderedSkills = List<SkillEntry>.from(skills)
      ..sort((SkillEntry a, SkillEntry b) {
        final int byLevel = (a.unlockLevel ?? 99).compareTo(b.unlockLevel ?? 99);
        if (byLevel != 0) {
          return byLevel;
        }
        return a.name.compareTo(b.name);
      });

    final List<_SkillTreeNodeLayout> nodes = <_SkillTreeNodeLayout>[];
    final Map<String, _SkillTreeNodeLayout> nodeByName =
        <String, _SkillTreeNodeLayout>{};
    final List<Offset> usedGridPoints = <Offset>[];
    int fallbackIndex = 0;

    for (final SkillEntry skill in orderedSkills) {
      final String normalizedName = _normalizeSkillName(skill.name);
      final Offset gridPoint =
          crusherGridBySkill[normalizedName] ??
          Offset(
            (5 + (fallbackIndex % 2)).toDouble(),
            (1 + (fallbackIndex ~/ 2)).toDouble(),
          );
      if (!crusherGridBySkill.containsKey(normalizedName)) {
        fallbackIndex++;
      }
      usedGridPoints.add(gridPoint);
      final _SkillTreeNodeLayout node = _SkillTreeNodeLayout(
        skill: skill,
        center: _centerFromGrid(gridPoint),
        column: gridPoint.dx.toInt(),
      );
      nodes.add(node);
      nodeByName[normalizedName] = node;
    }

    final List<_SkillTreeEdgeLayout> edges = <_SkillTreeEdgeLayout>[];
    for (final List<String> pair in crusherEdgesByName) {
      if (pair.length != 2) {
        continue;
      }
      final _SkillTreeNodeLayout? fromNode = nodeByName[pair[0]];
      final _SkillTreeNodeLayout? toNode = nodeByName[pair[1]];
      if (fromNode == null || toNode == null) {
        continue;
      }
      edges.add(_SkillTreeEdgeLayout(from: fromNode, to: toNode));
    }

    final int maxCol = usedGridPoints
        .map((Offset point) => point.dx.toInt())
        .fold<int>(0, math.max);
    final int maxRow = usedGridPoints
        .map((Offset point) => point.dy.toInt())
        .fold<int>(0, math.max);

    final double width =
        horizontalPadding * 2 + nodeDiameter + maxCol * horizontalGap;
    final double height =
        verticalPadding * 2 + nodeDiameter + maxRow * verticalGap;

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

  static String _normalizeSkillName(String value) {
    return value.trim().toLowerCase();
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
  });

  final _SkillTreeNodeLayout from;
  final _SkillTreeNodeLayout to;
}
