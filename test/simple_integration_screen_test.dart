import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:flutter_example/examples/simple_integration_screen.dart';

void main() {
  group('SimpleIntegrationScreen (User Story 1 - View stories feed)', () {
    testWidgets('renders app bar title, back control, and one feed widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Builder(
                  builder: (context) => Center(
                    child: ElevatedButton(
                      child: const Text('open'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SimpleIntegrationScreen(
                            configured: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();

      expect(find.text('Simple Integration'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.byType(FeedStoriesWidget), findsOneWidget);
    });
  });

  group('SimpleIntegrationScreen (SDK not configured)', () {
    testWidgets('shows a warning instead of the feed when the API key is unset',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SimpleIntegrationScreen(configured: false),
        ),
      );
      await tester.pump();

      expect(find.text('Simple Integration'), findsOneWidget);
      expect(find.text('InAppStory SDK is not configured'), findsOneWidget);
      expect(find.byType(FeedStoriesWidget), findsNothing);
    });
  });
}
