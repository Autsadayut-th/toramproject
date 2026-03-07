part of '../skill_tree_widgets.dart';

_SkillTreeLayout? _buildShotPresetLayout(List<SkillEntry> skills) {
  const Map<String, Offset> shotGridBySkill = <String, Offset>{
    'power shot': Offset(0, 3),
    'bullseye': Offset(1, 3),
    'arrow rain': Offset(2, 3),
    'snipe': Offset(4, 3),
    'cross fire': Offset(6, 1),
    'piercing shot': Offset(5, 2),
    'vanquisher': Offset(6, 3),
    'twin storm': Offset(5, 5),
    'retrograde shot': Offset(5, 0),
    'quick loader': Offset(3, 1),
    'moeba shot': Offset(1, 4),
    'paralysis shot': Offset(2, 4),
    'smoke dust': Offset(3, 4),
    'arm break': Offset(4, 4),
    'parabola cannon': Offset(6, 4),
    'spread shot': Offset(5, 6),
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
    <String>['bullseye', 'quick loader'],
    <String>['quick loader', 'cross fire'],
    <String>['quick loader', 'retrograde shot'],
    <String>['snipe', 'piercing shot'],
    <String>['snipe', 'vanquisher'],
    <String>['snipe', 'twin storm'],
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

  const Map<String, double> shotEdgeBendGridByPair = <String, double>{
    'bullseye->quick loader': 1.3,
    'quick loader->retrograde shot': 3.05,
    'snipe->piercing shot': 4.95,
    'snipe->vanquisher': 4.95,
    'snipe->twin storm': 4.95,
    'arm break->spread shot': 4.95,
    'shot mastery->sneak attack': 0.05,
    'sneak attack->fatal shot': 0.05,
  };

  return _buildGenericPresetLayout(
    skills: skills,
    gridBySkill: shotGridBySkill,
    edgesByName: shotEdgesByName,
    edgeBendGridByPair: shotEdgeBendGridByPair,
    fallbackStartColumn: 7,
    fallbackStartRow: 2,
  );
}
