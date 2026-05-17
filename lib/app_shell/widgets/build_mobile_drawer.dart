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
  bool _showAllMobileRecommendations = false;
  static const int _guestSavedBuildLimit = 2;
  static const String _guestSaveLimitMessage = 'Limit 2 builds only.';

  static const Set<String> _percentKeys = <String>{
    'CritRate',
    'PhysicalPierce',
    'MagicPierce',
    'Accuracy',
    'Stability',
  };

  String _sourceLabelForAi(String source) {
    final String normalized = source.trim().toLowerCase();
    switch (normalized) {
      case 'gemini':
        return 'Source: Gemini';
      case 'openai':
        return 'Source: OpenAI';
      case 'groq':
        return 'Source: Groq';
      case 'huggingface':
        return 'Source: HuggingFace';
      case 'fallback':
      case 'rule':
        return 'Source: Fallback rule';
      default:
        return 'Source: Local rule';
    }
  }

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

  Widget _buildSummaryModeSwitch() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.24),
        ),
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
            color: isActive
                ? colorScheme.surfaceContainerHigh
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? colorScheme.onSurface.withValues(alpha: 0.35)
                  : colorScheme.onSurface.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.75),
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (itemDetails.isEmpty) {
      return Text(
        'No item selected.',
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurface.withValues(alpha: 0.75),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.2)),
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String slotLabel = detail['slotLabel']?.toString().trim() ?? '-';
    final String itemName = detail['itemName']?.toString().trim() ?? '';
    final List<Map<String, dynamic>> stats = _readDetailStats(detail['stats']);
    final bool hasItem = itemName.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$slotLabel:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            hasItem ? itemName : '-',
            style: TextStyle(
              fontSize: 13,
              color: hasItem
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.54),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (!hasItem) ...<Widget>[
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              'No item selected',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.54),
              ),
            ),
          ),
        ] else ...<Widget>[
          const SizedBox(height: 5),
          if (stats.isEmpty)
            Padding(
              padding: EdgeInsets.only(left: 14),
              child: Text(
                'No stat data',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.54),
                ),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        color: isNegative
                            ? colorScheme.error
                            : colorScheme.onSurface,
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
      final ColorScheme colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(_guestSaveLimitMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colorScheme.surfaceContainerHigh,
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.surfaceContainerHigh,
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
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surfaceContainerHigh,
          title: Text(
            'Import Build Code',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: TextField(
            controller: codeController,
            autofocus: true,
            minLines: 2,
            maxLines: 4,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Paste shared build code (TB...)',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.54),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.22),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.45),
                ),
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
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
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
            final ColorScheme colorScheme = Theme.of(context).colorScheme;
            return AlertDialog(
              backgroundColor: colorScheme.surfaceContainerHigh,
              title: Text(
                'Clear All Data',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              content: Text(
                'Delete all current values and saved builds?',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: colorScheme.surface,
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
            final List<AiRecommendationItem> aiRecommendationItems =
                coordinator.aiRecommendationItems;
            final bool isAiLoading = coordinator.isAiRecommendationLoading;
            final String aiSource = coordinator.aiRecommendationSource;
            final String aiMessage = coordinator.aiRecommendationMessage;
            final Map<String, String> feedbackByRecommendationId =
                coordinator.feedbackByRecommendationId;
            final bool canUseAiGeneration = widget.hasAdvancedAccess;
            final bool canTriggerAi =
                canUseAiGeneration && coordinator.canGenerateAiRecommendations;
            final bool shouldShowRecommendations =
                coordinator.showRecommendations && canUseAiGeneration;
            final List<AiRecommendationItem> visibleRecommendationItems =
                aiRecommendationItems.isNotEmpty
                ? aiRecommendationItems
                : aiRecommendations
                      .asMap()
                      .entries
                      .map((MapEntry<int, String> entry) {
                        return AiRecommendationItem(
                          id: 'mobile_recommendation_${entry.key + 1}',
                          message: entry.value,
                          category: 'analysis',
                          priority: 3,
                          confidence: 0.67,
                          explanation: '',
                          source: aiSource,
                        );
                      })
                      .toList(growable: false);
            final bool hasSaveLimit = _hasSaveLimit;
            final bool canSaveBuild = _canSaveBuild;
            final String sourceLabel = _sourceLabelForAi(aiSource);
            final String normalizedSource = aiSource.trim().toLowerCase();
            final String normalizedMessage = aiMessage.trim().toLowerCase();
            final bool isErrorState =
                !isAiLoading &&
                (normalizedSource == 'error' ||
                    normalizedMessage.contains('unavailable') ||
                    normalizedMessage.contains('failed') ||
                    normalizedMessage.contains('error'));
            final bool isFallbackState =
                !isAiLoading &&
                !isErrorState &&
                (normalizedSource == 'fallback' || normalizedSource == 'rule');
            IconData statusIcon;
            Color statusColor;
            String statusLabel;
            if (isAiLoading) {
              statusIcon = Icons.sync;
              statusColor = colorScheme.tertiary;
              statusLabel = 'Loading';
            } else if (isErrorState) {
              statusIcon = Icons.error_outline;
              statusColor = colorScheme.error;
              statusLabel = 'Error';
            } else if (isFallbackState) {
              statusIcon = Icons.rule;
              statusColor = colorScheme.primary;
              statusLabel = 'Fallback';
            } else {
              statusIcon = Icons.check_circle_outline;
              statusColor = colorScheme.secondary;
              statusLabel = 'Success';
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Build Tools',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
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
                    trailing: IconButton(
                      onPressed: !canTriggerAi || isAiLoading
                          ? null
                          : coordinator.generateAiRecommendations,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Refresh',
                    ),
                    child: AiRecommendationsContent(
                      aiMessage: aiMessage,
                      statusIcon: statusIcon,
                      statusColor: statusColor,
                      statusLabel: statusLabel,
                      sourceLabel: sourceLabel,
                      canGenerateAi: canTriggerAi,
                      canSendFeedback: true,
                      isLoading: isAiLoading,
                      onGenerate: coordinator.generateAiRecommendations,
                      recommendationItems: visibleRecommendationItems,
                      feedbackByRecommendationId: feedbackByRecommendationId,
                      showAllRecommendations: _showAllMobileRecommendations,
                      onToggleShowAll: () {
                        setState(() {
                          _showAllMobileRecommendations =
                              !_showAllMobileRecommendations;
                        });
                      },
                      onFeedback: (
                        AiRecommendationItem recommendation,
                        String reaction,
                      ) {
                        coordinator.submitRecommendationFeedback(
                          recommendation: recommendation,
                          reaction: reaction,
                        );
                      },
                      isSmallScreen: true,
                      useCardShadow: false,
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
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Icon(
                        Icons.cleaning_services,
                        size: 15,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  child: SaveLoadBuildContent(
                    hasSaveLimit: hasSaveLimit,
                    canSaveBuild: canSaveBuild,
                    saveLimitMessage: _guestSaveLimitMessage,
                    buildNameController: _buildNameController,
                    onSaveBuild: _onSaveBuild,
                    onImportCode: _onRequestImportBuildShareCode,
                    savedBuilds: visibleSavedBuilds.asMap().entries.map((
                      MapEntry<int, Map<String, dynamic>> entry,
                    ) {
                      final int index = entry.key;
                      final Map<String, dynamic> build = entry.value;
                      final String buildId = _buildIdOf(build);
                      final bool canControl = buildId.isNotEmpty;
                      return SaveBuildEntry(
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
                    }).toList(growable: false),
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
