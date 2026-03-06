part of '../app_shell_page.dart';

enum _DrawerSummaryViewMode { metricList, tableGraph }

class _BuildStatsSummaryDrawer extends StatefulWidget {
  const _BuildStatsSummaryDrawer({required this.coordinator});

  final BuildSimulatorCoordinator coordinator;

  @override
  State<_BuildStatsSummaryDrawer> createState() =>
      _BuildStatsSummaryDrawerState();
}

class _BuildStatsSummaryDrawerState extends State<_BuildStatsSummaryDrawer> {
  final TextEditingController _buildNameController = TextEditingController();
  _DrawerSummaryViewMode _summaryViewMode = _DrawerSummaryViewMode.metricList;

  static const Set<String> _percentKeys = <String>{
    'CritRate',
    'PhysicalPierce',
    'MagicPierce',
    'Accuracy',
    'Stability',
  };

  @override
  void dispose() {
    _buildNameController.dispose();
    super.dispose();
  }

  bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
    }
    return false;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  String _buildIdOf(Map<String, dynamic> build) {
    return build['id']?.toString().trim() ?? '';
  }

  String _buildNameOf(Map<String, dynamic> build, int index) {
    final String rawName = build['name']?.toString().trim() ?? '';
    if (rawName.isEmpty) {
      return 'Build ${index + 1}';
    }
    return rawName;
  }

  int _summaryOf(Map<String, dynamic> build, String key) {
    final dynamic rawSummary = build['summary'];
    if (rawSummary is! Map) {
      return 0;
    }
    return _toInt(rawSummary[key]);
  }

  String _savedBuildStatsLine(Map<String, dynamic> build) {
    return 'ATK ${_summaryOf(build, 'ATK')}  '
        'DEF ${_summaryOf(build, 'DEF')}  '
        'MDEF ${_summaryOf(build, 'MDEF')}  '
        'HP ${_summaryOf(build, 'HP')}  '
        'MP ${_summaryOf(build, 'MP')}';
  }

  bool _isRemoteAiSource(String source) {
    final String normalized = source.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return normalized != 'rule' && normalized != 'fallback';
  }

  Widget _buildSummaryModeSwitch() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x44FFFFFF)),
      ),
      child: Row(
        children: <Widget>[
          _buildSummaryModeButton(
            label: 'Values',
            mode: _DrawerSummaryViewMode.metricList,
          ),
          const SizedBox(width: 6),
          _buildSummaryModeButton(
            label: 'Combat Bars',
            mode: _DrawerSummaryViewMode.tableGraph,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryModeButton({
    required String label,
    required _DrawerSummaryViewMode mode,
  }) {
    final bool isActive = _summaryViewMode == mode;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (isActive) {
            return;
          }
          setState(() {
            _summaryViewMode = mode;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2B2B2B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? const Color(0x66FFFFFF)
                  : const Color(0x22FFFFFF),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummaryCard(Map<String, num> summary) {
    return Column(
      children: <Widget>[
        _buildSummaryModeSwitch(),
        const SizedBox(height: 10),
        if (_summaryViewMode == _DrawerSummaryViewMode.metricList)
          Column(
            children: <Widget>[
              _StatsCategoryBlock(
                title: 'Attack',
                rows: const <MapEntry<String, String>>[
                  MapEntry<String, String>('ATK', 'ATK'),
                  MapEntry<String, String>('MATK', 'MATK'),
                ],
                summary: summary,
                percentKeys: _percentKeys,
              ),
              _StatsCategoryBlock(
                title: 'Defense',
                rows: const <MapEntry<String, String>>[
                  MapEntry<String, String>('DEF', 'DEF'),
                  MapEntry<String, String>('MDEF', 'MDEF'),
                ],
                summary: summary,
                percentKeys: _percentKeys,
              ),
              _StatsCategoryBlock(
                title: 'Main Stats',
                rows: const <MapEntry<String, String>>[
                  MapEntry<String, String>('STR', 'STR'),
                  MapEntry<String, String>('DEX', 'DEX'),
                  MapEntry<String, String>('INT', 'INT'),
                  MapEntry<String, String>('AGI', 'AGI'),
                  MapEntry<String, String>('VIT', 'VIT'),
                ],
                summary: summary,
                percentKeys: _percentKeys,
              ),
              _StatsCategoryBlock(
                title: 'Special Stats',
                rows: const <MapEntry<String, String>>[
                  MapEntry<String, String>('ASPD', 'ASPD'),
                  MapEntry<String, String>('CSPD', 'CSPD'),
                  MapEntry<String, String>('FLEE', 'FLEE'),
                  MapEntry<String, String>('CritRate', 'Critical Rate'),
                  MapEntry<String, String>(
                    'PhysicalPierce',
                    'Piercing (Physical)',
                  ),
                  MapEntry<String, String>('MagicPierce', 'Piercing (Magic)'),
                  MapEntry<String, String>('Accuracy', 'HIT'),
                  MapEntry<String, String>('Stability', 'Stability'),
                  MapEntry<String, String>('HP', 'HP'),
                  MapEntry<String, String>('MP', 'MP'),
                ],
                summary: summary,
                percentKeys: _percentKeys,
              ),
            ],
          )
        else
          _buildSummaryBarGraphView(summary),
      ],
    );
  }

  Widget _buildSummaryBarGraphView(Map<String, num> summary) {
    final List<ToramRadarMetricSpec> metrics = ToramRadarProfile.metrics;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Bars are benchmark-scaled for quick comparison while the numbers stay raw.',
          style: TextStyle(fontSize: 11, color: Colors.white70, height: 1.35),
        ),
        const SizedBox(height: 12),
        ...List<Widget>.generate(metrics.length, (int index) {
          final ToramRadarMetricSpec metric = metrics[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == metrics.length - 1 ? 0 : 10,
            ),
            child: _buildSummaryMetricBar(summary: summary, metric: metric),
          );
        }),
      ],
    );
  }

  Widget _buildSummaryMetricBar({
    required Map<String, num> summary,
    required ToramRadarMetricSpec metric,
  }) {
    final double rawValue = ToramRadarProfile.metricValue(summary, metric.id);
    final double normalizedValue = ToramRadarProfile.normalizedValue(
      summary: summary,
      metric: metric,
    ).clamp(0.0, 1.0);
    final List<Color> barColors = _summaryMetricBarColors(metric.label);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                metric.label,
                style: const TextStyle(
                  color: Color(0xFFFFE082),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Text(
                _formatMetricValue(rawValue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 12,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0x33FFFFFF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: normalizedValue,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: barColors),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Text(
                'Profile ${(normalizedValue * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Benchmark ${_formatMetricValue(metric.cap)}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMetricValue(double value) {
    return ToramRadarProfile.formatValue(value);
  }

  List<Color> _summaryMetricBarColors(String label) {
    switch (label) {
      case 'ATK':
      case 'MATK':
        return const <Color>[Color(0xFF77D3FF), Color(0xFF4D8DFF)];
      case 'DEF':
      case 'MDEF':
        return const <Color>[Color(0xFF86F7C8), Color(0xFF3CCB8E)];
      case 'HIT':
      case 'FLEE':
        return const <Color>[Color(0xFFFFD27A), Color(0xFFFFA347)];
      case 'ASPD':
      case 'CSPD':
        return const <Color>[Color(0xFFFFA7D1), Color(0xFFFF6F91)];
      default:
        return const <Color>[Color(0xFFB8D2FF), Color(0xFF6C9BFF)];
    }
  }

  void _onSaveBuild() {
    final String name = _buildNameController.text.trim();
    if (name.isEmpty) {
      return;
    }
    widget.coordinator.saveBuildByName(name);
    _buildNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF000000),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: widget.coordinator,
          builder: (BuildContext context, _) {
            final BuildSimulatorCoordinator coordinator = widget.coordinator;
            final Map<String, num> summary = coordinator.summary;
            final List<Map<String, dynamic>> savedBuilds =
                coordinator.savedBuilds;
            final List<String> aiRecommendations =
                coordinator.aiRecommendations;
            final bool isAiLoading = coordinator.isAiRecommendationLoading;
            final String aiSource = coordinator.aiRecommendationSource;
            final String aiMessage = coordinator.aiRecommendationMessage;
            final bool hasRemoteAi = _isRemoteAiSource(aiSource);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Build Tools',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white70),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _DrawerSectionCard(
                  title: 'Stats Summary',
                  icon: Icons.assessment,
                  child: _buildStatsSummaryCard(summary),
                ),
                if (coordinator.showRecommendations) ...<Widget>[
                  const SizedBox(height: 12),
                  _DrawerSectionCard(
                    title: 'AI Recommendations',
                    icon: Icons.lightbulb_outline,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              isAiLoading
                                  ? Icons.sync
                                  : hasRemoteAi
                                  ? Icons.psychology
                                  : Icons.rule,
                              size: 14,
                              color: isAiLoading
                                  ? const Color(0xFFFFE082)
                                  : hasRemoteAi
                                  ? const Color(0xFFB7FFC6)
                                  : const Color(0xFFFFCCBC),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                aiMessage,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isAiLoading
                                      ? const Color(0xFFFFF8E1)
                                      : Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (aiRecommendations.isEmpty)
                          const Text(
                            'No recommendations yet.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          )
                        else
                          ...List<Widget>.generate(aiRecommendations.length, (
                            int index,
                          ) {
                            return _RecommendationTile(
                              index: index + 1,
                              message: aiRecommendations[index],
                            );
                          }),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _DrawerSectionCard(
                  title: 'Save / Load Build',
                  icon: Icons.save_outlined,
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _buildNameController,
                        onSubmitted: (_) => _onSaveBuild(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter build name...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0A0A0A),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0x44FFFFFF),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0x77FFFFFF),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _onSaveBuild,
                              icon: const Icon(Icons.save, size: 16),
                              label: const Text('Save'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0x66FFFFFF),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: coordinator.clearAllData,
                              icon: const Icon(
                                Icons.cleaning_services,
                                size: 16,
                              ),
                              label: const Text('Clear'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: const BorderSide(
                                  color: Color(0x44FFFFFF),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (savedBuilds.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF101010),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0x33FFFFFF)),
                          ),
                          child: const Text(
                            'No saved builds yet.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        Column(
                          children: List<Widget>.generate(savedBuilds.length, (
                            int index,
                          ) {
                            final Map<String, dynamic> build =
                                savedBuilds[index];
                            final String buildId = _buildIdOf(build);
                            final bool canControl = buildId.isNotEmpty;
                            return _SavedBuildTile(
                              name: _buildNameOf(build, index),
                              statsLine: _savedBuildStatsLine(build),
                              isFavorite: _toBool(build['isFavorite']),
                              onToggleFavorite: canControl
                                  ? () => coordinator.toggleFavoriteBuildById(
                                      buildId,
                                    )
                                  : null,
                              onLoad: canControl
                                  ? () {
                                      coordinator.loadBuildById(buildId);
                                      Navigator.of(context).pop();
                                    }
                                  : null,
                              onDelete: canControl
                                  ? () => coordinator.deleteBuildById(buildId)
                                  : null,
                            );
                          }),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
