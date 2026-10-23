import 'package:flutter/foundation.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

class ProductCartValidationException implements Exception {
  const ProductCartValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProductCartStore extends ChangeNotifier {
  final List<ProductCartOffer> _offers = [];
  String? _currency;

  ProductCart get snapshot {
    var totalCents = BigInt.zero;
    for (final offer in _offers) {
      totalCents += _priceInCents(offer.price!) * BigInt.from(offer.quantity);
    }

    return ProductCart(
      offers: _offers.map(_copyOffer).toList(),
      price: _formatCents(totalCents),
      priceCurrency: _currency ?? '',
    );
  }

  ProductCart addProduct(ProductCartOffer offer) {
    final id = offer.offerId.trim();
    if (id.isEmpty) {
      throw const ProductCartValidationException(
        'Product identifier must not be empty.',
      );
    }
    if (offer.quantity <= 0) {
      throw const ProductCartValidationException(
        'Product quantity must be greater than zero.',
      );
    }

    final currency = offer.currency?.trim();
    if (currency == null || currency.isEmpty) {
      throw const ProductCartValidationException(
        'Product currency must not be empty.',
      );
    }
    if (_currency != null && currency != _currency) {
      throw ProductCartValidationException(
        'Product currency $currency does not match cart currency $_currency.',
      );
    }

    final cents = _priceInCents(offer.price);
    final index = _offers.indexWhere(
      (existing) =>
          existing.offerId == id &&
          existing.size == offer.size &&
          existing.color == offer.color,
    );
    final quantity = offer.quantity + (index < 0 ? 0 : _offers[index].quantity);
    final updatedOffer = _copyOffer(offer)
      ..offerId = id
      ..price = _formatCents(cents)
      ..currency = currency
      ..quantity = quantity;

    if (index < 0) {
      _offers.add(updatedOffer);
    } else {
      _offers[index] = updatedOffer;
    }
    _currency ??= currency;
    notifyListeners();
    return snapshot;
  }

  static ProductCartOffer _copyOffer(ProductCartOffer offer) {
    return ProductCartOffer(
      offerId: offer.offerId,
      groupId: offer.groupId,
      name: offer.name,
      offerDescription: offer.offerDescription,
      url: offer.url,
      coverUrl: offer.coverUrl,
      imageUrls: List<String>.of(offer.imageUrls),
      currency: offer.currency,
      price: offer.price,
      oldPrice: offer.oldPrice,
      adult: offer.adult,
      availability: offer.availability,
      size: offer.size,
      color: offer.color,
      quantity: offer.quantity,
    );
  }

  static BigInt _priceInCents(String? price) {
    final value = price?.trim();
    final match = value == null
        ? null
        : RegExp(r'^(\d+)(?:\.(\d+))?$').firstMatch(value);
    if (match == null) {
      throw const ProductCartValidationException(
        'Product price must be a non-negative decimal number.',
      );
    }

    final whole = BigInt.parse(match.group(1)!);
    final fraction = match.group(2) ?? '';
    final cents = BigInt.parse(fraction.padRight(2, '0').substring(0, 2));
    final roundUp = fraction.length > 2 && int.parse(fraction[2]) >= 5;
    return whole * BigInt.from(100) +
        cents +
        (roundUp ? BigInt.one : BigInt.zero);
  }

  static String _formatCents(BigInt cents) {
    final whole = cents ~/ BigInt.from(100);
    final fraction = (cents % BigInt.from(100)).toString().padLeft(2, '0');
    return '$whole.$fraction';
  }
}
