part of '../app_shell_page.dart';

enum _DrawerSummaryViewMode { metricList, itemDetails }

class _BuildStatsSummaryDrawer extends StatefulWidget {
  const _BuildStatsSummaryDrawer({
    required this.coordinator,
    required this.hasAdvancedAccess,
  });

  final BuildSimulatorCoordinator coordinator;
  final bool hasAdvancedAccess;

  @override
  State<_BuildStatsSummaryDrawer> createState() =>
      _BuildStatsSummaryDrawerState();
}

class _BuildStatsSummaryDrawerState extends State<_BuildStatsSummaryDrawer> {
  final TextEditingController _buildNameController = TextEditingController();
  _DrawerSummaryViewMode _summaryViewMode = _DrawerSummaryViewMode.metricList;
  static const int _guestSavedBuildLimit = 2;
  static const String _guestSaveLimitMessage = 'Limit 2 builds only.';

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

  String _savedBuildCodeLine(Map<String, dynamic> build) {
    final String code = BuildPersistenceService.encodeBuildShareCode(build);
    if (code.isEmpty) {
      return 'TB...';
    }
    const int maxVisibleChars = 28;
    if (code.length <= maxVisibleChars) {
      return code;
    }
    return '${code.substring(0, maxVisibleChars)}...';
  }

  String _savedBuildSavedAtLine(Map<String, dynamic> build) {
    final String savedAtRaw = BuildPersistenceService.readStringValue(
      build['savedAt'],
    ).trim();
    final DateTime? savedAt = savedAtRaw.isEmpty
        ? null
        : DateTime.tryParse(savedAtRaw);
    if (savedAt == null) {
      return 'Saved: -';
    }
    final DateTime localSavedAt = savedAt.toLocal();
    final String day = localSavedAt.day.toString().padLeft(2, '0');
    final String month = localSavedAt.month.toString().padLeft(2, '0');
    final String year = localSavedAt.year.toString();
    final String hour = localSavedAt.hour.toString().padLeft(2, '0');
    final String minute = localSavedAt.minute.toString().padLeft(2, '0');
    return 'Saved: $day/$month/$year $hour:$minute';
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
            label: 'Item Details',
            mode: _DrawerSummaryViewMode.itemDetails,
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

  Widget _buildStatsSummaryCard({
    required Map<String, num> summary,
    required List<Map<String, dynamic>> itemDetails,
  }) {
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
          _buildItemDetailsView(itemDetails),
      ],
    );
  }

  Widget _buildItemDetailsView(List<Map<String, dynamic>> itemDetails) {
    if (itemDetails.isEmpty) {
      return const Text(
        'No item selected.',
        style: TextStyle(fontSize: 12, color: Colors.white70),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(itemDetails.length, (int index) {
          final bool isLast = index == itemDetails.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: _buildItemDetailsSection(itemDetails[index]),
          );
        }),
      ),
    );
  }

  Widget _buildItemDetailsSection(Map<String, dynamic> detail) {
    final String slotLabel = detail['slotLabel']?.toString().trim() ?? '-';
    final String itemName = detail['itemName']?.toString().trim() ?? '';
    final List<Map<String, dynamic>> stats = _readDetailStats(detail['stats']);
    final bool hasItem = itemName.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$slotLabel:',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE0E0E0),
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            hasItem ? itemName : '-',
            style: TextStyle(
              fontSize: 13,
              color: hasItem ? const Color(0xFF9BC9FF) : Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (!hasItem) ...<Widget>[
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              'No item selected',
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ),
        ] else ...<Widget>[
          const SizedBox(height: 5),
          if (stats.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 14),
              child: Text(
                'No stat data',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            )
          else
            ...List<Widget>.generate(stats.length, (int index) {
              final Map<String, dynamic> stat = stats[index];
              final String label = stat['label']?.toString().trim() ?? '-';
              final String value = stat['value']?.toString().trim() ?? '0';
              final bool isNegative = value.startsWith('-');
              return Padding(
                padding: EdgeInsets.only(
                  left: 14,
                  bottom: index == stats.length - 1 ? 0 : 3,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        color: isNegative
                            ? const Color(0xFFA84B4B)
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ],
    );
  }

  List<Map<String, dynamic>> _readDetailStats(dynamic rawStats) {
    if (rawStats is! List) {
      return const <Map<String, dynamic>>[];
    }
    return rawStats
        .whereType<Map>()
        .map((Map<dynamic, dynamic> stat) {
          return Map<String, dynamic>.from(stat);
        })
        .toList(growable: false);
  }

  void _onSaveBuild() {
    if (_hasSaveLimit && !_canSaveBuild) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_guestSaveLimitMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF1A1A1A),
        ),
      );
      return;
    }
    final String name = _buildNameController.text.trim();
    if (name.isEmpty) {
      return;
    }
    widget.coordinator.saveBuildByName(name);
    _buildNameController.clear();
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A1A),
      ),
    );
  }

  Future<void> _onCopyBuildShareCode(Map<String, dynamic> build) async {
    final String code = BuildPersistenceService.encodeBuildShareCode(build);
    await Clipboard.setData(ClipboardData(text: code));
    _showMessage('Export code copied to clipboard.');
  }

  void _onImportBuildShareCode(String rawCode) {
    final String raw = rawCode.trim();
    if (raw.isEmpty) {
      _showMessage('Paste build code first.');
      return;
    }
    final Map<String, dynamic>? decoded =
        BuildPersistenceService.decodeBuildShareCode(
          raw,
          summaryTemplate: BuildCalculatorService.summaryTemplate,
          fallbackIndex: widget.coordinator.savedBuilds.length,
        );
    if (decoded == null) {
      _showMessage('Invalid build code.');
      return;
    }

    final int before = widget.coordinator.savedBuilds.length;
    widget.coordinator.mergeSavedBuilds(<Map<String, dynamic>>[decoded]);
    final int after = widget.coordinator.savedBuilds.length;
    if (after > before) {
      _showMessage('Build code imported.');
    }
  }

  Future<void> _onRequestImportBuildShareCode() async {
    final TextEditingController codeController = TextEditingController();
    final String? code = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Import Build Code',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: codeController,
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Paste shared build code (TB...)',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF0F0F0F),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.22),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0x66FFFFFF)),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(codeController.text);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4A4A4A),
              ),
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
    codeController.dispose();
    if (code == null) {
      return;
    }
    _onImportBuildShareCode(code);
  }

  Future<void> _onRequestClearAll() async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text(
                'Clear All Data',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Delete all current values and saved builds?',
                style: TextStyle(color: Colors.white70),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4A4A),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed) {
      return;
    }
    widget.coordinator.clearAllData();
  }

  bool get _hasSaveLimit => !widget.hasAdvancedAccess;
  bool get _canSaveBuild =>
      !_hasSaveLimit ||
      widget.coordinator.savedBuilds.length < _guestSavedBuildLimit;

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
            final List<Map<String, dynamic>> itemDetails =
                coordinator.selectedItemDetails;
            final List<Map<String, dynamic>> savedBuilds =
                coordinator.savedBuilds;
            final List<Map<String, dynamic>> visibleSavedBuilds = savedBuilds
                .take(5)
                .toList(growable: false);
            final List<String> aiRecommendations =
                coordinator.aiRecommendations;
            final bool isAiLoading = coordinator.isAiRecommendationLoading;
            final String aiSource = coordinator.aiRecommendationSource;
            final String aiMessage = coordinator.aiRecommendationMessage;
            final bool hasRemoteAi = _isRemoteAiSource(aiSource);
            final bool canUseAiGeneration = widget.hasAdvancedAccess;
            final bool shouldShowRecommendations =
                coordinator.showRecommendations && canUseAiGeneration;
            final bool hasSaveLimit = _hasSaveLimit;
            final bool canSaveBuild = _canSaveBuild;
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
                  child: _buildStatsSummaryCard(
                    summary: summary,
                    itemDetails: itemDetails,
                  ),
                ),
                if (shouldShowRecommendations) ...<Widget>[
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
                  trailing: InkWell(
                    onTap: _onRequestClearAll,
                    borderRadius: BorderRadius.circular(8),
                    child: Ink(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(
                            0xFFFFFFFF,
                          ).withValues(alpha: 0.24),
                        ),
                      ),
                      child: const Icon(
                        Icons.cleaning_services,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      if (hasSaveLimit) ...<Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _guestSaveLimitMessage,
                            style: TextStyle(
                              color: canSaveBuild
                                  ? Colors.white70
                                  : const Color(0xFFFFB3B3),
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
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
                            vertical: 14,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0A0A0A),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0x44FFFFFF),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
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
                              onPressed: canSaveBuild ? _onSaveBuild : null,
                              icon: const Icon(Icons.save, size: 16),
                              label: const Text('Save Build'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0x66FFFFFF),
                                ),
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _onRequestImportBuildShareCode,
                              icon: const Icon(
                                Icons.download_for_offline,
                                size: 16,
                              ),
                              label: const Text('Import Code'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: const BorderSide(
                                  color: Color(0x44FFFFFF),
                                ),
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
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
                          children: List<Widget>.generate(
                            visibleSavedBuilds.length,
                            (int index) {
                              final Map<String, dynamic> build =
                                  visibleSavedBuilds[index];
                              final String buildId = _buildIdOf(build);
                              final bool canControl = buildId.isNotEmpty;
                              return _SavedBuildTile(
                                name: _buildNameOf(build, index),
                                codeLine: _savedBuildCodeLine(build),
                                savedAtLine: _savedBuildSavedAtLine(build),
                                onTap: canControl
                                    ? () {
                                        coordinator.loadBuildById(buildId);
                                        Navigator.of(context).pop();
                                      }
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
                                onShare: () => _onCopyBuildShareCode(build),
                              );
                            },
                          ),
                        ),
                      if (savedBuilds.length > visibleSavedBuilds.length)
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'Showing first 5 builds.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
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
