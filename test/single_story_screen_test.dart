import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:flutter_example/examples/single_story_screen.dart';

void main() {
  group('SingleStoryScreen', () {
    testWidgets('configured: renders the "Show story" button and no feed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SingleStoryScreen(configured: true)),
      );
      await tester.pump();

      expect(find.text('Single story'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Show story'), findsOneWidget);
      // This example intentionally shows no stories feed.
      expect(find.byType(FeedStoriesWidget), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('not configured: shows warning, no button and no feed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SingleStoryScreen(configured: false)),
      );
      await tester.pump();

      expect(find.text('InAppStory SDK is not configured'), findsOneWidget);
      expect(find.text('Show story'), findsNothing);
      expect(find.byType(FeedStoriesWidget), findsNothing);
    });

    testWidgets('tapping the button applies appearance without throwing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SingleStoryScreen(configured: true)),
      );
      await tester.pump();

      await tester.tap(find.text('Show story'));
      await tester.pump();

      // The guarded per-show panel override + show call must not crash the
      // screen when there is no live platform channel.
      expect(tester.takeException(), isNull);
    });

    testWidgets('disposing the screen restores state without throwing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SingleStoryScreen(configured: true)),
      );
      await tester.pump();

      // Replace the screen to trigger dispose (baseline restore safety net).
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
