import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../account_page/account_page.dart';
import '../build_simulator/build_simulator_coordinator.dart';
import '../build_simulator/build_simulator_page.dart';
import '../compare_builds_page/compare_builds_page.dart';
import '../equipment_library/equipment_library_page.dart';
import '../saved_builds_page/saved_builds_page.dart';
import '../settings_data_page/settings_data_page.dart';
import '../shared/app_navigation_drawer.dart';
import '../shared/app_mobile_bottom_navigation_bar.dart';
import '../skill_menu_page/skill_menu_page.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  final BuildSimulatorCoordinator _coordinator = BuildSimulatorCoordinator();
  AppNavigationPage _currentPage = AppNavigationPage.build;
  User? _currentUser;
  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _coordinator.addListener(_onCoordinatorChanged);
    _currentUser = FirebaseAuth.instance.currentUser;
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      if (!mounted) return;
      setState(() {
        _currentUser = user;
      });
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _coordinator
      ..removeListener(_onCoordinatorChanged)
      ..detachHandlers();
    super.dispose();
  }

  void _onCoordinatorChanged() {
    if (!mounted) {
      return;
    }
    if (_currentPage == AppNavigationPage.build) {
      return;
    }
    setState(() {});
  }

  void _onNavigate(AppNavigationPage page) {
    if (_currentPage == page) {
      return;
    }
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _openAccountPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            AccountPage(initialEmail: _currentUser?.email ?? ''),
      ),
    );
  }

  int _indexOf(AppNavigationPage page) {
    switch (page) {
      case AppNavigationPage.build:
        return 0;
      case AppNavigationPage.equipment:
        return 1;
      case AppNavigationPage.skill:
        return 2;
      case AppNavigationPage.saved:
        return 3;
      case AppNavigationPage.compare:
        return 4;
      case AppNavigationPage.settings:
        return 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 1024;

    void onNavigateFromDrawer(AppNavigationPage page) {
      Navigator.of(context).pop();
      _onNavigate(page);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
        title: Text(
          _getPageTitle(_currentPage),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: _openAccountPage,
            tooltip: 'Account',
          ),
          if (_currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              tooltip: 'Logout',
            )
          else
            IconButton(
              icon: const Icon(Icons.login, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
              tooltip: 'Login',
            ),
        ],
      ),
      body: IndexedStack(
        index: _indexOf(_currentPage),
        children: <Widget>[
          BuildSimulatorScreen(coordinator: _coordinator),
          EquipmentLibraryScreen(onNavigate: _onNavigate),
          SkillMenuPage(onNavigate: _onNavigate),
          SavedBuildsPage(
            savedBuilds: _coordinator.savedBuilds,
            onLoadBuild: _coordinator.loadBuildById,
            onDeleteBuild: _coordinator.deleteBuildById,
            onRenameBuild: _coordinator.renameBuildById,
            onToggleFavoriteBuild: _coordinator.toggleFavoriteBuildById,
            onNavigate: _onNavigate,
          ),
          CompareBuildsPage(
            savedBuilds: _coordinator.savedBuilds,
            onLoadBuild: _coordinator.loadBuildById,
            onNavigate: _onNavigate,
          ),
          SettingsDataPage(
            savedBuilds: _coordinator.savedBuilds,
            equipmentCacheCount: _coordinator.equipmentCacheCount,
            showRecommendations: _coordinator.showRecommendations,
            onShowRecommendationsChanged: _coordinator.setShowRecommendations,
            onReplaceSavedBuilds: _coordinator.replaceSavedBuilds,
            onMergeSavedBuilds: _coordinator.mergeSavedBuilds,
            onClearAllData: _coordinator.clearAllData,
            onNavigate: _onNavigate,
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? AppMobileBottomNavigationBar(
              currentPage: _currentPage,
              onSelect: _onNavigate,
            )
          : null,
      drawer: !isMobile
          ? AppNavigationDrawer(
              currentPage: _currentPage,
              onOpenBuild: () => onNavigateFromDrawer(AppNavigationPage.build),
              onOpenEquipment: () =>
                  onNavigateFromDrawer(AppNavigationPage.equipment),
              onOpenSkill: () => onNavigateFromDrawer(AppNavigationPage.skill),
              onOpenSaved: () => onNavigateFromDrawer(AppNavigationPage.saved),
              onOpenCompare: () =>
                  onNavigateFromDrawer(AppNavigationPage.compare),
              onOpenSettings: () =>
                  onNavigateFromDrawer(AppNavigationPage.settings),
            )
          : _currentPage == AppNavigationPage.build
          ? _BuildStatsSummaryDrawer(coordinator: _coordinator)
          : null,
    );
  }

  String _getPageTitle(AppNavigationPage page) {
    switch (page) {
      case AppNavigationPage.build:
        return 'Toram Item Build Simulation';
      case AppNavigationPage.equipment:
        return 'Equipment Library';
      case AppNavigationPage.skill:
        return 'Skill Menu';
      case AppNavigationPage.saved:
        return 'Saved Builds';
      case AppNavigationPage.compare:
        return 'Compare Builds';
      case AppNavigationPage.settings:
        return 'Settings & Data';
    }
  }
}

class _BuildStatsSummaryDrawer extends StatefulWidget {
  const _BuildStatsSummaryDrawer({required this.coordinator});

  final BuildSimulatorCoordinator coordinator;

  @override
  State<_BuildStatsSummaryDrawer> createState() =>
      _BuildStatsSummaryDrawerState();
}

class _BuildStatsSummaryDrawerState extends State<_BuildStatsSummaryDrawer> {
  final TextEditingController _buildNameController = TextEditingController();

  static const Set<String> _percentKeys = <String>{
    'CritRate',
    'PhysicalPierce',
    'ElementPierce',
    'Stability',
  };

  static const List<String> _recommendations = <String>[
    'Choose a main weapon that matches your core stats.',
    'Use crystals that increase ATK or Critical Rate.',
    'Balance DEF and MDEF to fit your build.',
  ];

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
                  child: Column(
                    children: <Widget>[
                      _StatsCategoryBlock(
                        title: 'Attack',
                        rows: <MapEntry<String, String>>[
                          const MapEntry<String, String>('ATK', 'ATK'),
                          const MapEntry<String, String>('MATK', 'MATK'),
                        ],
                        summary: summary,
                        percentKeys: _percentKeys,
                      ),
                      _StatsCategoryBlock(
                        title: 'Defense',
                        rows: <MapEntry<String, String>>[
                          const MapEntry<String, String>('DEF', 'DEF'),
                          const MapEntry<String, String>('MDEF', 'MDEF'),
                        ],
                        summary: summary,
                        percentKeys: _percentKeys,
                      ),
                      _StatsCategoryBlock(
                        title: 'Main Stats',
                        rows: <MapEntry<String, String>>[
                          const MapEntry<String, String>('STR', 'STR'),
                          const MapEntry<String, String>('DEX', 'DEX'),
                          const MapEntry<String, String>('INT', 'INT'),
                          const MapEntry<String, String>('AGI', 'AGI'),
                          const MapEntry<String, String>('VIT', 'VIT'),
                        ],
                        summary: summary,
                        percentKeys: _percentKeys,
                      ),
                      _StatsCategoryBlock(
                        title: 'Special Stats',
                        rows: <MapEntry<String, String>>[
                          const MapEntry<String, String>('ASPD', 'ASPD'),
                          const MapEntry<String, String>(
                            'CritRate',
                            'Critical Rate',
                          ),
                          const MapEntry<String, String>(
                            'PhysicalPierce',
                            'Piercing (Physical)',
                          ),
                          const MapEntry<String, String>(
                            'ElementPierce',
                            'Piercing (Element)',
                          ),
                          const MapEntry<String, String>(
                            'Accuracy',
                            'Accuracy',
                          ),
                          const MapEntry<String, String>(
                            'Stability',
                            'Stability',
                          ),
                          const MapEntry<String, String>('HP', 'HP'),
                          const MapEntry<String, String>('MP', 'MP'),
                        ],
                        summary: summary,
                        percentKeys: _percentKeys,
                      ),
                    ],
                  ),
                ),
                if (coordinator.showRecommendations) ...<Widget>[
                  const SizedBox(height: 12),
                  _DrawerSectionCard(
                    title: 'AI Recommendations',
                    icon: Icons.lightbulb_outline,
                    child: Column(
                      children: List<Widget>.generate(_recommendations.length, (
                        int index,
                      ) {
                        return _RecommendationTile(
                          index: index + 1,
                          message: _recommendations[index],
                        );
                      }),
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

class _DrawerSectionCard extends StatelessWidget {
  const _DrawerSectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.index, required this.message});

  final int index;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$index.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedBuildTile extends StatelessWidget {
  const _SavedBuildTile({
    required this.name,
    required this.statsLine,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onLoad,
    required this.onDelete,
  });

  final String name;
  final String statsLine;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onLoad;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.amberAccent : Colors.white70,
                  size: 18,
                ),
                tooltip: isFavorite ? 'Unfavorite' : 'Favorite',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Text(
            statsLine,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              TextButton.icon(
                onPressed: onLoad,
                icon: const Icon(Icons.upload_file, size: 15),
                label: const Text('Load'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 15),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsCategoryBlock extends StatelessWidget {
  const _StatsCategoryBlock({
    required this.title,
    required this.rows,
    required this.summary,
    required this.percentKeys,
  });

  final String title;
  final List<MapEntry<String, String>> rows;
  final Map<String, num> summary;
  final Set<String> percentKeys;

  String _displayValue(String key) {
    final num value = summary[key] ?? 0;
    if (percentKeys.contains(key)) {
      return '${value.toInt()}%';
    }
    return value.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...rows.map((MapEntry<String, String> row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      row.value,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    _displayValue(row.key),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
