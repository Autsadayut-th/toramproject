import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../shared/app_mobile_bottom_navigation_bar.dart';
import '../shared/app_navigation_drawer.dart';
import '../shared/toram_radar_profile.dart';

part 'widgets/compare_build_radar_section.dart';
part 'widgets/compare_build_stats_table_section.dart';

class CompareBuildsPage extends StatefulWidget {
  const CompareBuildsPage({
    super.key,
    required this.savedBuilds,
    required this.onLoadBuild,
    this.onNavigate,
  });

  final List<Map<String, dynamic>> savedBuilds;
  final ValueChanged<String> onLoadBuild;
  final ValueChanged<AppNavigationPage>? onNavigate;

  @override
  State<CompareBuildsPage> createState() => _CompareBuildsPageState();
}

class _CompareBuildsPageState extends State<CompareBuildsPage> {
  static const List<String> _compareKeys = <String>[
    'ATK',
    'MATK',
    'DEF',
    'MDEF',
    'STR',
    'DEX',
    'INT',
    'AGI',
    'VIT',
    'ASPD',
    'CSPD',
    'FLEE',
    'CritRate',
    'PhysicalPierce',
    'MagicPierce',
    'Accuracy',
    'Stability',
    'HP',
    'MP',
  ];

  static const Set<String> _percentKeys = <String>{
    'CritRate',
    'PhysicalPierce',
    'MagicPierce',
    'Accuracy',
    'Stability',
  };

  late List<Map<String, dynamic>> _builds;
  String? _firstBuildId;
  String? _secondBuildId;
  bool _showOnlyDifferences = true;
  bool _sortByDifference = true;

  @override
  void initState() {
    super.initState();
    _syncBuildsFromWidget();
  }

  @override
  void didUpdateWidget(covariant CompareBuildsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.savedBuilds != widget.savedBuilds) {
      _syncBuildsFromWidget();
    }
  }

  void _syncBuildsFromWidget() {
    _builds = widget.savedBuilds
        .map((Map<String, dynamic> build) => Map<String, dynamic>.from(build))
        .toList(growable: false);

    if (_builds.isNotEmpty) {
      _firstBuildId = _buildId(_builds.first, 0);
    }
    if (_builds.length > 1) {
      _secondBuildId = _buildId(_builds[1], 1);
    } else {
      _secondBuildId = _firstBuildId;
    }

    if (_buildById(_firstBuildId) == null && _builds.isNotEmpty) {
      _firstBuildId = _buildId(_builds.first, 0);
    }
    if (_buildById(_secondBuildId) == null) {
      _secondBuildId = _builds.length > 1
          ? _buildId(_builds[1], 1)
          : _firstBuildId;
    }
  }

  String _buildId(Map<String, dynamic> build, int index) {
    final String id = build['id']?.toString().trim() ?? '';
    if (id.isNotEmpty) {
      return id;
    }
    return 'legacy_build_$index';
  }

  String _displayName(Map<String, dynamic> build, int index) {
    final String name = build['name']?.toString().trim() ?? '';
    if (name.isNotEmpty) {
      return name;
    }
    return 'Build ${index + 1}';
  }

  Map<String, dynamic>? _buildById(String? id) {
    if (id == null) {
      return null;
    }
    for (int i = 0; i < _builds.length; i++) {
      if (_buildId(_builds[i], i) == id) {
        return _builds[i];
      }
    }
    return null;
  }

  int _summaryValue(Map<String, dynamic>? build, String key) {
    if (build == null) {
      return 0;
    }
    final dynamic summary = build['summary'];
    if (summary is! Map) {
      return 0;
    }
    final dynamic raw = summary[key];
    if (raw is num) {
      return raw.toInt();
    }
    if (raw is String) {
      return int.tryParse(raw.trim()) ?? 0;
    }
    return 0;
  }

  Map<String, num> _summaryMap(Map<String, dynamic>? build) {
    final Map<String, num> summary = <String, num>{};
    for (final String key in _compareKeys) {
      summary[key] = _summaryValue(build, key);
    }
    return summary;
  }

  String _slotLabel(Map<String, dynamic>? build, String key) {
    if (build == null) {
      return '-';
    }
    final String value = build[key]?.toString().trim() ?? '';
    if (value.isEmpty) {
      return '-';
    }
    return value;
  }

  String _formatStatValue(String key, num value) {
    final String text = value == value.toInt()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    if (_percentKeys.contains(key)) {
      return '$text%';
    }
    return text;
  }

  int _deltaValue({
    required Map<String, dynamic>? firstBuild,
    required Map<String, dynamic>? secondBuild,
    required String key,
  }) {
    return _summaryValue(secondBuild, key) - _summaryValue(firstBuild, key);
  }

  int _differenceCount({
    required Map<String, dynamic>? firstBuild,
    required Map<String, dynamic>? secondBuild,
  }) {
    int count = 0;
    for (final String key in _compareKeys) {
      if (_deltaValue(firstBuild: firstBuild, secondBuild: secondBuild, key: key) !=
          0) {
        count++;
      }
    }
    return count;
  }

  int _buildALeadCount({
    required Map<String, dynamic>? firstBuild,
    required Map<String, dynamic>? secondBuild,
  }) {
    int count = 0;
    for (final String key in _compareKeys) {
      if (_deltaValue(firstBuild: firstBuild, secondBuild: secondBuild, key: key) <
          0) {
        count++;
      }
    }
    return count;
  }

  int _buildBLeadCount({
    required Map<String, dynamic>? firstBuild,
    required Map<String, dynamic>? secondBuild,
  }) {
    int count = 0;
    for (final String key in _compareKeys) {
      if (_deltaValue(firstBuild: firstBuild, secondBuild: secondBuild, key: key) >
          0) {
        count++;
      }
    }
    return count;
  }

  void _swapBuildSelection() {
    setState(() {
      final String? cached = _firstBuildId;
      _firstBuildId = _secondBuildId;
      _secondBuildId = cached;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? firstBuild = _buildById(_firstBuildId);
    final Map<String, dynamic>? secondBuild = _buildById(_secondBuildId);
    final bool isMobile = MediaQuery.sizeOf(context).width < 1024;
    final bool isEmbeddedInShell = widget.onNavigate != null;
    final int differenceCount = _differenceCount(
      firstBuild: firstBuild,
      secondBuild: secondBuild,
    );
    final int buildALeadCount = _buildALeadCount(
      firstBuild: firstBuild,
      secondBuild: secondBuild,
    );
    final int buildBLeadCount = _buildBLeadCount(
      firstBuild: firstBuild,
      secondBuild: secondBuild,
    );

    void onSelectMobileNav(AppNavigationPage page) {
      if (page == AppNavigationPage.compare) {
        return;
      }
      widget.onNavigate?.call(page);
    }

    final Widget content = _builds.length < 2
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'At least 2 saved builds are required to compare.',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool stackSelectors = constraints.maxWidth < 860;
                    final Widget selectorA = _buildSelector(
                      label: 'Build A',
                      selectedId: _firstBuildId,
                      onChanged: (String? value) {
                        setState(() {
                          _firstBuildId = value;
                        });
                      },
                    );
                    final Widget selectorB = _buildSelector(
                      label: 'Build B',
                      selectedId: _secondBuildId,
                      onChanged: (String? value) {
                        setState(() {
                          _secondBuildId = value;
                        });
                      },
                    );
                    if (stackSelectors) {
                      return Column(
                        children: <Widget>[
                          selectorA,
                          const SizedBox(height: 10),
                          selectorB,
                        ],
                      );
                    }
                    return Row(
                      children: <Widget>[
                        Expanded(child: selectorA),
                        const SizedBox(width: 12),
                        Expanded(child: selectorB),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _swapBuildSelection,
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Swap A/B'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: firstBuild == null
                          ? null
                          : () {
                              widget.onLoadBuild(_firstBuildId!);
                              if (widget.onNavigate != null) {
                                widget.onNavigate!(AppNavigationPage.build);
                                return;
                              }
                              Navigator.of(context).pop();
                            },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Load Build A'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: secondBuild == null
                          ? null
                          : () {
                              widget.onLoadBuild(_secondBuildId!);
                              if (widget.onNavigate != null) {
                                widget.onNavigate!(AppNavigationPage.build);
                                return;
                              }
                              Navigator.of(context).pop();
                            },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Load Build B'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName(
                          firstBuild ?? _builds.first,
                          firstBuild == null ? 0 : _builds.indexOf(firstBuild),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Main: ${_slotLabel(firstBuild, 'mainWeaponId')}  '
                        'Sub: ${_slotLabel(firstBuild, 'subWeaponId')}  '
                        'Armor: ${_slotLabel(firstBuild, 'armorId')}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _displayName(
                          secondBuild ?? _builds[1],
                          secondBuild == null
                              ? 1
                              : _builds.indexOf(secondBuild),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Main: ${_slotLabel(secondBuild, 'mainWeaponId')}  '
                        'Sub: ${_slotLabel(secondBuild, 'subWeaponId')}  '
                        'Armor: ${_slotLabel(secondBuild, 'armorId')}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _summaryChip(
                      icon: Icons.compare_arrows,
                      label: 'Different Stats',
                      value: '$differenceCount/${_compareKeys.length}',
                    ),
                    _summaryChip(
                      icon: Icons.arrow_back,
                      label: 'Build A Leads',
                      value: '$buildALeadCount',
                    ),
                    _summaryChip(
                      icon: Icons.arrow_forward,
                      label: 'Build B Leads',
                      value: '$buildBLeadCount',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildCompareRadarCard(firstBuild: firstBuild, secondBuild: secondBuild),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    FilterChip(
                      label: const Text('Only Differences'),
                      selected: _showOnlyDifferences,
                      onSelected: (bool selected) {
                        setState(() {
                          _showOnlyDifferences = selected;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Sort By Delta'),
                      selected: _sortByDifference,
                      onSelected: (bool selected) {
                        setState(() {
                          _sortByDifference = selected;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildCenteredCompareTable(
                  firstBuild: firstBuild,
                  secondBuild: secondBuild,
                  showOnlyDifferences: _showOnlyDifferences,
                  sortByDifference: _sortByDifference,
                ),
                  ],
                ),
              ),
            ),
          );

    if (isEmbeddedInShell) {
      return content;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      drawer: isMobile
          ? null
          : AppNavigationDrawer(
              currentPage: AppNavigationPage.compare,
              onOpenBuild: () {
                Navigator.of(context).pop();
                widget.onNavigate?.call(AppNavigationPage.build);
              },
              onOpenEquipment: () {
                Navigator.of(context).pop();
                widget.onNavigate?.call(AppNavigationPage.equipment);
              },
              onOpenSkill: () {
                Navigator.of(context).pop();
                widget.onNavigate?.call(AppNavigationPage.skill);
              },
              onOpenCompare: () => Navigator.of(context).pop(),
              onOpenSaved: () {
                Navigator.of(context).pop();
                widget.onNavigate?.call(AppNavigationPage.saved);
              },
              onOpenSettings: () {
                Navigator.of(context).pop();
                widget.onNavigate?.call(AppNavigationPage.settings);
              },
            ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: isMobile
            ? null
            : Builder(
                builder: (BuildContext context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        title: const Text('Compare Builds'),
      ),
      body: content,
      bottomNavigationBar: isMobile
          ? AppMobileBottomNavigationBar(
              currentPage: AppNavigationPage.compare,
              onSelect: onSelectMobileNav,
            )
          : null,
    );
  }

  Widget _buildSelector({
    required String label,
    required String? selectedId,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFF101010),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedId,
          dropdownColor: const Color(0xFF101010),
          isExpanded: true,
          items: List<DropdownMenuItem<String>>.generate(_builds.length, (
            int i,
          ) {
            final Map<String, dynamic> build = _builds[i];
            return DropdownMenuItem<String>(
              value: _buildId(build, i),
              child: Text(
                _displayName(build, i),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _summaryChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
