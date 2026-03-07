part of '../skill_tree_widgets.dart';

_SkillTreeLayout? _buildBladePresetLayout(List<SkillEntry> skills) {
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
    <String>['spiral air', 'buster blade'],
    <String>['buster blade', 'aura blade'],
    <String>['sword mastery', 'quick slash'],
    <String>['quick slash', 'sword techniques'],
    <String>['quick slash', 'war cry'],
    <String>['war cry', 'berserk'],
    <String>['berserk', 'gladiate'],
  ];

  const Map<String, double> bladeEdgeBendGridByPair = <String, double>{
    'trigger slash->shut-out': 2.55,
    'spiral air->buster blade': 2.55,
    'quick slash->war cry': 1.55,
  };

  return _buildGenericPresetLayout(
    skills: skills,
    gridBySkill: bladeGridBySkill,
    edgesByName: bladeEdgesByName,
    edgeBendGridByPair: bladeEdgeBendGridByPair,
    fallbackStartColumn: 7,
    fallbackStartRow: 2,
  );
}
