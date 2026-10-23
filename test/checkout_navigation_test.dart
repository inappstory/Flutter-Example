import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example/cart/product_cart_store.dart';
import 'package:flutter_example/examples/checkout_screen.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

ProductCartOffer _offer() {
  return ProductCartOffer(
    offerId: 'sku-1',
    name: 'Demo product',
    imageUrls: const [],
    currency: 'USD',
    price: '9.99',
    availability: 1,
    quantity: 1,
  );
}

void main() {
  testWidgets('closes reader before opening cart and preserves cart on return', (
    tester,
  ) async {
    final cart = ProductCartStore()..addProduct(_offer());
    final messenger = tester.binding.defaultBinaryMessenger;
    var readerClosed = false;
    messenger.setMockMessageHandler(
      'dev.flutter.pigeon.inappstory_plugin.InAppStoryManagerHostApi.closeReaders',
      (_) async {
        expect(find.text('Cart'), findsNothing);
        readerClosed = true;
        return const StandardMessageCodec().encodeMessage(<Object?>[null]);
      },
    );

    await tester.pumpWidget(
      MaterialApp(home: CheckoutScreen(cartStore: cart, configured: false)),
    );

    final callbackResponse = await messenger.handlePlatformMessage(
      'dev.flutter.pigeon.inappstory_plugin.CheckoutCallbackFlutterApi.onProductCartClicked',
      const StandardMessageCodec().encodeMessage(null),
      (ByteData? _) {},
    );
    expect(callbackResponse, isNotNull);

    await tester.pumpAndSettle();

    expect(readerClosed, isTrue);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Demo product'), findsOneWidget);
    expect(find.text('Total: 9.99 USD'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Checkout'), findsOneWidget);
    await tester.tap(find.byKey(const Key('open-cart-button')));
    await tester.pumpAndSettle();
    expect(find.text('Demo product'), findsOneWidget);
    expect(find.text('Total: 9.99 USD'), findsOneWidget);
  });
}
