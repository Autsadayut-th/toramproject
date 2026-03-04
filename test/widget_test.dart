import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:toramonline/frontend/app_shell/app_shell_page.dart';

void main() {
  testWidgets('MyApp uses mobile bottom navigation to switch pages', (
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
    expect(find.byIcon(Icons.menu), findsNothing);

    await tester.tap(find.text('Skill'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Skill Menu'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Settings & Data'), findsOneWidget);

    await tester.tap(find.text('Build'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Toram Item Build Simulation'), findsOneWidget);
  });

  testWidgets('MyApp shows desktop drawer entry for equipment library', (
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

    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.byIcon(Icons.menu), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Build Tools'), findsOneWidget);
    expect(find.text('Equipment Library'), findsOneWidget);
    expect(find.text('Saved Builds'), findsOneWidget);
    expect(find.text('Compare Builds'), findsOneWidget);
    expect(find.text('Settings & Data'), findsOneWidget);
  });
}
