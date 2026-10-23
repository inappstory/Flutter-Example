import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

import '../cart/product_cart_store.dart';
import '../sdk/ias_config.dart';

final ProductCartStore _sessionCart = ProductCartStore();

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, this.cartStore, bool? configured})
    : _configuredOverride = configured;

  final ProductCartStore? cartStore;
  final bool? _configuredOverride;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with IASCheckoutCallback<CheckoutScreen> {
  ProductCartStore get _cartStore => widget.cartStore ?? _sessionCart;
  bool get _configured => widget._configuredOverride ?? iasConfigured;

  @override
  void initState() {
    super.initState();
    _cartStore.addListener(_onCartChanged);

    if (widget.cartStore == null) {
      final cartStore = _cartStore;
      final manager = InAppStoryManager.instance;
      manager.setOnProductCartUpdate((offer) async {
        return cartStore.addProduct(offer);
      });
      manager.setGetProductCartState(() async => cartStore.snapshot);
    }
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openCart() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ProductCartScreen(cartStore: _cartStore),
      ),
    );
  }

  @override
  Future<void> onProductCartClicked() async {
    await super.onProductCartClicked();
    if (mounted) await _openCart();
  }

  @override
  void dispose() {
    _cartStore.removeListener(_onCartChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        actions: [
          IconButton(
            key: const Key('open-cart-button'),
            tooltip: 'Open cart',
            onPressed: _openCart,
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: _configured
          ? SizedBox(
              height: 160,
              child: FeedStoriesWidget(feed: iasDefaultFeedSlug),
            )
          : const _SdkNotConfiguredWarning(),
    );
  }
}

class ProductCartScreen extends StatelessWidget {
  const ProductCartScreen({super.key, required this.cartStore});

  final ProductCartStore cartStore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: AnimatedBuilder(
        animation: cartStore,
        builder: (context, _) {
          final cart = cartStore.snapshot;
          if (cart.offers.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.offers.length,
                  itemBuilder: (context, index) {
                    final offer = cart.offers[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProductImage(imageUrl: _imageUrl(offer)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    offer.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${offer.price} ${offer.currency}'),
                                  Text('Quantity: ${offer.quantity}'),
                                  if (offer.size?.isNotEmpty ?? false)
                                    Text('Size: ${offer.size}'),
                                  if (offer.color?.isNotEmpty ?? false)
                                    Text('Color: ${offer.color}'),
                                  if (offer.offerDescription?.isNotEmpty ?? false)
                                    Text(offer.offerDescription!),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Total: ${cart.price} ${cart.priceCurrency}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String? _imageUrl(ProductCartOffer offer) {
  if (offer.coverUrl?.isNotEmpty == true) return offer.coverUrl;
  for (final url in offer.imageUrls) {
    if (url.isNotEmpty) return url;
  }
  return null;
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return const SizedBox(
        width: 72,
        height: 72,
        child: Icon(Icons.shopping_bag_outlined),
      );
    }
    return Image.network(
      url,
      key: ValueKey(url),
      width: 72,
      height: 72,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const SizedBox(
        width: 72,
        height: 72,
        child: Icon(Icons.shopping_bag_outlined),
      ),
    );
  }
}

class _SdkNotConfiguredWarning extends StatelessWidget {
  const _SdkNotConfiguredWarning();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.amber[800],
            ),
            const SizedBox(height: 16),
            Text(
              'InAppStory SDK is not configured',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Set your API key in lib/sdk/ias_config.dart before running this example.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
