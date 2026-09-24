import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:flutter_example/examples/multi_feed_screen.dart';

void main() {
  group('MultiFeedScreen', () {
    testWidgets(
      'renders warning banner when SDK is unconfigured (configured: false)',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: MultiFeedScreen(configured: false)),
        );
        await tester.pump();

        expect(find.text('InAppStory SDK is not configured'), findsOneWidget);
        expect(find.byType(FeedStoriesWidget), findsNothing);
        expect(
          find.byKey(const Key('refresh-default-feed-button')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('refresh-custom-feed-button')),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'renders both Default Feed and Custom Feed widgets when configured',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: MultiFeedScreen(configured: true)),
        );
        await tester.pump();

        expect(find.byType(FeedStoriesWidget), findsNWidgets(2));
        expect(find.byKey(const Key('default-feed-widget')), findsOneWidget);
        expect(find.byKey(const Key('custom-feed-widget')), findsOneWidget);

        expect(find.text('Default Feed'), findsOneWidget);
        expect(find.text('slug: default'), findsOneWidget);
        expect(find.text('Custom Feed'), findsOneWidget);
        expect(find.text('slug: custom-feed'), findsOneWidget);

        expect(
          find.byKey(const Key('refresh-default-feed-button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('refresh-custom-feed-button')),
          findsOneWidget,
        );
        expect(find.text('Multi-Feed Event Log'), findsNothing);
        expect(find.byKey(const Key('empty-log-placeholder')), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('tapping refresh on Default Feed does not crash', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: MultiFeedScreen(configured: true)),
      );
      await tester.pump();

      final refreshDefaultBtn = find.byKey(
        const Key('refresh-default-feed-button'),
      );
      await tester.tap(refreshDefaultBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('default-feed-widget')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping refresh on Custom Feed does not crash', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: MultiFeedScreen(configured: true)),
      );
      await tester.pump();

      final refreshCustomBtn = find.byKey(
        const Key('refresh-custom-feed-button'),
      );
      await tester.ensureVisible(refreshCustomBtn);
      await tester.tap(refreshCustomBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('custom-feed-widget')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Disposes cleanly without throwing exceptions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MultiFeedScreen(configured: true)),
      );
      await tester.pump();

      // Replace widget to trigger dispose()
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Next Screen'))),
      );
      await tester.pump();

      expect(find.text('Next Screen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
