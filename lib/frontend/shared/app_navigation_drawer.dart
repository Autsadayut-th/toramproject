import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AppNavigationPage { build, equipment, skill, saved, compare, settings }

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({
    super.key,
    required this.currentPage,
    required this.onOpenBuild,
    required this.onOpenEquipment,
    required this.onOpenSkill,
    required this.onOpenSaved,
    required this.onOpenCompare,
    required this.onOpenSettings,
  });

  final AppNavigationPage currentPage;
  final VoidCallback onOpenBuild;
  final VoidCallback onOpenEquipment;
  final VoidCallback onOpenSkill;
  final VoidCallback onOpenSaved;
  final VoidCallback onOpenCompare;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final bool isAuthenticated = FirebaseAuth.instance.currentUser != null;

    return Drawer(
      backgroundColor: const Color(0xFF000000),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: const Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFF111111),
                          child: Icon(Icons.auto_awesome, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Build Tools',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _tile(
                    icon: Icons.build,
                    label: 'Build Simulator',
                    selected: currentPage == AppNavigationPage.build,
                    onTap: onOpenBuild,
                  ),
                  _tile(
                    icon: Icons.menu_book_outlined,
                    label: 'Equipment Library',
                    selected: currentPage == AppNavigationPage.equipment,
                    onTap: onOpenEquipment,
                  ),
                  _tile(
                    icon: Icons.auto_awesome_mosaic_outlined,
                    label: 'Skill Menu',
                    selected: currentPage == AppNavigationPage.skill,
                    onTap: onOpenSkill,
                  ),
                  _tile(
                    icon: Icons.bookmark_border,
                    label: 'Saved Builds',
                    selected: currentPage == AppNavigationPage.saved,
                    onTap: onOpenSaved,
                  ),
                  _tile(
                    icon: Icons.compare_arrows,
                    label: 'Compare Builds',
                    selected: currentPage == AppNavigationPage.compare,
                    onTap: onOpenCompare,
                  ),
                  _tile(
                    icon: Icons.settings_suggest,
                    label: 'Settings & Data',
                    selected: currentPage == AppNavigationPage.settings,
                    onTap: onOpenSettings,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.16),
                  ),
                ),
              ),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final NavigatorState navigator = Navigator.of(context);
                  navigator.pop();
                  if (isAuthenticated) {
                    await FirebaseAuth.instance.signOut();
                    return;
                  }
                  navigator.pushNamed('/login');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.36),
                  ),
                  minimumSize: const Size.fromHeight(44),
                ),
                icon: Icon(isAuthenticated ? Icons.logout : Icons.login),
                label: Text(isAuthenticated ? 'Logout' : 'Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.white : Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      selected: selected,
      selectedTileColor: const Color(0x22FFFFFF),
      onTap: onTap,
    );
  }
}
