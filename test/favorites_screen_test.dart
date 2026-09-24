import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:flutter_example/examples/favorites_screen.dart';

void main() {
  group('FavoritesScreen (US1 - enable favorites + feed)', () {
    testWidgets('configured: renders the default feed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: FavoritesScreen(configured: true)),
      );
      await tester.pump();

      expect(find.text('Favorites'), findsOneWidget);

      final feedFinder = find.byType(FeedStoriesWidget);
      expect(feedFinder, findsOneWidget);

      final feed = tester.widget<FeedStoriesWidget>(feedFinder);
      expect(feed.feed, 'default');
      // favoritesBuilder unset → SDK default grid. No custom builder.
      expect(feed.favoritesBuilder, isNull);
      // Enabling favorites in initState must not crash the screen even with no
      // live SDK platform channel (the call is guarded).
      expect(tester.takeException(), isNull);
    });

    testWidgets('not configured: shows warning and no feed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: FavoritesScreen(configured: false)),
      );
      await tester.pump();

      expect(find.text('InAppStory SDK is not configured'), findsOneWidget);
      expect(find.byType(FeedStoriesWidget), findsNothing);
    });

    testWidgets('disposing the screen does not throw (global-state reset)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: FavoritesScreen(configured: true)),
      );
      await tester.pump();

      // Navigate away → FavoritesScreen.dispose() runs resetInAppStory().
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
