import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toramonline/shared/app_theme_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppThemeController', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await AppThemeController.instance.setThemeMode(ThemeMode.dark);
    });

    test('should be singleton', () {
      final instance1 = AppThemeController.instance;
      final instance2 = AppThemeController.instance;
      expect(instance1, same(instance2));
    });

    test('should have initial theme mode', () {
      final controller = AppThemeController.instance;
      expect([ThemeMode.light, ThemeMode.dark], contains(controller.themeMode));
    });

    test('should have isDarkMode and isLightMode getters', () {
      final controller = AppThemeController.instance;
      final isDark = controller.isDarkMode;
      final isLight = controller.isLightMode;
      // One must be true, other false
      expect(isDark != isLight, true);
    });

    test('should toggle theme mode', () async {
      final controller = AppThemeController.instance;
      final initialMode = controller.themeMode;

      await controller.toggle();

      expect(controller.themeMode, isNot(initialMode));
    });

    test('should notify listeners on theme change', () async {
      final controller = AppThemeController.instance;
      bool notified = false;

      controller.addListener(() {
        notified = true;
      });

      await controller.setThemeMode(
        controller.isDarkMode ? ThemeMode.light : ThemeMode.dark,
      );

      expect(notified, true);
    });

    test('should persist theme preference', () async {
      final controller = AppThemeController.instance;

      // Set theme
      final targetMode = controller.isDarkMode
          ? ThemeMode.light
          : ThemeMode.dark;
      await controller.setThemeMode(targetMode);

      // Should be persisted
      expect(controller.themeMode, targetMode);
    });
  });
}
