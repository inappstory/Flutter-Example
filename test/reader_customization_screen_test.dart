import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:flutter_example/examples/reader_customization_screen.dart';

void main() {
  group('ReaderCustomizationScreen (US1 - customized reader chrome)', () {
    testWidgets('configured: renders the default feed without throwing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ReaderCustomizationScreen(configured: true)),
      );
      await tester.pump();

      expect(find.text('Reader customization'), findsOneWidget);

      final feedFinder = find.byType(FeedStoriesWidget);
      expect(feedFinder, findsOneWidget);
      expect(tester.widget<FeedStoriesWidget>(feedFinder).feed, 'default');

      // The guarded appearance calls (close position / scroll / presentation +
      // panel toggles) must not crash the screen with no live platform channel.
      expect(tester.takeException(), isNull);
    });

    testWidgets('not configured: shows warning and no feed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ReaderCustomizationScreen(configured: false)),
      );
      await tester.pump();

      expect(find.text('InAppStory SDK is not configured'), findsOneWidget);
      expect(find.byType(FeedStoriesWidget), findsNothing);
    });

    testWidgets('disposing the screen resets global state without throwing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ReaderCustomizationScreen(configured: true)),
      );
      await tester.pump();

      // Navigate away → dispose() runs resetInAppStory().
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('ReaderCustomizationScreen (US2 - bottom panel)', () {
    testWidgets('enabling like/favorite/share keeps the screen stable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ReaderCustomizationScreen(configured: true)),
      );
      await tester.pump();

      // Panel toggles are applied in initState; the feed still renders and no
      // exception escapes when there is no live platform channel.
      expect(find.byType(FeedStoriesWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ReaderCustomizationScreen (US3 - degraded swipe/refresh)', () {
    testWidgets('builds and disposes without swipe/refresh appearance calls',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ReaderCustomizationScreen(configured: true)),
      );
      await tester.pump();
      expect(find.byType(FeedStoriesWidget), findsOneWidget);

      // No public swipe-to-close / refresh-icon API is exercised; the screen
      // stays stable through build and teardown (graceful degradation).
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
