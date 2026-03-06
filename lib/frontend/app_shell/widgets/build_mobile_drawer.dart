part of '../app_shell_page.dart';

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

  String _formatRadarValue(double value) {
    return ToramRadarProfile.formatValue(value);
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
            label: 'Radar Graph',
            mode: _DrawerSummaryViewMode.radarGraph,
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
                  MapEntry<String, String>(
                    'MagicPierce',
                    'Piercing (Magic)',
                  ),
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
          _buildSummaryRadarView(summary),
      ],
    );
  }

  Widget _buildSummaryRadarView(Map<String, num> summary) {
    final List<ToramRadarMetricSpec> metrics = ToramRadarProfile.metrics;
    final List<ToramRadarLabelAnchor> anchors = ToramRadarProfile.buildLabelAnchors(
      axisCount: metrics.length,
      radius: 0.97,
      minVerticalGap: 0.24,
    );
    final List<double> normalizedValues = metrics
        .map(
          (ToramRadarMetricSpec metric) => ToramRadarProfile.normalizedValue(
            summary: summary,
            metric: metric,
          ),
        )
        .toList(growable: false);

    return SizedBox(
      height: 340,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 190,
              height: 190,
              child: CustomPaint(
                painter: _DrawerSummaryRadarPainter(
                  normalizedValues: normalizedValues,
                  gridColor: const Color(0x66FFFFFF),
                  axisColor: const Color(0x33FFFFFF),
                  fillColor: const Color(0xAA8FC7FF),
                  strokeColor: const Color(0xFFD6ECFF),
                ),
              ),
            ),
          ),
          ...List<Widget>.generate(metrics.length, (int index) {
            final ToramRadarMetricSpec metric = metrics[index];
            final ToramRadarLabelAnchor anchor = anchors[index];
            final double width = anchor.textAlign == TextAlign.center ? 72 : 82;
            return _buildDrawerRadarLabel(
              alignment: anchor.alignment,
              label: metric.label,
              value: ToramRadarProfile.metricValue(summary, metric.id),
              textAlign: anchor.textAlign,
              maxWidth: width,
              valueFontSize: 12,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerRadarLabel({
    required Alignment alignment,
    required String label,
    required double value,
    TextAlign textAlign = TextAlign.center,
    double maxWidth = 98,
    double valueFontSize = 13,
  }) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: maxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: textAlign == TextAlign.left
              ? CrossAxisAlignment.start
              : textAlign == TextAlign.right
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFFFE082),
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
              ),
              textAlign: textAlign,
            ),
            Text(
              _formatRadarValue(value),
              style: TextStyle(
                color: Colors.white,
                fontSize: valueFontSize,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
              textAlign: textAlign,
            ),
          ],
        ),
      ),
    );
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
            final List<String> aiRecommendations = coordinator.aiRecommendations;
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
