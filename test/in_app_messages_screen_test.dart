import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:flutter_example/examples/in_app_messages_screen.dart';

void main() {
  group('InAppMessagesScreen', () {
    testWidgets(
      'renders warning banner when SDK is unconfigured (configured: false)',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: InAppMessagesScreen(configured: false),
          ),
        );
        await tester.pump();

        expect(find.text('InAppStory SDK is not configured'), findsOneWidget);
        expect(find.byKey(const Key('iam-message-id-input')), findsNothing);
        expect(find.byKey(const Key('show-iam-by-id-button')), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'US1: renders input cards, trigger buttons, and empty event log when configured',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: InAppMessagesScreen(configured: true),
          ),
        );
        await tester.pump();

        // Title and Info
        expect(find.text('In-App Messaging'), findsOneWidget);
        expect(find.text('In-App Messages (IAM)'), findsOneWidget);

        // Inputs
        expect(find.byKey(const Key('iam-message-id-input')), findsOneWidget);
        expect(find.byKey(const Key('iam-event-name-input')), findsOneWidget);

        // Buttons
        expect(find.byKey(const Key('show-iam-by-id-button')), findsOneWidget);
        expect(find.byKey(const Key('show-iam-by-event-button')), findsOneWidget);

        // Event Log
        expect(find.text('IAM Event Log'), findsOneWidget);
        expect(find.text('No IAM events logged yet'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'US1: tapping Show by ID logs action request',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: InAppMessagesScreen(configured: true),
          ),
        );
        await tester.pump();

        final showByIdBtn = find.byKey(const Key('show-iam-by-id-button'));
        await tester.tap(showByIdBtn);
        await tester.pump();

        expect(find.textContaining('Show requested by ID'), findsOneWidget);
        expect(find.text('ACTION'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'US1: tapping Show by Event logs action request',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: InAppMessagesScreen(configured: true),
          ),
        );
        await tester.pump();

        final showByEventBtn = find.byKey(const Key('show-iam-by-event-button'));
        await tester.tap(showByEventBtn);
        await tester.pump();

        expect(find.textContaining('Show requested by Event'), findsOneWidget);
        expect(find.text('ACTION'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'US2: toggling Only Preloaded switch and clicking preload buttons',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: InAppMessagesScreen(configured: true),
          ),
        );
        await tester.pump();

        final switchFinder = find.byKey(const Key('only-preloaded-switch'));
        expect(switchFinder, findsOneWidget);

        // Ensure visible in scroll view before tapping
        await tester.ensureVisible(switchFinder);
        await tester.tap(switchFinder);
        await tester.pump();

        final switchWidget = tester.widget<SwitchListTile>(switchFinder);
        expect(switchWidget.value, isTrue);

        // Tap Preload All
        final preloadAllBtn = find.byKey(const Key('preload-all-button'));
        await tester.ensureVisible(preloadAllBtn);
        await tester.tap(preloadAllBtn);
        await tester.pump();

        expect(find.textContaining('Preload all messages requested'), findsOneWidget);

        // Tap Preload Current ID
        final preloadByIdBtn = find.byKey(const Key('preload-by-id-button'));
        await tester.ensureVisible(preloadByIdBtn);
        await tester.tap(preloadByIdBtn);
        await tester.pump();

        expect(find.textContaining('Preload by ID requested'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'US3: handles IASInAppMessageCallback callbacks and clear log action',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: InAppMessagesScreen(configured: true),
          ),
        );
        await tester.pump();

        final state = tester.state(find.byType(InAppMessagesScreen))
            as dynamic;

        // Simulate onShowInAppMessage callback
        state.onShowInAppMessage(
          InAppMessageDataDto(id: 42, title: 'Welcome IAM', event: 'welcome'),
        );
        await tester.pump();

        expect(find.text('SHOW'), findsOneWidget);
        expect(find.text('Welcome IAM'), findsOneWidget);
        expect(find.text('Message ID: 42'), findsOneWidget);

        // Simulate onInAppMessageWidgetEvent callback
        state.onInAppMessageWidgetEvent(
          InAppMessageDataDto(id: 42, title: 'Welcome IAM', event: 'welcome'),
          'cta_button',
          {'clicked': true},
        );
        await tester.pump();

        expect(find.text('WIDGET'), findsOneWidget);
        expect(find.text('Event: cta_button'), findsOneWidget);

        // Simulate onCloseInAppMessage callback
        state.onCloseInAppMessage(
          InAppMessageDataDto(id: 42, title: 'Welcome IAM', event: 'welcome'),
        );
        await tester.pump();

        expect(find.text('CLOSE'), findsOneWidget);

        // Clear Log
        final clearBtn = find.byKey(const Key('clear-iam-log-button'));
        await tester.ensureVisible(clearBtn);
        await tester.tap(clearBtn);
        await tester.pump();

        expect(find.text('No IAM events logged yet'), findsOneWidget);
        expect(find.text('SHOW'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Disposes cleanly without throwing exceptions',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: InAppMessagesScreen(configured: true),
          ),
        );
        await tester.pump();

        // Navigate away to trigger dispose
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: Text('Next Screen')),
          ),
        );
        await tester.pump();

        expect(find.text('Next Screen'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
