part of '../skill_tree_widgets.dart';

_SkillTreeLayout? _buildBarehandPresetLayout(List<SkillEntry> skills) {
  if (skills.isEmpty) {
    return null;
  }
  return _SkillTreeLayout._buildAutoLayout(skills);
}
