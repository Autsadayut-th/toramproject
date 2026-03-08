import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

const String _appLogoAssetPath = 'assets/logo/logo.png';

enum AppNavigationPage {
  build,
  equipment,
  critical,
  skill,
  saved,
  compare,
  settings,
}

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({
    super.key,
    required this.currentPage,
    required this.onOpenBuild,
    required this.onOpenEquipment,
    this.onOpenCritical,
    required this.onOpenSkill,
    required this.onOpenSaved,
    required this.onOpenCompare,
    required this.onOpenSettings,
  });

  final AppNavigationPage currentPage;
  final VoidCallback onOpenBuild;
  final VoidCallback onOpenEquipment;
  final VoidCallback? onOpenCritical;
  final VoidCallback onOpenSkill;
  final VoidCallback onOpenSaved;
  final VoidCallback onOpenCompare;
  final VoidCallback onOpenSettings;

  bool _isFirebaseAvailable() {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool _readAuthenticatedState(bool firebaseAvailable) {
    if (!firebaseAvailable) {
      return false;
    }
    try {
      return FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool firebaseAvailable = _isFirebaseAvailable();
    final bool isAuthenticated = _readAuthenticatedState(firebaseAvailable);

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
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E0E0E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(
                                0xFFFFFFFF,
                              ).withValues(alpha: 0.28),
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Image.asset(
                            _appLogoAssetPath,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                            errorBuilder:
                                (
                                  BuildContext context,
                                  Object _,
                                  StackTrace? __,
                                ) => const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
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
                  if (onOpenCritical != null)
                    _tile(
                      icon: Icons.track_changes,
                      label: 'Critical Simulator',
                      selected: currentPage == AppNavigationPage.critical,
                      onTap: onOpenCritical!,
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
                onPressed: !firebaseAvailable
                    ? null
                    : () async {
                        final NavigatorState navigator = Navigator.of(context);
                        navigator.pop();
                        if (isAuthenticated) {
                          try {
                            await FirebaseAuth.instance.signOut();
                          } catch (_) {}
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
                icon: Icon(
                  !firebaseAvailable
                      ? Icons.cloud_off
                      : isAuthenticated
                      ? Icons.logout
                      : Icons.login,
                ),
                label: Text(
                  !firebaseAvailable
                      ? 'Firebase unavailable'
                      : isAuthenticated
                      ? 'Logout'
                      : 'Login',
                ),
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
