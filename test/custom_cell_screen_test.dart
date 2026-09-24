import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:flutter_example/examples/custom_cell_screen.dart';

/// Minimal in-memory [Story] for pumping [customStoryCell] without the SDK.
class _FakeStory implements Story {
  _FakeStory({this.opened = false});

  @override
  final bool opened;
  bool tapped = false;

  @override
  int get id => 1;

  @override
  String get title => 'Fake title';

  @override
  double get aspectRatio => 1.0;

  @override
  File? get imageFile => null;

  @override
  File? get videoFile => null;

  @override
  bool get hasAudio => false;

  @override
  Color get backgroundColor => const Color(0xFF222222);

  @override
  Color get titleColor => const Color(0xFFFFFFFF);

  @override
  Stream<void> get updates => const Stream.empty();

  @override
  void showReader() => tapped = true;
}

void main() {
  group('CustomCellScreen (US1 - custom cells)', () {
    testWidgets('configured: renders feed with a custom storyBuilder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: CustomCellScreen(configured: true)),
      );
      await tester.pump();

      expect(find.text('Custom cell'), findsOneWidget);
      final feedFinder = find.byType(FeedStoriesWidget);
      expect(feedFinder, findsOneWidget);

      final feed = tester.widget<FeedStoriesWidget>(feedFinder);
      expect(feed.feed, 'default');
      // A custom cell — not the default builder — must be supplied.
      expect(feed.storyBuilder, isNotNull);
      // The screen builds with an unresolved live feed without crashing.
      expect(tester.takeException(), isNull);
    });

    testWidgets('not configured: shows warning and no feed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: CustomCellScreen(configured: false)),
      );
      await tester.pump();

      expect(find.text('InAppStory SDK is not configured'), findsOneWidget);
      expect(find.byType(FeedStoriesWidget), findsNothing);
    });

    testWidgets('custom cell shows title and opens reader on tap', (
      WidgetTester tester,
    ) async {
      final story = _FakeStory(opened: true);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: customStoryCell(story, const FeedStoryDecorator()),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Fake title'), findsOneWidget);

      await tester.tap(find.byType(GestureDetector).first);
      expect(story.tapped, isTrue);
    });
  });

  group('CustomCellScreen (US2 - unread indicator)', () {
    Widget cellFor(bool opened) => MaterialApp(
      home: Scaffold(
        body: customStoryCell(
          _FakeStory(opened: opened),
          const FeedStoryDecorator(),
        ),
      ),
    );

    Iterable<Container> gradientRings(WidgetTester tester) => tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (c) =>
              c.decoration is BoxDecoration &&
              (c.decoration as BoxDecoration).gradient != null,
        );

    testWidgets('unopened story shows the gradient unread ring', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(cellFor(false));
      await tester.pump();

      expect(gradientRings(tester), isNotEmpty);
    });

    testWidgets('opened story shows a flat ring (no gradient)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(cellFor(true));
      await tester.pump();

      expect(gradientRings(tester), isEmpty);
    });
  });
}
