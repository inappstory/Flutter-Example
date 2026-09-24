import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:flutter_example/examples/cell_customization_screen.dart';

FeedStoriesWidget _feed(WidgetTester tester) =>
    tester.widget<FeedStoriesWidget>(find.byType(FeedStoriesWidget));

void main() {
  group('CellCustomizationScreen (User Story 1 - customized cells)', () {
    testWidgets('renders a feed with a non-default customized decorator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CellCustomizationScreen(configured: true),
        ),
      );
      await tester.pump();

      expect(find.text('Cell customization'), findsOneWidget);
      expect(find.byType(FeedStoriesWidget), findsOneWidget);

      final feed = _feed(tester);
      expect(feed.feed, 'default');

      final d = feed.decorator!;
      // Customized vs. FeedStoryDecorator defaults (radius 8, no border color
      // change, fontSize 12, zero feedPadding).
      expect(d.borderRadius, const BorderRadius.all(Radius.circular(20)));
      expect(d.showBorder, isTrue);
      expect(d.borderColor, Colors.deepPurple);
      expect(d.borderWidth, 3);
      expect(d.textStyle?.color, Colors.white);
      expect(d.textStyle?.fontSize, 16);
      expect(d.feedPadding, isNot(EdgeInsets.zero));
      expect(d.storyPadding, 16);
    });

    testWidgets('shows a warning and no feed when SDK is not configured',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CellCustomizationScreen(configured: false),
        ),
      );
      await tester.pump();

      expect(find.text('InAppStory SDK is not configured'), findsOneWidget);
      expect(find.byType(FeedStoriesWidget), findsNothing);
    });
  });

  group('CellCustomizationScreen (User Story 2 - title visibility toggle)', () {
    testWidgets('toggling title collapses the title but keeps other styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CellCustomizationScreen(configured: true),
        ),
      );
      await tester.pump();

      final titledWidget = _feed(tester);
      final titled = titledWidget.decorator!;
      expect(titled.textStyle?.fontSize, 16); // title visible

      await tester.tap(find.byType(Switch));
      await tester.pump();

      final hiddenWidget = _feed(tester);
      final hidden = hiddenWidget.decorator!;
      // The key MUST change so FeedStoriesWidget rebuilds and picks up the new
      // decorator — it ignores in-place decorator changes.
      expect(hiddenWidget.key, isNot(titledWidget.key));
      // Title collapsed...
      expect(hidden.textStyle?.fontSize, 0);
      expect(hidden.textStyle?.color, Colors.transparent);
      // ...while the rest of the customization is unchanged.
      expect(hidden.borderRadius, titled.borderRadius);
      expect(hidden.borderColor, titled.borderColor);
      expect(hidden.borderWidth, titled.borderWidth);
      expect(hidden.storyPadding, titled.storyPadding);
      expect(hidden.feedPadding, titled.feedPadding);
    });
  });
}
