part of '../skill_tree_widgets.dart';

_SkillTreeLayout? _buildMagicPresetLayout(List<SkillEntry> skills) {
  const Map<String, Offset> magicGridBySkill = <String, Offset>{
    'magic: arrows': Offset(0, 2),
    'magic: javelin': Offset(1, 0),
    'magic: lances': Offset(2, 0),
    'magic: impact': Offset(3, 0),
    'magic: finale': Offset(4, 0),
    'chronos shift': Offset(5, 0),
    'magic: wall': Offset(1, 1),
    'magic: blast': Offset(2, 1),
    'magic: storm': Offset(3, 1),
    'magic: burst': Offset(4, 1),
    'magic: magic cannon': Offset(5, 1),
    'magic: crash': Offset(6, 1),
    'magic: laser': Offset(6, 0),
    'magic: guardian beam': Offset(6, 2),
    'magic mastery': Offset(0, 4),
    'magic knife': Offset(1, 4),
    'qadal': Offset(2, 4),
    'spell calibration': Offset(3, 4),
    'enchanted barrier': Offset(4, 4),
    'mp charge': Offset(0, 6),
    'chain cast': Offset(1, 6),
    'power wave': Offset(2, 6),
    'maximizer': Offset(3, 6),
    'rapid charge': Offset(4, 7),
  };

  const List<List<String>> magicEdgesByName = <List<String>>[
    <String>['magic: arrows', 'magic: javelin'],
    <String>['magic: arrows', 'magic: wall'],
    <String>['magic: javelin', 'magic: lances'],
    <String>['magic: lances', 'magic: impact'],
    <String>['magic: impact', 'magic: finale'],
    <String>['magic: finale', 'chronos shift'],
    <String>['magic: wall', 'magic: blast'],
    <String>['magic: blast', 'magic: storm'],
    <String>['magic: storm', 'magic: burst'],
    <String>['magic: burst', 'magic: magic cannon'],
    <String>['magic: magic cannon', 'magic: crash'],
    <String>['magic: magic cannon', 'magic: laser'],
    <String>['magic: impact', 'magic: guardian beam'],
    <String>['magic mastery', 'magic knife'],
    <String>['magic knife', 'qadal'],
    <String>['qadal', 'spell calibration'],
    <String>['spell calibration', 'enchanted barrier'],
    <String>['mp charge', 'chain cast'],
    <String>['chain cast', 'power wave'],
    <String>['power wave', 'maximizer'],
    <String>['maximizer', 'rapid charge'],
  ];

  const Map<String, double> magicEdgeBendGridByPair = <String, double>{
    'magic: arrows->magic: javelin': 0.55,
    'magic: arrows->magic: wall': 0.55,
    'magic: magic cannon->magic: laser': 5.55,
    'magic: impact->magic: guardian beam': 3.05,
    'maximizer->rapid charge': 3.05,
  };

  return _buildGenericPresetLayout(
    skills: skills,
    gridBySkill: magicGridBySkill,
    edgesByName: magicEdgesByName,
    edgeBendGridByPair: magicEdgeBendGridByPair,
    fallbackStartColumn: 7,
    fallbackStartRow: 2,
  );
}
