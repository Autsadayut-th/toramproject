import 'package:flutter/material.dart';

import '../shared/app_mobile_bottom_navigation_bar.dart';
import '../shared/app_navigation_drawer.dart';
import 'models/equipment_library_item.dart';
import 'repository/equipment_library_repository.dart';

part 'equipment_library_data_view.dart';
part 'equipment_library_details_sheet.dart';
part 'equipment_library_grid.dart';
part 'equipment_library_pagination.dart';
part 'equipment_library_formatters.dart';

class EquipmentLibraryScreen extends StatelessWidget {
  const EquipmentLibraryScreen({
    super.key,
    this.pickMode = false,
    this.initialCategory,
    this.allowedCategories,
    this.title = 'Equipment Library',
    this.onNavigate,
  });

  final bool pickMode;
  final String? initialCategory;
  final List<String>? allowedCategories;
  final String title;
  final ValueChanged<AppNavigationPage>? onNavigate;

  static Future<String?> pickItemKey(
    BuildContext context, {
    required String initialCategory,
    required String title,
    List<String>? allowedCategories,
  }) async {
    final EquipmentLibraryItem? selected = await Navigator.of(context)
        .push<EquipmentLibraryItem>(
          MaterialPageRoute<EquipmentLibraryItem>(
            builder: (_) => EquipmentLibraryScreen(
              pickMode: true,
              initialCategory: initialCategory,
              allowedCategories: allowedCategories,
              title: title,
            ),
          ),
        );
    return selected?.key;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.sizeOf(context).width < 1024;
    final bool isEmbeddedInShell = !pickMode && onNavigate != null;
    final bool showMobileNav = !pickMode && !isEmbeddedInShell && isMobile;
    final bool showGlobalMenu = !pickMode && !isEmbeddedInShell && !isMobile;

    void onSelectMobileNav(AppNavigationPage page) {
      if (page == AppNavigationPage.equipment) {
        return;
      }
      onNavigate?.call(page);
    }

    final Widget content = _EquipmentLibraryDataView(
      pickMode: pickMode,
      initialCategory: initialCategory,
      allowedCategories: allowedCategories,
    );

    if (isEmbeddedInShell) {
      return content;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      drawer: showGlobalMenu
          ? AppNavigationDrawer(
              currentPage: AppNavigationPage.equipment,
              onOpenBuild: () {
                Navigator.of(context).pop();
                onNavigate?.call(AppNavigationPage.build);
              },
              onOpenEquipment: () => Navigator.of(context).pop(),
              onOpenSkill: () {
                Navigator.of(context).pop();
                onNavigate?.call(AppNavigationPage.skill);
              },
              onOpenSaved: () {
                Navigator.of(context).pop();
                onNavigate?.call(AppNavigationPage.saved);
              },
              onOpenCompare: () {
                Navigator.of(context).pop();
                onNavigate?.call(AppNavigationPage.compare);
              },
              onOpenSettings: () {
                Navigator.of(context).pop();
                onNavigate?.call(AppNavigationPage.settings);
              },
            )
          : null,
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: !showGlobalMenu && !showMobileNav,
        leading: showGlobalMenu
            ? Builder(
                builder: (BuildContext context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
      ),
      body: content,
      bottomNavigationBar: showMobileNav
          ? AppMobileBottomNavigationBar(
              currentPage: AppNavigationPage.equipment,
              onSelect: onSelectMobileNav,
            )
          : null,
    );
  }
}
