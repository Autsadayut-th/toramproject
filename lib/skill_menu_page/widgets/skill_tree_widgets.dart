import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../skill_menu_page.dart';

part 'skill_tree_canvas.dart';
part 'skill_tree_layout.dart';
part 'presets/skill_tree_preset_common.dart';
part 'presets/skill_tree_preset_blade.dart';
part 'presets/skill_tree_preset_shot.dart';
part 'presets/skill_tree_preset_crusher.dart';
part 'presets/skill_tree_preset_magic.dart';
part 'presets/skill_tree_preset_dualsword.dart';
part 'presets/skill_tree_preset_halberd.dart';
part 'presets/skill_tree_preset_mononofu.dart';
part 'presets/skill_tree_preset_sprite.dart';
part 'presets/skill_tree_preset_martial.dart';
part 'presets/skill_tree_preset_barehand.dart';

class SkillTreeWidgets {
  static Widget buildTreeSelector({
    required List<String> trees,
    required String activeTree,
    required ValueChanged<String> onSelected,
    required BuildContext context,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: trees
            .map((String treeName) {
              final bool selected = treeName == activeTree;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => onSelected(treeName),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? LinearGradient(
                              colors: <Color>[
                                colorScheme.primaryContainer,
                                colorScheme.primaryContainer.withValues(
                                  alpha: 0.8,
                                ),
                              ],
                            )
                          : LinearGradient(
                              colors: <Color>[
                                colorScheme.surfaceContainerHigh,
                                colorScheme.surfaceContainerHighest,
                              ],
                            ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.3),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      treeName,
                      style: TextStyle(
                        color: selected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface.withValues(alpha: 0.75),
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }

  static Widget buildSkillTreeCanvas({
    required String treeName,
    required List<SkillEntry> skills,
    required ValueChanged<SkillEntry> onTapSkill,
    required BuildContext context,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (skills.isEmpty) {
      return Center(
        child: Text(
          'No skills found for this tree.',
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.75)),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surfaceContainerHigh,
            colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.24)),
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
                            painter: _SkillTreeConnectorPainter(
                              edges: layout.edges,
                              lineColor: colorScheme.onSurface.withValues(
                                alpha: 0.75,
                              ),
                            ),
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
