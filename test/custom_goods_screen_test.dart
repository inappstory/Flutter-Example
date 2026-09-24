import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:flutter_example/examples/custom_goods_screen.dart';

void main() {
  group('CustomGoodsScreen', () {
    testWidgets(
      'renders warning banner when SDK is unconfigured (configured: false)',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: CustomGoodsScreen(configured: false),
          ),
        );
        await tester.pump();

        expect(find.text('InAppStory SDK is not configured'), findsOneWidget);
        expect(find.byType(FeedStoriesWidget), findsNothing);
        expect(find.byKey(const Key('preview-overlay-button')), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'renders FeedStoriesWidget, preset chips, preview button, and log when configured',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: CustomGoodsScreen(configured: true),
          ),
        );
        await tester.pump();

        expect(find.byType(FeedStoriesWidget), findsOneWidget);
        expect(find.text('Full UI Goods Override'), findsOneWidget);
        expect(find.text('Preview Custom Goods UI'), findsOneWidget);
        expect(find.byKey(const Key('preview-overlay-button')), findsOneWidget);
        expect(find.text('Goods Interaction Log'), findsOneWidget);
        expect(find.byKey(const Key('preset-chip-0')), findsOneWidget);
        expect(find.byKey(const Key('preset-chip-1')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'US1: previews custom goods overlay with product cards and handles empty state',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: CustomGoodsScreen(configured: true),
          ),
        );
        await tester.pump();

        final previewButton = find.byKey(const Key('preview-overlay-button'));
        await tester.ensureVisible(previewButton);
        await tester.pumpAndSettle();

        // 1. Tap preview button with default preset ("Sneakers & Hoodie")
        await tester.tap(previewButton);
        await tester.pumpAndSettle();

        // Verify CustomGoodsOverlaySheet is open with product cards
        expect(find.byType(CustomGoodsOverlaySheet), findsOneWidget);
        expect(find.text('Featured Products'), findsOneWidget);
        expect(find.text('Urban Runner Sneakers'), findsOneWidget);
        expect(find.text('Oversized Street Hoodie'), findsOneWidget);
        expect(find.text('25% OFF'), findsOneWidget);
        expect(find.text('\$120'), findsOneWidget);
        expect(find.text('\$160'), findsOneWidget);

        // Close sheet
        await tester.tap(find.byKey(const Key('close-overlay-button')));
        await tester.pumpAndSettle();
        expect(find.byType(CustomGoodsOverlaySheet), findsNothing);

        // 2. Select "Empty List" preset and preview
        final emptyChip = find.byKey(const Key('preset-chip-3'));
        await tester.ensureVisible(emptyChip);
        await tester.tap(emptyChip); // Empty List
        await tester.pumpAndSettle();

        await tester.ensureVisible(previewButton);
        await tester.tap(previewButton);
        await tester.pumpAndSettle();

        expect(find.byType(CustomGoodsOverlaySheet), findsOneWidget);
        expect(find.text('No products available for this story.'), findsOneWidget);
        expect(find.byKey(const Key('checkout-button')), findsNothing);

        // Close sheet
        await tester.tap(find.byKey(const Key('close-overlay-button')));
        await tester.pumpAndSettle();

        // 3. Select "Unknown SKU" preset and preview fallback card
        final unknownChip = find.byKey(const Key('preset-chip-2'));
        await tester.ensureVisible(unknownChip);
        await tester.tap(unknownChip); // Unknown SKU
        await tester.pumpAndSettle();

        await tester.ensureVisible(previewButton);
        await tester.tap(previewButton);
        await tester.pumpAndSettle();

        expect(find.text('Product sku_custom_99'), findsOneWidget);
        expect(find.text('CUSTOM'), findsOneWidget);

        await tester.tap(find.byKey(const Key('close-overlay-button')));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'US2: adds item to cart, logs event, and handles item selection callback',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: CustomGoodsScreen(configured: true),
          ),
        );
        await tester.pump();

        final previewButton = find.byKey(const Key('preview-overlay-button'));
        await tester.ensureVisible(previewButton);
        await tester.pumpAndSettle();

        // Open custom overlay
        await tester.tap(previewButton);
        await tester.pumpAndSettle();

        // Tap "Add" button on sneakers product card
        final addButton = find.byKey(const Key('add-to-cart-sku_sneakers_01'));
        expect(addButton, findsOneWidget);
        await tester.tap(addButton);
        await tester.pump();

        // Verify snackbar feedback
        expect(find.text('Added "Urban Runner Sneakers" to cart!'), findsOneWidget);

        // Close overlay
        await tester.tap(find.byKey(const Key('close-overlay-button')));
        await tester.pumpAndSettle();

        // Verify shopping cart badge in AppBar shows 1
        expect(find.text('1'), findsOneWidget);

        // Verify event log contains "Added to Cart" and exact log details
        expect(find.text('Added to Cart'), findsOneWidget);
        expect(
          find.text('Added "Urban Runner Sneakers" to cart (Total: 1).'),
          findsOneWidget,
        );

        // Clear log
        final clearLogButton = find.byKey(const Key('clear-log-button'));
        await tester.ensureVisible(clearLogButton);
        await tester.tap(clearLogButton);
        await tester.pump();
        expect(find.text('Added to Cart'), findsNothing);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'US3: handles checkout reader close action and safe disposal',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: CustomGoodsScreen(configured: true),
          ),
        );
        await tester.pump();

        final previewButton = find.byKey(const Key('preview-overlay-button'));
        await tester.ensureVisible(previewButton);
        await tester.pumpAndSettle();

        // Open custom overlay
        await tester.tap(previewButton);
        await tester.pumpAndSettle();

        // Tap "Proceed to Checkout"
        final checkoutButton = find.byKey(const Key('checkout-button'));
        expect(checkoutButton, findsOneWidget);
        await tester.tap(checkoutButton);
        await tester.pumpAndSettle();

        // Overlay should be closed and checkout snackbar shown
        expect(find.byType(CustomGoodsOverlaySheet), findsNothing);
        expect(
          find.text('Proceeding to checkout — story reader closed.'),
          findsOneWidget,
        );
        expect(find.text('Reader Closed'), findsOneWidget);

        // Unmount widget to verify dispose() runs without error
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();

        expect(tester.takeException(), isNull);
      },
    );

    test('MockGoodsCatalog resolves predefined and fallback SKUs correctly', () {
      final resolved = MockGoodsCatalog.resolveSkus([
        'sku_sneakers_01',
        'unknown_999',
      ]);

      expect(resolved.length, 2);
      expect(resolved[0].title, 'Urban Runner Sneakers');
      expect(resolved[0].badge, '25% OFF');
      expect(resolved[1].title, 'Product unknown_999');
      expect(resolved[1].badge, 'CUSTOM');

      final emptyResolved = MockGoodsCatalog.resolveSkus([]);
      expect(emptyResolved, isEmpty);
    });
  });
}
