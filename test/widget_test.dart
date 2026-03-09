import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:toramonline/app_shell/app_shell_page.dart';

void main() {
  testWidgets('AppShell uses mobile bottom navigation to switch pages', (
    WidgetTester tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
    );
    tester.binding.platformDispatcher.textScaleFactorTestValue = 1.0;
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(MaterialApp(home: AppShellScreen()));
    await tester.pump();

    expect(find.text('Toram Item Build Simulation'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);

    await tester.tap(find.text('Critical'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Critical Simulator'), findsWidgets);

    await tester.tap(find.text('Build'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Toram Item Build Simulation'), findsOneWidget);
  });

  testWidgets('AppShell menu shows navigation entries', (
    WidgetTester tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
    );
    tester.binding.platformDispatcher.textScaleFactorTestValue = 1.0;
    await tester.binding.setSurfaceSize(const Size(1280, 800));

    await tester.pumpWidget(MaterialApp(home: AppShellScreen()));
    await tester.pump();

    expect(find.byIcon(Icons.menu), findsOneWidget);
    if (find.byType(BottomNavigationBar).evaluate().isNotEmpty) {
      await tester.tap(find.text('Critical'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Critical Simulator'), findsWidgets);
    }

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Build Tools'), findsOneWidget);
    expect(find.text('Build Simulator'), findsOneWidget);
    expect(find.text('Equipment Library'), findsOneWidget);
    expect(find.text('Critical Simulator'), findsWidgets);
    expect(find.text('Saved Builds'), findsOneWidget);
    expect(find.text('Compare Builds'), findsOneWidget);
  });
}
