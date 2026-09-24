import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:flutter_example/examples/user_change_screen.dart';

void main() {
  group('UserChangeScreen', () {
    testWidgets('configured: renders the feed and the switch button (US1)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: UserChangeScreen(configured: true)),
      );
      await tester.pump();

      expect(find.text('User Change'), findsOneWidget);

      final feedFinder = find.byType(FeedStoriesWidget);
      expect(feedFinder, findsOneWidget);
      expect(tester.widget<FeedStoriesWidget>(feedFinder).feed, 'default');

      expect(find.text('Switch user'), findsOneWidget);
      // Starts on the anonymous user.
      expect(find.text('Current user: anonymous'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('not configured: shows warning and no feed (SC-005)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: UserChangeScreen(configured: false)),
      );
      await tester.pump();

      expect(find.text('InAppStory SDK is not configured'), findsOneWidget);
      expect(find.byType(FeedStoriesWidget), findsNothing);
      expect(find.text('Switch user'), findsNothing);
    });

    testWidgets('tapping the switch button repeatedly never throws (US2/US3)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: UserChangeScreen(configured: true)),
      );
      await tester.pump();

      final button = find.text('Switch user');
      // Toggle a few times: switch calls are guarded, so no live SDK is fine.
      for (var i = 0; i < 3; i++) {
        await tester.tap(button);
        await tester.pump();
        expect(button, findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('disposing the screen does not throw (logout to anonymous)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: UserChangeScreen(configured: true)),
      );
      await tester.pump();

      // Navigate away → dispose() logs back out to the anonymous baseline.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
