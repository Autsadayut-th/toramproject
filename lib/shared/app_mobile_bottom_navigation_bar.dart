import 'package:flutter/material.dart';

import 'app_navigation_drawer.dart';

class AppMobileBottomNavigationBar extends StatelessWidget {
  const AppMobileBottomNavigationBar({
    super.key,
    required this.currentPage,
    required this.onSelect,
  });

  final AppNavigationPage currentPage;
  final ValueChanged<AppNavigationPage> onSelect;

  int _selectedIndex() {
    switch (currentPage) {
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
    return BottomNavigationBar(
      currentIndex: _selectedIndex(),
      backgroundColor: const Color(0xFF0A0A0A),
      selectedItemColor: const Color(0xFFFFFFFF),
      unselectedItemColor: const Color(0xAAFFFFFF),
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (int index) {
        switch (index) {
          case 0:
            onSelect(AppNavigationPage.build);
            return;
          case 1:
            onSelect(AppNavigationPage.equipment);
            return;
          case 2:
            onSelect(AppNavigationPage.critical);
            return;
          case 3:
            onSelect(AppNavigationPage.skill);
            return;
          case 4:
            onSelect(AppNavigationPage.saved);
            return;
          case 5:
            onSelect(AppNavigationPage.compare);
            return;
          case 6:
            onSelect(AppNavigationPage.settings);
            return;
        }
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Build'),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          label: 'Equip',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.track_changes),
          label: 'Critical',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome_mosaic_outlined),
          label: 'Skill',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.compare_arrows),
          label: 'Compare',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_suggest),
          label: 'Settings',
        ),
      ],
    );
  }
}
