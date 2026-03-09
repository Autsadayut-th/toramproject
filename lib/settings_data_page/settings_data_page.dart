import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../map_library/map_library_page.dart';
import '../monster_library/monster_library_page.dart';
import '../shared/app_mobile_bottom_navigation_bar.dart';
import '../shared/app_theme_controller.dart';
import '../shared/app_navigation_drawer.dart';

class SettingsDataPage extends StatefulWidget {
  const SettingsDataPage({
    super.key,
    required this.savedBuilds,
    required this.equipmentCacheCount,
    required this.showRecommendations,
    required this.onShowRecommendationsChanged,
    required this.onReplaceSavedBuilds,
    required this.onMergeSavedBuilds,
    required this.onClearAllData,
    this.onNavigate,
  });

  final List<Map<String, dynamic>> savedBuilds;
  final int equipmentCacheCount;
  final bool showRecommendations;
  final ValueChanged<bool> onShowRecommendationsChanged;
  final ValueChanged<List<Map<String, dynamic>>> onReplaceSavedBuilds;
  final ValueChanged<List<Map<String, dynamic>>> onMergeSavedBuilds;
  final VoidCallback onClearAllData;
  final ValueChanged<AppNavigationPage>? onNavigate;

  @override
  State<SettingsDataPage> createState() => _SettingsDataPageState();
}

class _SettingsDataPageState extends State<SettingsDataPage> {
  late final TextEditingController _jsonController;
  late bool _showRecommendations;

  @override
  void initState() {
    super.initState();
    _jsonController = TextEditingController();
    _showRecommendations = widget.showRecommendations;
  }

  @override
  void didUpdateWidget(covariant SettingsDataPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showRecommendations != widget.showRecommendations) {
      _showRecommendations = widget.showRecommendations;
    }
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _exportBuilds() async {
    final String payload = const JsonEncoder.withIndent(
      '  ',
    ).convert(widget.savedBuilds);
    _jsonController.text = payload;
    await Clipboard.setData(ClipboardData(text: payload));
    _showMessage('Exported JSON and copied to clipboard.');
  }

  List<Map<String, dynamic>> _decodeBuilds(String source) {
    final dynamic decoded = jsonDecode(source);
    List<dynamic> rawBuilds;
    if (decoded is List) {
      rawBuilds = decoded;
    } else if (decoded is Map && decoded['builds'] is List) {
      rawBuilds = decoded['builds'] as List<dynamic>;
    } else {
      throw const FormatException(
        'JSON must be an array or an object with a "builds" array.',
      );
    }

    final List<Map<String, dynamic>> builds = rawBuilds
        .whereType<Map>()
        .map((Map map) => Map<String, dynamic>.from(map))
        .toList(growable: false);

    if (builds.isEmpty) {
      throw const FormatException('No valid build records were found.');
    }
    return builds;
  }

  void _importBuilds({required bool merge}) {
    final String source = _jsonController.text.trim();
    if (source.isEmpty) {
      _showMessage('Paste JSON before importing.');
      return;
    }

    try {
      final List<Map<String, dynamic>> decodedBuilds = _decodeBuilds(source);
      if (merge) {
        widget.onMergeSavedBuilds(decodedBuilds);
        _showMessage('Merged ${decodedBuilds.length} builds.');
      } else {
        widget.onReplaceSavedBuilds(decodedBuilds);
        _showMessage(
          'Replaced saved builds with ${decodedBuilds.length} builds.',
        );
      }
    } on FormatException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Failed to import builds. Please verify JSON format.');
    }
  }

  Future<void> _confirmClearAllData() async {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            backgroundColor: colorScheme.surfaceContainerHigh,
            title: const Text('Clear All Data'),
            content: const Text(
              'This action clears current build values, saved builds, and display settings.',
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
                child: const Text('Clear'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }
    widget.onClearAllData();
    setState(() {
      _showRecommendations = true;
      _jsonController.clear();
    });
    _showMessage('All simulator data were cleared.');
  }

  Future<void> _openMonsterLibrary() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MonsterLibraryPage()));
  }

  Future<void> _openMapLibrary() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MapLibraryPage()));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isMobile = MediaQuery.sizeOf(context).width < 1024;
    final bool isEmbeddedInShell = widget.onNavigate != null;
    final bool isLightTheme = AppThemeController.instance.isLightMode;

    void onSelectMobileNav(AppNavigationPage page) {
      if (page == AppNavigationPage.settings) {
        return;
      }
      widget.onNavigate?.call(page);
    }

    final Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panel(
            title: 'Session Data',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved builds: ${widget.savedBuilds.length}',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  'Equipment cache size: ${widget.equipmentCacheCount}',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _panel(
            title: 'Game Data Library',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Open dedicated pages for Monster and Map references.',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    FilledButton.tonalIcon(
                      onPressed: _openMonsterLibrary,
                      icon: const Icon(Icons.pets),
                      label: const Text('Open Monster Library'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _openMapLibrary,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Open Map Library'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _panel(
            title: 'Display',
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Show recommendations panel',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: Text(
                'Control visibility of AI recommendations in the simulator.',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              value: _showRecommendations,
              onChanged: (bool value) {
                setState(() {
                  _showRecommendations = value;
                });
                widget.onShowRecommendationsChanged(value);
              },
            ),
          ),
          const SizedBox(height: 14),
          _panel(
            title: 'Theme',
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Use light theme (white)',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: Text(
                'Turn off to use dark theme (black).',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              value: isLightTheme,
              onChanged: (bool value) {
                AppThemeController.instance.saveThemeModeUnawaited(
                  value ? ThemeMode.light : ThemeMode.dark,
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _panel(
            title: 'Import / Export JSON',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _exportBuilds,
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Export Saved Builds'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _importBuilds(merge: false),
                      icon: const Icon(Icons.file_download_outlined),
                      label: const Text('Import Replace'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _importBuilds(merge: true),
                      icon: const Icon(Icons.merge_type),
                      label: const Text('Import Merge'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _jsonController,
                  maxLines: 12,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Paste build JSON here...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _panel(
            title: 'Danger Zone',
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _confirmClearAllData,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Clear All Data'),
              ),
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
              currentPage: AppNavigationPage.settings,
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
              onOpenSettings: () => Navigator.of(context).pop(),
              onOpenSaved: () {
                Navigator.of(context).pop();
                widget.onNavigate?.call(AppNavigationPage.saved);
              },
              onOpenCompare: () {
                Navigator.of(context).pop();
                widget.onNavigate?.call(AppNavigationPage.compare);
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
        title: const Text('Settings & Data'),
      ),
      body: content,
      bottomNavigationBar: isMobile
          ? AppMobileBottomNavigationBar(
              currentPage: AppNavigationPage.settings,
              onSelect: onSelectMobileNav,
            )
          : null,
    );
  }

  Widget _panel({required String title, required Widget child}) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
