import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example/cart/product_cart_store.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

ProductCartOffer offer({
  String id = 'sku-1',
  String? price = '12.50',
  String? currency = 'USD',
  int quantity = 1,
  String? size,
  String? color,
}) {
  return ProductCartOffer(
    offerId: id,
    name: 'Demo product',
    offerDescription: 'A demo item',
    imageUrls: const [],
    currency: currency,
    price: price,
    availability: 1,
    size: size,
    color: color,
    quantity: quantity,
  );
}

void main() {
  group('ProductCartStore', () {
    test('starts empty and returns current snapshots', () {
      final cart = ProductCartStore();

      expect(cart.snapshot.offers, isEmpty);
      expect(cart.snapshot.price, '0.00');

      final updated = cart.addProduct(offer());
      expect(updated.offers.single.quantity, 1);
      expect(cart.snapshot.offers.single.offerId, 'sku-1');
      expect(cart.snapshot.price, '12.50');
    });

    test('combines repeated product variants and sums their quantities', () {
      final cart = ProductCartStore();

      cart.addProduct(offer(quantity: 2));
      final updated = cart.addProduct(offer(quantity: 3));

      expect(updated.offers, hasLength(1));
      expect(updated.offers.single.quantity, 5);
      expect(updated.price, '62.50');
    });

    test('keeps different sizes and colors as separate lines', () {
      final cart = ProductCartStore();

      cart.addProduct(offer(size: 'S', color: 'Blue'));
      cart.addProduct(offer(size: 'M', color: 'Blue'));
      cart.addProduct(offer(size: 'S', color: 'Red'));

      expect(cart.snapshot.offers, hasLength(3));
    });

    test('rounds unit prices to two decimals before multiplying quantity', () {
      final cart = ProductCartStore();

      cart.addProduct(offer(price: '0.005', quantity: 3, currency: 'JPY'));

      expect(cart.snapshot.offers.single.price, '0.01');
      expect(cart.snapshot.price, '0.03');
      expect(cart.snapshot.priceCurrency, 'JPY');
    });

    test('rejects invalid offers without changing the cart', () {
      final invalidOffers = [
        offer(id: '  '),
        offer(price: null),
        offer(price: 'not-a-price'),
        offer(price: '-1.00'),
        offer(currency: null),
        offer(currency: '  '),
        offer(quantity: 0),
        offer(quantity: -1),
      ];

      for (final invalid in invalidOffers) {
        final cart = ProductCartStore();
        cart.addProduct(offer());
        final before = cart.snapshot;

        expect(
          () => cart.addProduct(invalid),
          throwsA(isA<ProductCartValidationException>()),
        );
        expect(
          cart.snapshot.offers.single.quantity,
          before.offers.single.quantity,
        );
        expect(cart.snapshot.price, before.price);
      }
    });

    test('rejects mixed currencies without changing the cart', () {
      final cart = ProductCartStore();
      cart.addProduct(offer(currency: 'USD'));

      expect(
        () => cart.addProduct(offer(id: 'sku-2', currency: 'EUR')),
        throwsA(isA<ProductCartValidationException>()),
      );
      expect(cart.snapshot.offers, hasLength(1));
      expect(cart.snapshot.priceCurrency, 'USD');
      expect(cart.snapshot.price, '12.50');
    });
  });
}
