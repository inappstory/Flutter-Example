import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example/examples/onboarding_screen.dart';

void main() {
  group('OnboardingScreen (US1 - show onboarding on demand)', () {
    testWidgets('configured: renders the "Show onboarding" button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OnboardingScreen(configured: true)),
      );
      await tester.pump();

      expect(find.text('Onboarding'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Show onboarding'), findsOneWidget);
      // Applying panel settings in initState must not crash with no live SDK.
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping "Show onboarding" does not throw (guarded call)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OnboardingScreen(configured: true)),
      );
      await tester.pump();

      await tester.tap(find.text('Show onboarding'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('not configured: shows warning and no button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OnboardingScreen(configured: false)),
      );
      await tester.pump();

      expect(find.text('InAppStory SDK is not configured'), findsOneWidget);
      expect(find.text('Show onboarding'), findsNothing);
    });
  });

  group('OnboardingScreen (US3 - panel settings reset on exit)', () {
    testWidgets('disposing the screen does not throw (global-state reset)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OnboardingScreen(configured: true)),
      );
      await tester.pump();

      // Navigate away → OnboardingScreen.dispose() runs resetInAppStory().
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
