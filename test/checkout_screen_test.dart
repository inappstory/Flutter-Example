import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example/cart/product_cart_store.dart';
import 'package:flutter_example/examples/checkout_screen.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

ProductCartOffer offer({
  String id = 'sku-1',
  String name = 'Demo product',
  String? price = '12.50',
  String? currency = 'USD',
  int quantity = 1,
  String? size,
  String? color,
  String? coverUrl,
  List<String> imageUrls = const [],
}) {
  return ProductCartOffer(
    offerId: id,
    name: name,
    imageUrls: imageUrls,
    coverUrl: coverUrl,
    currency: currency,
    price: price,
    availability: 1,
    size: size,
    color: color,
    quantity: quantity,
  );
}

void main() {
  testWidgets('shows an empty cart without a priced total', (tester) async {
    final cart = ProductCartStore();

    await tester.pumpWidget(
      MaterialApp(home: ProductCartScreen(cartStore: cart)),
    );

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.textContaining('0.00'), findsNothing);
  });

  testWidgets('shows product details, placeholder, quantity, and total', (
    tester,
  ) async {
    final cart = ProductCartStore()
      ..addProduct(offer(quantity: 2, size: 'M', color: 'Blue'))
      ..addProduct(
        offer(
          id: 'sku-2',
          name: 'Another product',
          price: '0.25',
          currency: 'USD',
        ),
      );

    await tester.pumpWidget(
      MaterialApp(home: ProductCartScreen(cartStore: cart)),
    );

    expect(find.text('Demo product'), findsOneWidget);
    expect(find.text('Another product'), findsOneWidget);
    expect(find.text('Quantity: 2'), findsOneWidget);
    expect(find.text('Size: M'), findsOneWidget);
    expect(find.text('Color: Blue'), findsOneWidget);
    expect(find.text('12.50 USD'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsNWidgets(2));
    expect(find.text('Total: 25.25 USD'), findsOneWidget);
  });

  testWidgets('uses the first available image when the cover is missing', (
    tester,
  ) async {
    const imageUrl = 'https://example.test/product.png';
    final cart = ProductCartStore()
      ..addProduct(offer(coverUrl: '', imageUrls: ['', imageUrl]));

    await tester.pumpWidget(
      MaterialApp(home: ProductCartScreen(cartStore: cart)),
    );

    expect(find.byKey(const ValueKey(imageUrl)), findsOneWidget);
  });
}
