import 'dart:async';

import 'dart:math' as math;

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

part 'widgets/build_mobile_drawer.dart';
part 'widgets/build_mobile_drawer_widgets.dart';
part 'widgets/build_mobile_radar_chart.dart';

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


