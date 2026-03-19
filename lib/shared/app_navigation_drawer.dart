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
    this.showOnlyBuild = false,
  });

  final AppNavigationPage currentPage;
  final VoidCallback onOpenBuild;
  final VoidCallback onOpenEquipment;
  final VoidCallback? onOpenCritical;
  final VoidCallback onOpenSkill;
  final VoidCallback onOpenSaved;
  final VoidCallback onOpenCompare;
  final VoidCallback onOpenSettings;
  final bool showOnlyBuild;

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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool firebaseAvailable = _isFirebaseAvailable();
    final bool isAuthenticated = _readAuthenticatedState(firebaseAvailable);
    final bool isMobile = MediaQuery.sizeOf(context).width < 1024;
    final bool showBuildOnly = showOnlyBuild || isMobile;

    return Drawer(
      backgroundColor: colorScheme.surface,
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
                          color: colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.28,
                              ),
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
                                ) => Icon(
                                  Icons.auto_awesome,
                                  color: colorScheme.onSurface,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Build Tools',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _tile(
                    context: context,
                    icon: Icons.build,
                    label: 'Build Simulator',
                    selected: currentPage == AppNavigationPage.build,
                    onTap: onOpenBuild,
                  ),
                  if (!showBuildOnly)
                    _tile(
                      context: context,
                      icon: Icons.menu_book_outlined,
                      label: 'Equipment Library',
                      selected: currentPage == AppNavigationPage.equipment,
                      onTap: onOpenEquipment,
                    ),
                  if (!showBuildOnly && onOpenCritical != null)
                    _tile(
                      context: context,
                      icon: Icons.track_changes,
                      label: 'Critical Simulator',
                      selected: currentPage == AppNavigationPage.critical,
                      onTap: onOpenCritical!,
                    ),
                  if (!showBuildOnly)
                    _tile(
                      context: context,
                      icon: Icons.bookmark_border,
                      label: 'Saved Builds',
                      selected: currentPage == AppNavigationPage.saved,
                      onTap: onOpenSaved,
                    ),
                  if (!showBuildOnly)
                    _tile(
                      context: context,
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
                    color: colorScheme.onSurface.withValues(alpha: 0.16),
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
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(
                    color: colorScheme.onSurface.withValues(alpha: 0.36),
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
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        icon,
        color: selected
            ? colorScheme.onSurface
            : colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      title: Text(label, style: TextStyle(color: colorScheme.onSurface)),
      selected: selected,
      selectedTileColor: colorScheme.onSurface.withValues(alpha: 0.12),
      onTap: onTap,
    );
  }
}
