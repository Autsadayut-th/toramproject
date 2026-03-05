part of '../skill_tree_widgets.dart';

_SkillTreeLayout? _buildHalberdPresetLayout(List<SkillEntry> skills) {
  const Map<String, Offset> halberdGridBySkill = <String, Offset>{
    'flash stab': Offset(0, 1),
    'cannon spear': Offset(1, 1),
    'dragon tail': Offset(2, 1),
    'dive impact': Offset(3, 1),
    'dragon tooth': Offset(4, 0),
    'draconic charge': Offset(5, 0),
    'deadly spear': Offset(1, 2),
    'strike stab': Offset(2, 2),
    'chronos drive': Offset(3, 2),
    'infinite dimension': Offset(5, 2),
    'punish ray': Offset(2, 3),
    'blitz spike': Offset(3, 3),
    'lightning hail': Offset(4, 3),
    "thor's hammer": Offset(5, 3),
    'halberd mastery': Offset(0, 5),
    'critical spear': Offset(2, 5),
    'tornado lance': Offset(5, 5),
    'quick aura': Offset(0, 6),
    'war cry of struggle': Offset(2, 6),
    'godspeed wield': Offset(4, 6),
    'almighty wield': Offset(5, 6),
    'buster lance': Offset(3, 7),
  };

  const List<List<String>> halberdEdgesByName = <List<String>>[
    <String>['flash stab', 'cannon spear'],
    <String>['cannon spear', 'dragon tail'],
    <String>['dragon tail', 'dive impact'],
    <String>['dive impact', 'dragon tooth'],
    <String>['dragon tooth', 'draconic charge'],
    <String>['cannon spear', 'deadly spear'],
    <String>['deadly spear', 'strike stab'],
    <String>['strike stab', 'chronos drive'],
    <String>['chronos drive', 'infinite dimension'],
    <String>['cannon spear', 'punish ray'],
    <String>['punish ray', 'blitz spike'],
    <String>['blitz spike', 'lightning hail'],
    <String>['lightning hail', "thor's hammer"],
    <String>['halberd mastery', 'critical spear'],
    <String>['critical spear', 'tornado lance'],
    <String>['quick aura', 'war cry of struggle'],
    <String>['war cry of struggle', 'godspeed wield'],
    <String>['godspeed wield', 'almighty wield'],
    <String>['war cry of struggle', 'buster lance'],
  ];

  const Map<String, double> halberdEdgeBendGridByPair = <String, double>{
    'dive impact->dragon tooth': 3.55,
    'cannon spear->deadly spear': 0.55,
    'cannon spear->punish ray': 0.55,
    'war cry of struggle->buster lance': 2.55,
  };

  return _buildGenericPresetLayout(
    skills: skills,
    gridBySkill: halberdGridBySkill,
    edgesByName: halberdEdgesByName,
    edgeBendGridByPair: halberdEdgeBendGridByPair,
    fallbackStartColumn: 7,
    fallbackStartRow: 2,
  );
}
