part of '../skill_tree_widgets.dart';

_SkillTreeLayout? _buildMononofuPresetLayout(List<SkillEntry> skills) {
  const Map<String, Offset> mononofuGridBySkill = <String, Offset>{
    'issen': Offset(0, 0),
    'pulse blade': Offset(1, 0),
    'triple thrust': Offset(2, 0),
    'hasso happa': Offset(3, 0),
    'tenryu ransei': Offset(4, 0),
    'kasumisetsu getsuka': Offset(5, 0),
    'garyou tensei': Offset(4, 1),
    'shadowless slash': Offset(5, 1),
    'pommel strike': Offset(0, 2),
    'magadachi': Offset(1, 2),
    'zantei settetsu': Offset(2, 2),
    'bushido': Offset(0, 4),
    'shukuchi': Offset(1, 4),
    'nukiuchi sennosen': Offset(2, 4),
    'two-handed': Offset(0, 6),
    'meikyo shisui': Offset(1, 6),
    'kairiki ranshin': Offset(3, 6),
    'dauntless': Offset(4, 6),
    'auspicious wind': Offset(1, 7),
    'gust': Offset(2, 7),
    'zephyr rush': Offset(3, 7),
    'super gust': Offset(4, 7),
    'bouncing blade': Offset(3, 8),
  };

  const List<List<String>> mononofuEdgesByName = <List<String>>[
    <String>['issen', 'pulse blade'],
    <String>['pulse blade', 'triple thrust'],
    <String>['triple thrust', 'hasso happa'],
    <String>['hasso happa', 'tenryu ransei'],
    <String>['tenryu ransei', 'kasumisetsu getsuka'],
    <String>['hasso happa', 'garyou tensei'],
    <String>['garyou tensei', 'shadowless slash'],
    <String>['pommel strike', 'magadachi'],
    <String>['magadachi', 'zantei settetsu'],
    <String>['bushido', 'shukuchi'],
    <String>['shukuchi', 'nukiuchi sennosen'],
    <String>['two-handed', 'meikyo shisui'],
    <String>['meikyo shisui', 'kairiki ranshin'],
    <String>['kairiki ranshin', 'dauntless'],
    <String>['meikyo shisui', 'auspicious wind'],
    <String>['auspicious wind', 'gust'],
    <String>['gust', 'zephyr rush'],
    <String>['zephyr rush', 'super gust'],
    <String>['gust', 'bouncing blade'],
  ];

  const Map<String, double> mononofuEdgeBendGridByPair = <String, double>{
    'hasso happa->garyou tensei': 3.55,
    'meikyo shisui->auspicious wind': 1.55,
    'gust->bouncing blade': 2.55,
  };

  return _buildGenericPresetLayout(
    skills: skills,
    gridBySkill: mononofuGridBySkill,
    edgesByName: mononofuEdgesByName,
    edgeBendGridByPair: mononofuEdgeBendGridByPair,
    fallbackStartColumn: 7,
    fallbackStartRow: 2,
  );
}
