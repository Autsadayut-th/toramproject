import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../account_page/account_page.dart';
import '../build_simulator/build_simulator_coordinator.dart';
import '../build_simulator/build_simulator_page.dart';
import '../build_simulator/services/build_calculator_service.dart';
import '../build_simulator/services/build_persistence_service.dart';
import '../compare_builds_page/compare_builds_page.dart';
import '../critical_simulator_page/critical_simulator_page.dart';
import '../equipment_library/equipment_library_page.dart';
import '../saved_builds_page/saved_builds_page.dart';
import '../settings_data_page/settings_data_page.dart';
import '../shared/app_navigation_drawer.dart';
import '../shared/app_mobile_bottom_navigation_bar.dart';
import '../skill_menu_page/skill_menu_page.dart';

part 'widgets/build_mobile_drawer.dart';
part 'widgets/build_mobile_drawer_widgets.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  static const String _appLogoAssetPath = 'assets/logo/logo.png';
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
      case AppNavigationPage.critical:
        return 2;
      case AppNavigationPage.skill:
        return 3;
      case AppNavigationPage.saved:
        return 4;
      case AppNavigationPage.compare:
        return 5;
      case AppNavigationPage.settings:
        return 6;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 1024;
    final bool showMobileBuildSummaryLeading =
        isMobile && _currentPage == AppNavigationPage.build;

    void onNavigateFromDrawer(AppNavigationPage page) {
      Navigator.of(context).pop();
      _onNavigate(page);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
        leadingWidth: 84,
        titleSpacing: 6,
        title: Text(
          _getPageTitle(_currentPage),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (BuildContext context) {
            return Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  tooltip: showMobileBuildSummaryLeading
                      ? 'Build Summary'
                      : 'Navigation menu',
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E0E0E),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.36),
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Image.asset(
                    _appLogoAssetPath,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder:
                        (BuildContext context, Object _, StackTrace? __) =>
                            const Icon(
                              Icons.auto_awesome,
                              size: 15,
                              color: Colors.white,
                            ),
                  ),
                ),
              ],
            );
          },
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
          BuildSimulatorScreen(
            coordinator: _coordinator,
            currentUserId: _currentUser?.uid,
            isAuthenticated: _currentUser != null,
            hasAdvancedAccess: _currentUser != null,
          ),
          EquipmentLibraryScreen(onNavigate: _onNavigate),
          const CriticalSimulatorPage(),
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
      drawer: showMobileBuildSummaryLeading
          ? _BuildStatsSummaryDrawer(
              coordinator: _coordinator,
              hasAdvancedAccess: _currentUser != null,
            )
          : AppNavigationDrawer(
              currentPage: _currentPage,
              onOpenBuild: () => onNavigateFromDrawer(AppNavigationPage.build),
              onOpenEquipment: () =>
                  onNavigateFromDrawer(AppNavigationPage.equipment),
              onOpenCritical: () =>
                  onNavigateFromDrawer(AppNavigationPage.critical),
              onOpenSkill: () => onNavigateFromDrawer(AppNavigationPage.skill),
              onOpenSaved: () => onNavigateFromDrawer(AppNavigationPage.saved),
              onOpenCompare: () =>
                  onNavigateFromDrawer(AppNavigationPage.compare),
              onOpenSettings: () =>
                  onNavigateFromDrawer(AppNavigationPage.settings),
            ),
    );
  }

  String _getPageTitle(AppNavigationPage page) {
    switch (page) {
      case AppNavigationPage.build:
        return 'Toram Item Build Simulation';
      case AppNavigationPage.equipment:
        return 'Equipment Library';
      case AppNavigationPage.critical:
        return 'Critical Simulator';
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
