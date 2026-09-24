import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:flutter_example/examples/tags_placeholders_screen.dart';

void main() {
  group('TagsPlaceholdersScreen', () {
    testWidgets('shows SDK feed and compact inputs when configured', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: TagsPlaceholdersScreen(configured: true)),
      );
      await tester.pump();

      expect(find.byType(FeedStoriesWidget), findsOneWidget);
      expect(find.byKey(const Key('tags-field')), findsOneWidget);
      expect(find.byKey(const Key('placeholders-field')), findsOneWidget);
      expect(find.byKey(const Key('apply-refresh-button')), findsOneWidget);
      expect(find.byKey(const Key('clear-all-button')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows a warning when SDK is not configured', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TagsPlaceholdersScreen(configured: false)),
      );
      await tester.pump();

      expect(find.text('InAppStory SDK is not configured'), findsOneWidget);
      expect(find.byType(FeedStoriesWidget), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('applies tags and placeholders without throwing', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: TagsPlaceholdersScreen(configured: true)),
      );
      await tester.pump();

      await tester.enterText(find.byKey(const Key('tags-field')), 'vip, promo');
      await tester.enterText(
        find.byKey(const Key('placeholders-field')),
        'city=London, avatar=https://example.com/avatar.png',
      );
      final applyButton = find.byKey(const Key('apply-refresh-button'));
      await tester.ensureVisible(applyButton);
      await tester.tap(applyButton);
      await tester.pump();

      expect(find.byType(FeedStoriesWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('clears input and resets SDK state on dispose', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TagsPlaceholdersScreen(configured: true)),
      );
      await tester.pump();

      final clearButton = find.byKey(const Key('clear-all-button'));
      await tester.ensureVisible(clearButton);
      await tester.tap(clearButton);
      await tester.pump();

      expect(
        tester
            .widget<TextField>(find.byKey(const Key('tags-field')))
            .controller!
            .text,
        isEmpty,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('placeholders-field')))
            .controller!
            .text,
        isEmpty,
      );

      await tester.pumpWidget(const MaterialApp(home: Text('Next Screen')));
      expect(find.text('Next Screen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
