import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:toramonline/app_shell/app_shell_page.dart';

Future<void> _openShellDrawerAndWaitFor(
  WidgetTester tester, {
  required String expectedText,
  Duration timeout = const Duration(seconds: 2),
}) async {
  final ScaffoldState scaffoldState = tester.state<ScaffoldState>(
    find.byType(Scaffold),
  );
  scaffoldState.openDrawer();

  final DateTime deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.text(expectedText).evaluate().isNotEmpty) {
      return;
    }
  }
}

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

    // Desktop layout: just verify drawer contents after opening.
    await _openShellDrawerAndWaitFor(tester, expectedText: 'Build Tools');

    expect(find.text('Build Tools'), findsOneWidget);

    // Open again (drawer may auto-close, but opening should still work).
    await _openShellDrawerAndWaitFor(tester, expectedText: 'Build Tools');

    expect(find.text('Build Tools'), findsOneWidget);
  });
}
