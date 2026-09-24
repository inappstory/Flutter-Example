import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_example/examples/banners_screen.dart';

void main() {
  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  group('BannersScreen', () {
    testWidgets(
      'renders warning banner when SDK is unconfigured (configured: false)',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: BannersScreen(configured: false)),
        );
        await tester.pump();

        expect(find.text('InAppStory SDK is not configured'), findsOneWidget);
        expect(find.byKey(const Key('banner-place-widget')), findsNothing);
        expect(find.byKey(const Key('dot-navigation-indicator')), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'US1: renders banner place, dot navigation indicator, controls, and empty event log when configured',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: BannersScreen(configured: true)),
        );
        await tester.pump();

        // Page title
        expect(find.text('Banners'), findsOneWidget);
        expect(find.text('InAppStory Banners'), findsNothing);

        // BannerPlace & DotNavigationIndicator
        expect(find.byKey(const Key('banner-place-widget')), findsOneWidget);
        expect(
          find.byKey(const Key('dot-navigation-indicator')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('dot-indicator-0')), findsOneWidget);
        expect(find.byKey(const Key('dot-indicator-1')), findsOneWidget);
        expect(find.byKey(const Key('dot-indicator-2')), findsOneWidget);

        // Controls
        expect(find.byKey(const Key('prev-banner-button')), findsOneWidget);
        expect(
          find.byKey(const Key('autoscroll-toggle-button')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('next-banner-button')), findsOneWidget);
        expect(find.byKey(const Key('reload-banners-button')), findsOneWidget);
        expect(find.byKey(const Key('preload-banners-button')), findsOneWidget);

        // Settings
        expect(find.byKey(const Key('banner-place-id-input')), findsOneWidget);

        // Event Log
        expect(find.text('Banner Event Log'), findsOneWidget);
        expect(find.text('No banner events logged yet'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'US2: programmatic navigation buttons (Next, Prev), dot indicator tap, and autoscroll toggle',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: BannersScreen(configured: true)),
        );
        await tester.pump();

        // Tap Next
        final nextBtn = find.byKey(const Key('next-banner-button'));
        await tester.ensureVisible(nextBtn);
        await tester.tap(nextBtn);
        await tester.pump();

        expect(find.text('Next banner requested'), findsOneWidget);
        expect(find.text('CONTROL'), findsWidgets);

        // Tap Prev
        final prevBtn = find.byKey(const Key('prev-banner-button'));
        await tester.ensureVisible(prevBtn);
        await tester.tap(prevBtn);
        await tester.pump();

        expect(find.text('Previous banner requested'), findsOneWidget);

        // Tap Dot Indicator at index 2
        final dot2 = find.byKey(const Key('dot-indicator-2'));
        await tester.ensureVisible(dot2);
        await tester.tap(dot2);
        await tester.pump();

        expect(find.text('Jump to banner index 2 requested'), findsOneWidget);

        // Tap Autoscroll Pause / Resume
        final autoscrollBtn = find.byKey(const Key('autoscroll-toggle-button'));
        expect(find.text('Pause Autoscroll'), findsOneWidget);

        await tester.ensureVisible(autoscrollBtn);
        await tester.tap(autoscrollBtn);
        await tester.pump();

        expect(find.text('Resume'), findsOneWidget);
        expect(find.text('Pause autoscroll requested'), findsOneWidget);

        // Tap again to Resume
        await tester.tap(autoscrollBtn);
        await tester.pump();

        expect(find.text('Pause Autoscroll'), findsOneWidget);
        expect(find.text('Resume autoscroll requested'), findsOneWidget);

        // Tap Reload & Preload
        final reloadBtn = find.byKey(const Key('reload-banners-button'));
        await tester.ensureVisible(reloadBtn);
        await tester.tap(reloadBtn);
        await tester.pump();
        expect(
          find.text('Reload requested for place "app-head"'),
          findsOneWidget,
        );

        final preloadBtn = find.byKey(const Key('preload-banners-button'));
        await tester.ensureVisible(preloadBtn);
        await tester.tap(preloadBtn);
        await tester.pump();
        expect(
          find.text('Preload requested for place "app-head"'),
          findsOneWidget,
        );

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'US3: handles BannerPlace callbacks (load, scroll, action) and clear log',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: BannersScreen(configured: true)),
        );
        await tester.pump();

        final state =
            tester.state(find.byType(BannersScreen)) as BannersScreenState;

        // Simulate onBannerPlaceLoaded
        state.handleBannerPlaceLoaded(4, 180);
        await tester.pump();

        expect(
          find.text('Banner place loaded (4 items, height: 180px)'),
          findsOneWidget,
        );
        expect(find.text('LOAD'), findsOneWidget);
        expect(find.byKey(const Key('dot-indicator-3')), findsOneWidget);

        // Simulate onBannerScroll
        state.handleBannerScroll(1);
        await tester.pump();

        expect(find.text('Scrolled to banner index 1'), findsOneWidget);
        expect(find.text('SCROLL'), findsOneWidget);

        // Simulate onActionWith
        state.handleActionWith(
          BannerData(
            id: 'banner_101',
            bannerPlace: 'banners',
            payload: 'promo_code',
          ),
          'cta_click',
          {'sku': 'item_55'},
        );
        await tester.pump();

        expect(find.text('Action in banner: cta_click'), findsOneWidget);
        expect(find.text('Banner ID: banner_101'), findsOneWidget);
        expect(find.text('ACTION'), findsOneWidget);

        // Clear Log
        final clearBtn = find.byKey(const Key('clear-banner-log-button'));
        await tester.ensureVisible(clearBtn);
        await tester.tap(clearBtn);
        await tester.pump();

        expect(find.text('No banner events logged yet'), findsOneWidget);
        expect(find.text('ACTION'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Disposes cleanly without throwing exceptions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BannersScreen(configured: true)),
      );
      await tester.pump();

      // Navigate away to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Next Screen'))),
      );
      await tester.pump();

      expect(find.text('Next Screen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
