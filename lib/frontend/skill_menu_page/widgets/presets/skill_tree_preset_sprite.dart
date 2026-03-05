part of '../skill_tree_widgets.dart';

_SkillTreeLayout? _buildSpritePresetLayout(List<SkillEntry> skills) {
  const Map<String, Offset> spriteGridBySkill = <String, Offset>{
    'auto-device': Offset(0, 2),
    'express aid': Offset(1, 1),
    'micro heal': Offset(2, 1),
    'resurrection': Offset(3, 0),
    'enhance': Offset(2, 2),
    'counterforce': Offset(3, 2),
    'astral lance': Offset(4, 0),
    'stabiliz': Offset(1, 3),
    'sprite upgrade': Offset(3, 3),
    'sprite shield': Offset(2, 4),
    'magic vulcan': Offset(4, 4),
    'cursed altar': Offset(5, 4),
    'ignition': Offset(0, 6),
    'terrawrym': Offset(1, 6),
    'faux weapon': Offset(2, 6),
    'slash reaper': Offset(3, 6),
    'lebenglanz': Offset(4, 6),
  };

  const List<List<String>> spriteEdgesByName = <List<String>>[
    <String>['auto-device', 'express aid'],
    <String>['express aid', 'micro heal'],
    <String>['micro heal', 'resurrection'],
    <String>['express aid', 'enhance'],
    <String>['enhance', 'counterforce'],
    <String>['counterforce', 'astral lance'],
    <String>['auto-device', 'stabiliz'],
    <String>['stabiliz', 'sprite upgrade'],
    <String>['enhance', 'sprite shield'],
    <String>['sprite shield', 'magic vulcan'],
    <String>['magic vulcan', 'cursed altar'],
    <String>['sprite upgrade', 'magic vulcan'],
    <String>['ignition', 'terrawrym'],
    <String>['terrawrym', 'faux weapon'],
    <String>['faux weapon', 'slash reaper'],
    <String>['slash reaper', 'lebenglanz'],
  ];

  const Map<String, double> spriteEdgeBendGridByPair = <String, double>{
    'auto-device->express aid': 0.55,
    'auto-device->stabiliz': 0.55,
    'express aid->enhance': 1.55,
    'enhance->sprite shield': 2.55,
    'sprite upgrade->magic vulcan': 3.55,
  };

  return _buildGenericPresetLayout(
    skills: skills,
    gridBySkill: spriteGridBySkill,
    edgesByName: spriteEdgesByName,
    edgeBendGridByPair: spriteEdgeBendGridByPair,
    fallbackStartColumn: 7,
    fallbackStartRow: 2,
  );
}
