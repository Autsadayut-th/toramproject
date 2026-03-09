import 'package:flutter/material.dart';

import '../equipment_library/models/equipment_library_item.dart';
import '../equipment_library/repository/equipment_library_repository.dart';
import '../shared/app_mobile_bottom_navigation_bar.dart';
import '../shared/app_navigation_drawer.dart';

class SavedBuildsPage extends StatefulWidget {
  const SavedBuildsPage({
    super.key,
    required this.savedBuilds,
    required this.onLoadBuild,
    required this.onDeleteBuild,
    required this.onRenameBuild,
    required this.onToggleFavoriteBuild,
    this.onNavigate,
  });

  final List<Map<String, dynamic>> savedBuilds;
  final ValueChanged<String> onLoadBuild;
  final ValueChanged<String> onDeleteBuild;
  final void Function(String buildId, String nextName) onRenameBuild;
  final ValueChanged<String> onToggleFavoriteBuild;
  final ValueChanged<AppNavigationPage>? onNavigate;

  @override
  State<SavedBuildsPage> createState() => _SavedBuildsPageState();
}

class _SavedBuildsPageState extends State<SavedBuildsPage> {
  final EquipmentLibraryRepository _equipmentRepository =
      EquipmentLibraryRepository();
  late final TextEditingController _searchController;
  late List<Map<String, dynamic>> _builds;
  Map<String, String> _equipmentNameByKey = <String, String>{};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _builds = widget.savedBuilds
        .map((Map<String, dynamic> build) => Map<String, dynamic>.from(build))
        .toList(growable: true);
    _loadEquipmentNames();
  }

  @override
  void didUpdateWidget(covariant SavedBuildsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.savedBuilds != widget.savedBuilds) {
      _builds = widget.savedBuilds
          .map((Map<String, dynamic> build) => Map<String, dynamic>.from(build))
          .toList(growable: true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _buildId(Map<String, dynamic> build, int index) {
    final String id = build['id']?.toString().trim() ?? '';
    if (id.isNotEmpty) {
      return id;
    }
    return 'legacy_build_$index';
  }

  bool _isFavorite(Map<String, dynamic> build) {
    return build['isFavorite'] == true;
  }

  String _displayName(Map<String, dynamic> build, int index) {
    final String rawName = build['name']?.toString().trim() ?? '';
    if (rawName.isNotEmpty) {
      return rawName;
    }
    return 'Build ${index + 1}';
  }

  String _slotLabel(dynamic value) {
    final String key = value?.toString().trim() ?? '';
    if (key.isEmpty) {
      return '-';
    }
    final String normalizedKey = key.toLowerCase();
    final String? name = _equipmentNameByKey[normalizedKey];
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return _humanizeEquipmentKey(key);
  }

  String _humanizeEquipmentKey(String key) {
    final String normalized = key
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ')
        .trim();
    if (normalized.isEmpty) {
      return key;
    }
    return normalized
        .split(RegExp(r'\s+'))
        .where((String token) => token.isNotEmpty)
        .map((String token) {
          if (token == token.toUpperCase()) {
            return token;
          }
          return token[0].toUpperCase() + token.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Future<void> _loadEquipmentNames() async {
    try {
      final Map<String, List<EquipmentLibraryItem>> categories =
          await _equipmentRepository.loadAllCategories();
      final Map<String, String> nextMap = <String, String>{};
      for (final List<EquipmentLibraryItem> items in categories.values) {
        for (final EquipmentLibraryItem item in items) {
          final String key = item.key.trim().toLowerCase();
          final String name = item.name.trim();
          if (key.isEmpty || name.isEmpty) {
            continue;
          }
          nextMap[key] = name;
        }
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _equipmentNameByKey = nextMap;
      });
    } catch (_) {
      // Keep fallback label formatting when remote library is unavailable.
    }
  }

  int _summaryValue(Map<String, dynamic> build, String key) {
    final dynamic summary = build['summary'];
    if (summary is! Map) {
      return 0;
    }
    final dynamic rawValue = summary[key];
    if (rawValue is num) {
      return rawValue.toInt();
    }
    if (rawValue is String) {
      return int.tryParse(rawValue.trim()) ?? 0;
    }
    return 0;
  }

  String _equipmentPreview(Map<String, dynamic> build) {
    return 'Main ${_slotLabel(build['mainWeaponId'])} | '
        'Sub ${_slotLabel(build['subWeaponId'])} | '
        'Armor ${_slotLabel(build['armorId'])} | '
        'Helmet ${_slotLabel(build['helmetId'])} | '
        'Ring ${_slotLabel(build['ringId'])}';
  }

  DateTime? _savedAt(Map<String, dynamic> build) {
    final String raw = build['savedAt']?.toString().trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  String _savedAtLabel(Map<String, dynamic> build) {
    final DateTime? savedAt = _savedAt(build);
    if (savedAt == null) {
      return 'Saved: -';
    }
    final DateTime local = savedAt.toLocal();
    final String day = local.day.toString().padLeft(2, '0');
    final String month = local.month.toString().padLeft(2, '0');
    final String year = local.year.toString();
    final String hour = local.hour.toString().padLeft(2, '0');
    final String minute = local.minute.toString().padLeft(2, '0');
    return 'Saved: $day/$month/$year $hour:$minute';
  }

  void _loadBuildFromCard(String buildId) {
    widget.onLoadBuild(buildId);
    if (widget.onNavigate != null) {
      widget.onNavigate!(AppNavigationPage.build);
      return;
    }
    Navigator.of(context).pop();
  }

  Widget _sectionTitle(String title) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.75),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _slotRow(String label, String value) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 58,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, int value) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.24),
        ),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.75),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color resolvedColor = color ?? colorScheme.onSurface;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 15),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: resolvedColor,
          side: BorderSide(color: resolvedColor.withValues(alpha: 0.36)),
          backgroundColor: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildSavedBuildCard({
    required BuildContext context,
    required Map<String, dynamic> build,
    required int sourceIndex,
    required int fallbackIndex,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String buildId = _buildId(
      build,
      sourceIndex >= 0 ? sourceIndex : fallbackIndex,
    );
    final String name = _displayName(
      build,
      sourceIndex >= 0 ? sourceIndex : fallbackIndex,
    );
    final bool favorite = _isFavorite(build);
    final List<(String, String)> slots = <(String, String)>[
      ('Main', _slotLabel(build['mainWeaponId'])),
      ('Sub', _slotLabel(build['subWeaponId'])),
      ('Armor', _slotLabel(build['armorId'])),
      ('Helmet', _slotLabel(build['helmetId'])),
      ('Ring', _slotLabel(build['ringId'])),
    ];
    final List<(String, int)> stats = <(String, int)>[
      ('ATK', _summaryValue(build, 'ATK')),
      ('DEF', _summaryValue(build, 'DEF')),
      ('MDEF', _summaryValue(build, 'MDEF')),
      ('HP', _summaryValue(build, 'HP')),
      ('MP', _summaryValue(build, 'MP')),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surfaceContainerHigh,
            colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.2)),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool useWideLayout = constraints.maxWidth >= 1100;
          if (!useWideLayout) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          build['isFavorite'] = !favorite;
                        });
                        widget.onToggleFavoriteBuild(buildId);
                      },
                      icon: Icon(
                        favorite ? Icons.star : Icons.star_border,
                        color: favorite
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                    ),
                  ],
                ),
                Text(
                  _savedAtLabel(build),
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.62),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _equipmentPreview(build),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: stats
                      .map(((String, int) item) => _statChip(item.$1, item.$2))
                      .toList(growable: false),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    FilledButton.tonalIcon(
                      onPressed: () => _loadBuildFromCard(buildId),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Load'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _renameBuild(build),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Rename'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _deleteBuild(build),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Delete'),
                      style: FilledButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _sectionTitle('Build'),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _savedAtLabel(build),
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.62),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: colorScheme.onSurface.withValues(alpha: 0.14),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _sectionTitle('Equipment'),
                    const SizedBox(height: 8),
                    ...slots.map(
                      ((String, String) item) => _slotRow(item.$1, item.$2),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: colorScheme.onSurface.withValues(alpha: 0.14),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _sectionTitle('Stats'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: stats
                          .map(
                            ((String, int) item) => _statChip(item.$1, item.$2),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: colorScheme.onSurface.withValues(alpha: 0.14),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        setState(() {
                          build['isFavorite'] = !favorite;
                        });
                        widget.onToggleFavoriteBuild(buildId);
                      },
                      icon: Icon(
                        favorite ? Icons.star : Icons.star_border,
                        color: favorite
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                      tooltip: favorite ? 'Remove favorite' : 'Mark favorite',
                    ),
                    const SizedBox(height: 4),
                    _actionButton(
                      label: 'Load',
                      icon: Icons.play_arrow,
                      onPressed: () => _loadBuildFromCard(buildId),
                    ),
                    const SizedBox(height: 8),
                    _actionButton(
                      label: 'Rename',
                      icon: Icons.edit_outlined,
                      onPressed: () => _renameBuild(build),
                    ),
                    const SizedBox(height: 8),
                    _actionButton(
                      label: 'Delete',
                      icon: Icons.delete_outline,
                      onPressed: () => _deleteBuild(build),
                      color: colorScheme.error,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _visibleBuilds() {
    final String keyword = _searchController.text.trim().toLowerCase();
    final List<Map<String, dynamic>> filtered = _builds
        .where((Map<String, dynamic> build) {
          if (keyword.isEmpty) {
            return true;
          }
          final String name = (build['name']?.toString() ?? '').toLowerCase();
          final String main = (build['mainWeaponId']?.toString() ?? '')
              .toLowerCase();
          final String armor = (build['armorId']?.toString() ?? '')
              .toLowerCase();
          return name.contains(keyword) ||
              main.contains(keyword) ||
              armor.contains(keyword);
        })
        .toList(growable: false);

    filtered.sort((Map<String, dynamic> left, Map<String, dynamic> right) {
      final int favoriteCompare = (_isFavorite(right) ? 1 : 0).compareTo(
        _isFavorite(left) ? 1 : 0,
      );
      if (favoriteCompare != 0) {
        return favoriteCompare;
      }

      final DateTime? leftSavedAt = _savedAt(left);
      final DateTime? rightSavedAt = _savedAt(right);
      if (leftSavedAt != null && rightSavedAt != null) {
        return rightSavedAt.compareTo(leftSavedAt);
      }
      if (leftSavedAt != null) {
        return -1;
      }
      if (rightSavedAt != null) {
        return 1;
      }

      final String leftName = (left['name']?.toString() ?? '').toLowerCase();
      final String rightName = (right['name']?.toString() ?? '').toLowerCase();
      return leftName.compareTo(rightName);
    });

    return filtered;
  }

  Future<void> _renameBuild(Map<String, dynamic> build) async {
    final TextEditingController controller = TextEditingController(
      text: build['name']?.toString() ?? '',
    );
    final String? nextName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surfaceContainerHigh,
          title: Text(
            'Rename Build',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Enter build name',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.54),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (nextName == null || nextName.isEmpty) {
      return;
    }

    final int localIndex = _builds.indexOf(build);
    if (localIndex < 0) {
      return;
    }
    final String buildId = _buildId(build, localIndex);
    setState(() {
      _builds[localIndex]['name'] = nextName;
    });
    widget.onRenameBuild(buildId, nextName);
  }

  Future<void> _deleteBuild(Map<String, dynamic> build) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            final ColorScheme colorScheme = Theme.of(context).colorScheme;
            return AlertDialog(
              backgroundColor: colorScheme.surfaceContainerHigh,
              title: Text(
                'Delete Build',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              content: Text(
                'This action removes the selected build from your saved list.',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              actions: [
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

    final int localIndex = _builds.indexOf(build);
    if (localIndex < 0) {
      return;
    }
    final String buildId = _buildId(build, localIndex);

    setState(() {
      _builds.removeAt(localIndex);
    });
    widget.onDeleteBuild(buildId);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<Map<String, dynamic>> visibleBuilds = _visibleBuilds();
    final bool isMobile = MediaQuery.sizeOf(context).width < 1024;
    final bool isEmbeddedInShell = widget.onNavigate != null;

    void onSelectMobileNav(AppNavigationPage page) {
      if (page == AppNavigationPage.saved) {
        return;
      }
      widget.onNavigate?.call(page);
    }

    final Widget content = ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: colorScheme.onSurface),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by name or equipment key',
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.54),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.onSurface.withValues(alpha: 0.24),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.onSurface.withValues(alpha: 0.24),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: visibleBuilds.isEmpty
                ? Center(
                    child: Text(
                      'No saved builds found.',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: visibleBuilds.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> build = visibleBuilds[index];
                      final int sourceIndex = _builds.indexOf(build);
                      return _buildSavedBuildCard(
                        context: context,
                        build: build,
                        sourceIndex: sourceIndex,
                        fallbackIndex: index,
                      );
                    },
                  ),
          ),
        ],
      ),
    );

    if (isEmbeddedInShell) {
      return content;
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      drawer: isMobile
          ? null
          : AppNavigationDrawer(
              currentPage: AppNavigationPage.saved,
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
              onOpenSaved: () => Navigator.of(context).pop(),
              onOpenCompare: () {
                Navigator.of(context).pop();
                widget.onNavigate?.call(AppNavigationPage.compare);
              },
              onOpenSettings: () {
                Navigator.of(context).pop();
                widget.onNavigate?.call(AppNavigationPage.settings);
              },
            ),
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        automaticallyImplyLeading: false,
        leading: isMobile
            ? null
            : Builder(
                builder: (BuildContext context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        title: Text('Saved Builds (${_builds.length})'),
      ),
      body: content,
      bottomNavigationBar: isMobile
          ? AppMobileBottomNavigationBar(
              currentPage: AppNavigationPage.saved,
              onSelect: onSelectMobileNav,
            )
          : null,
    );
  }
}
