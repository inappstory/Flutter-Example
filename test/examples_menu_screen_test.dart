import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example/menu/example_entry.dart';
import 'package:flutter_example/menu/examples_menu_screen.dart';
import 'package:flutter_example/examples/placeholder_example_screen.dart';

void main() {
  group('ExamplesMenuScreen (User Story 1 - Browse and open an example)', () {
    testWidgets('renders all entries with titles and chevron icons', (
      WidgetTester tester,
    ) async {
      final testEntries = [
        ExampleEntry(
          title: 'Test Example 1',
          builder: (context) =>
              const PlaceholderExampleScreen(title: 'Test Example 1'),
        ),
        ExampleEntry(
          title: 'Test Example 2',
          builder: (context) =>
              const PlaceholderExampleScreen(title: 'Test Example 2'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: ExamplesMenuScreen(entries: testEntries, onReset: () async {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('InAppStory Examples'), findsOneWidget);
      expect(find.text('Test Example 1'), findsOneWidget);
      expect(find.text('Test Example 2'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
    });

    testWidgets('navigates to example screen on tap and returns on back', (
      WidgetTester tester,
    ) async {
      final testEntries = [
        ExampleEntry(
          title: 'Custom Destination Screen',
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Detail Screen')),
            body: const Center(child: Text('Custom Destination Content')),
          ),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: ExamplesMenuScreen(entries: testEntries, onReset: () async {}),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the row
      await tester.tap(find.text('Custom Destination Screen'));
      await tester.pumpAndSettle();

      // Verify destination screen is shown
      expect(find.text('Custom Destination Content'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify returned to start menu
      expect(find.text('Custom Destination Screen'), findsOneWidget);
    });

    testWidgets('renders default kExamples list when no entries provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: ExamplesMenuScreen(onReset: () async {})),
      );
      await tester.pumpAndSettle();

      const titles = [
        'Simple integration (Stories feed)',
        'Cell customization',
        'Custom cell',
        'Single story',
        'Onboarding',
        'In-App Messaging (IAM)',
        'Custom GoodsWidget',
        'Checkout',
        'Favorites',
        'Banners',
        'Multi-feed',
        'User switching',
        'Tags & Placeholders',
        'Reader customization',
      ];
      expect(kExamples.map((entry) => entry.title), orderedEquals(titles));
      expect(find.text('Checkout'), findsOneWidget);
    });
  });

  group('ExamplesMenuScreen (User Story 2 - Reset isolation)', () {
    testWidgets('invokes reset on initial load and on return from route', (
      WidgetTester tester,
    ) async {
      int resetCount = 0;

      final testEntries = [
        ExampleEntry(
          title: 'Test Entry',
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Detail Screen')),
            body: const Text('Detail Content'),
          ),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: ExamplesMenuScreen(
            entries: testEntries,
            onReset: () async {
              resetCount++;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial reset on show
      expect(resetCount, equals(1));

      // Push detail screen
      await tester.tap(find.text('Test Entry'));
      await tester.pumpAndSettle();

      // Return back to menu
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Reset called again on return
      expect(resetCount, equals(2));
    });

    testWidgets('renders normally even if reset throws an error', (
      WidgetTester tester,
    ) async {
      final testEntries = [
        ExampleEntry(
          title: 'Resilient Entry',
          builder: (context) =>
              const PlaceholderExampleScreen(title: 'Resilient Entry'),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: ExamplesMenuScreen(
            entries: testEntries,
            onReset: () async {
              throw Exception('Reset failed');
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Menu is still rendered and interactive
      expect(find.text('Resilient Entry'), findsOneWidget);
    });
  });
}
