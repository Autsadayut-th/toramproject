import 'package:flutter/material.dart';

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
  late final TextEditingController _searchController;
  late List<Map<String, dynamic>> _builds;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _builds = widget.savedBuilds
        .map((Map<String, dynamic> build) => Map<String, dynamic>.from(build))
        .toList(growable: true);
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
    return key;
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

  String _statsPreview(Map<String, dynamic> build) {
    return 'ATK ${_summaryValue(build, 'ATK')}   '
        'DEF ${_summaryValue(build, 'DEF')}   '
        'MDEF ${_summaryValue(build, 'MDEF')}   '
        'HP ${_summaryValue(build, 'HP')}   '
        'MP ${_summaryValue(build, 'MP')}';
  }

  DateTime? _savedAt(Map<String, dynamic> build) {
    final String raw = build['savedAt']?.toString().trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
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
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Rename Build'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter build name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
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
          builder: (BuildContext context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text('Delete Build'),
            content: const Text(
              'This action removes the selected build from your saved list.',
            ),
            actions: [
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
          ),
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
    final List<Map<String, dynamic>> visibleBuilds = _visibleBuilds();
    final bool isMobile = MediaQuery.sizeOf(context).width < 1024;
    final bool isEmbeddedInShell = widget.onNavigate != null;

    void onSelectMobileNav(AppNavigationPage page) {
      if (page == AppNavigationPage.saved) {
        return;
      }
      widget.onNavigate?.call(page);
    }

    final Widget content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search by name or equipment key',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: visibleBuilds.isEmpty
              ? const Center(
                  child: Text(
                    'No saved builds found.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: visibleBuilds.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> build = visibleBuilds[index];
                    final int sourceIndex = _builds.indexOf(build);
                    final String buildId = _buildId(
                      build,
                      sourceIndex >= 0 ? sourceIndex : index,
                    );
                    final String name = _displayName(
                      build,
                      sourceIndex >= 0 ? sourceIndex : index,
                    );
                    final bool favorite = _isFavorite(build);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF888888),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(
                            0xFFFFFFFF,
                          ).withValues(alpha: 0.16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
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
                                      ? const Color(0xFF888888)
                                      : Colors.white70,
                                ),
                                tooltip: favorite
                                    ? 'Remove favorite'
                                    : 'Mark favorite',
                              ),
                            ],
                          ),
                          Text(
                            _equipmentPreview(build),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _statsPreview(build),
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () {
                                  widget.onLoadBuild(buildId);
                                  if (widget.onNavigate != null) {
                                    widget.onNavigate!(AppNavigationPage.build);
                                    return;
                                  }
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Load'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: () => _renameBuild(build),
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Rename'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: () => _deleteBuild(build),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Delete'),
                                style: FilledButton.styleFrom(
                                  foregroundColor: const Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );

    if (isEmbeddedInShell) {
      return content;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
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
