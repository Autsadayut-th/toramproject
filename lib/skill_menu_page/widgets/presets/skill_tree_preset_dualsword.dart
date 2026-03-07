part of '../skill_tree_widgets.dart';

_SkillTreeLayout? _buildDualSwordPresetLayout(List<SkillEntry> skills) {
  const Map<String, Offset> dualSwordGridBySkill = <String, Offset>{
    'dual sword mastery': Offset(0, 1),
    'twin slash': Offset(1, 1),
    'spinning slash': Offset(2, 1),
    'phantom slash': Offset(3, 1),
    'aerial cut': Offset(6, 0),
    'cross parry': Offset(1, 2),
    'charging slash': Offset(2, 2),
    'shadowstep': Offset(3, 2),
    'shining cross': Offset(4, 2),
    'lunar misfortune': Offset(6, 1),
    'twin buster blade': Offset(6, 3),
    'reflex': Offset(1, 3),
    'flash blast': Offset(2, 3),
    'storm reaper': Offset(3, 3),
    'dual sword control': Offset(0, 5),
    'godspeed': Offset(1, 5),
    'saber aura': Offset(2, 5),
    'crescent saber': Offset(3, 5),
    'horizon cut': Offset(6, 5),
    'aerial slay': Offset(4, 6),
    'sting blade': Offset(6, 6),
  };

  const List<List<String>> dualSwordEdgesByName = <List<String>>[
    <String>['dual sword mastery', 'twin slash'],
    <String>['twin slash', 'spinning slash'],
    <String>['spinning slash', 'phantom slash'],
    <String>['spinning slash', 'aerial cut'],
    <String>['dual sword mastery', 'cross parry'],
    <String>['cross parry', 'charging slash'],
    <String>['charging slash', 'shadowstep'],
    <String>['shadowstep', 'shining cross'],
    <String>['shining cross', 'lunar misfortune'],
    <String>['shining cross', 'twin buster blade'],
    <String>['dual sword mastery', 'reflex'],
    <String>['reflex', 'flash blast'],
    <String>['flash blast', 'storm reaper'],
    <String>['storm reaper', 'sting blade'],
    <String>['dual sword control', 'godspeed'],
    <String>['godspeed', 'saber aura'],
    <String>['saber aura', 'crescent saber'],
    <String>['crescent saber', 'horizon cut'],
    <String>['godspeed', 'aerial slay'],
    <String>['aerial slay', 'sting blade'],
  ];

  const Map<String, double> dualSwordEdgeBendGridByPair = <String, double>{
    'dual sword mastery->cross parry': 0.55,
    'dual sword mastery->reflex': 0.55,
    'spinning slash->aerial cut': 2.05,
    'shining cross->lunar misfortune': 4.55,
    'shining cross->twin buster blade': 4.55,
    'godspeed->aerial slay': 1.55,
    'aerial slay->sting blade': 4.55,
  };

  return _buildGenericPresetLayout(
    skills: skills,
    gridBySkill: dualSwordGridBySkill,
    edgesByName: dualSwordEdgesByName,
    edgeBendGridByPair: dualSwordEdgeBendGridByPair,
    fallbackStartColumn: 7,
    fallbackStartRow: 2,
  );
}
