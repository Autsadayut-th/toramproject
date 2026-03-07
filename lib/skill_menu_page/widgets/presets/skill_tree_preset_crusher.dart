part of '../skill_tree_widgets.dart';

_SkillTreeLayout? _buildCrusherPresetLayout(List<SkillEntry> skills) {
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

  const Map<String, double> crusherEdgeBendGridByPair = <String, double>{
    'breathwork->floating kick': 0.55,
  };

  return _buildGenericPresetLayout(
    skills: skills,
    gridBySkill: crusherGridBySkill,
    edgesByName: crusherEdgesByName,
    edgeBendGridByPair: crusherEdgeBendGridByPair,
    fallbackStartColumn: 5,
    fallbackStartRow: 1,
  );
}
