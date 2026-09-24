import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import '../sdk/ias_config.dart';
import '../sdk/reset_inappstory.dart';

/// Represents a product item in the application's mock catalog.
class GoodsProduct {
  const GoodsProduct({
    required this.sku,
    required this.title,
    required this.description,
    required this.price,
    this.oldPrice,
    this.imageUrl,
    this.badge,
    this.inStock = true,
  });

  final String sku;
  final String title;
  final String description;
  final String price;
  final String? oldPrice;
  final String? imageUrl;
  final String? badge;
  final bool inStock;

  /// Converts this model into the SDK's [GoodsItemData] format.
  GoodsItemData toSdkGoodsItemData() {
    return GoodsItemData(
      sku: sku,
      title: title,
      description: description,
      price: price,
      oldPrice: oldPrice,
      image: imageUrl,
    );
  }
}

/// Category of goods-related interaction events.
enum GoodsEventType {
  skuRequested,
  itemSelected,
  addedToCart,
  overlayDismissed,
  readerClosed,
}

/// Record of an event triggered by custom goods interactions.
class GoodsInteractionEvent {
  const GoodsInteractionEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.details,
    this.sku,
  });

  final String id;
  final DateTime timestamp;
  final GoodsEventType type;
  final String? sku;
  final String details;
}

/// In-memory catalog repository providing sample product data.
class MockGoodsCatalog {
  static const Map<String, GoodsProduct> _catalog = {
    'sku_sneakers_01': GoodsProduct(
      sku: 'sku_sneakers_01',
      title: 'Urban Runner Sneakers',
      description: 'Breathable cushioning engineered for daily city running.',
      price: '\$120',
      oldPrice: '\$160',
      imageUrl: 'https://placehold.co/200x200/png?text=Sneakers',
      badge: '25% OFF',
    ),
    'sku_hoodie_02': GoodsProduct(
      sku: 'sku_hoodie_02',
      title: 'Oversized Street Hoodie',
      description: 'Heavyweight organic cotton fleece with boxy modern cut.',
      price: '\$85',
      oldPrice: '\$110',
      imageUrl: 'https://placehold.co/200x200/png?text=Hoodie',
      badge: 'NEW',
    ),
    'sku_backpack_03': GoodsProduct(
      sku: 'sku_backpack_03',
      title: 'Waterproof Tech Backpack',
      description: 'Weatherproof 20L daypack with padded 16-inch laptop pocket.',
      price: '\$95',
      imageUrl: 'https://placehold.co/200x200/png?text=Backpack',
      badge: 'POPULAR',
    ),
    'sku_watch_04': GoodsProduct(
      sku: 'sku_watch_04',
      title: 'Minimalist Chrono Watch',
      description: 'Sapphire crystal glass and genuine Italian leather strap.',
      price: '\$210',
      oldPrice: '\$250',
      imageUrl: 'https://placehold.co/200x200/png?text=Watch',
      badge: 'LIMITED',
    ),
  };

  /// Resolves a list of SKU identifiers into [GoodsProduct] models.
  static List<GoodsProduct> resolveSkus(List<String> skus) {
    if (skus.isEmpty) return const [];
    return skus.map((sku) {
      final found = _catalog[sku];
      if (found != null) return found;
      // Fallback for unknown SKUs
      return GoodsProduct(
        sku: sku,
        title: 'Product $sku',
        description: 'Dynamic catalog item for identifier $sku.',
        price: '\$99',
        badge: 'CUSTOM',
      );
    }).toList();
  }

  /// Preset sample SKU lists for simulation.
  static const List<String> presetSneakersAndHoodie = [
    'sku_sneakers_01',
    'sku_hoodie_02',
  ];

  static const List<String> presetFullCatalog = [
    'sku_sneakers_01',
    'sku_hoodie_02',
    'sku_backpack_03',
    'sku_watch_04',
  ];

  static const List<String> presetUnknownSku = ['sku_custom_99'];
}

/// Demonstrates a fully custom goods presentation.
///
/// Demonstrates complete replacement of the built-in goods presentation with a
/// host-controlled custom UI overlay:
/// - Intercepts SKU lookups via [InAppStoryManager.setGetSkusCallback].
/// - Listens for product selection callbacks via [IASGoodItemSelectedCallback].
/// - Provides a rich custom modal bottom sheet ([CustomGoodsOverlaySheet])
///   featuring custom typography, badges, price strikethroughs, and cart actions.
/// - Demonstrates programmatic story reader dismissal via [InAppStoryManager.closeReaders].
///
/// Restores default SDK state on [dispose] to maintain clean isolation.
class CustomGoodsScreen extends StatefulWidget {
  const CustomGoodsScreen({super.key, bool? configured})
      : _configuredOverride = configured;

  /// Overrides [iasConfigured] for testing; defaults to the real SDK config.
  final bool? _configuredOverride;

  @override
  State<CustomGoodsScreen> createState() => _CustomGoodsScreenState();
}

class _CustomGoodsScreenState extends State<CustomGoodsScreen>
    with IASGoodItemSelectedCallback {
  bool get _configured => widget._configuredOverride ?? iasConfigured;

  int _selectedPresetIndex = 0;
  final List<GoodsInteractionEvent> _events = [];
  int _cartCount = 0;

  static const List<String> _presetNames = [
    'Sneakers & Hoodie',
    'Full Catalog',
    'Unknown SKU',
    'Empty List',
  ];

  @override
  void initState() {
    super.initState();
    _setupSdkCallbacks();
  }

  void _setupSdkCallbacks() {
    if (!_configured) return;
    try {
      InAppStoryManager.instance.setGetSkusCallback((List<String> skus) async {
        final products = MockGoodsCatalog.resolveSkus(skus);
        _logEvent(
          GoodsEventType.skuRequested,
          skus.join(', '),
          'Resolved ${products.length} catalog items for story goods widget.',
        );
        return products.map((p) => p.toSdkGoodsItemData()).toList();
      });
    } catch (_) {
      // Platform channel absent in tests — ignore.
    }
  }

  @override
  void dispose() {
    if (_configured) {
      try {
        InAppStoryManager.instance.setGetSkusCallback((_) async => []);
        resetInAppStory();
      } catch (_) {
        // Platform channel absent in tests — ignore.
      }
    }
    super.dispose();
  }

  @override
  Future<void> goodsItemSelected(GoodsItemDataDto item) async {
    _logEvent(
      GoodsEventType.itemSelected,
      item.sku,
      'Product selected in story: ${item.title ?? item.sku}',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected: ${item.title ?? item.sku} (${item.price ?? ""})'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _logEvent(GoodsEventType type, String? sku, String details) {
    if (!mounted) return;
    setState(() {
      _events.insert(
        0,
        GoodsInteractionEvent(
          id: '${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          type: type,
          sku: sku,
          details: details,
        ),
      );
      if (_events.length > 50) {
        _events.removeLast();
      }
    });
  }

  List<String> _getActivePresetSkus() {
    switch (_selectedPresetIndex) {
      case 0:
        return MockGoodsCatalog.presetSneakersAndHoodie;
      case 1:
        return MockGoodsCatalog.presetFullCatalog;
      case 2:
        return MockGoodsCatalog.presetUnknownSku;
      case 3:
      default:
        return const [];
    }
  }

  void _previewCustomOverlay() {
    final skus = _getActivePresetSkus();
    final products = MockGoodsCatalog.resolveSkus(skus);

    _logEvent(
      GoodsEventType.skuRequested,
      skus.join(', '),
      'Previewing custom overlay with ${products.length} products.',
    );

    CustomGoodsOverlaySheet.show(
      context: context,
      products: products,
      onAddToCart: _handleAddToCart,
      onProceedToCheckout: _handleCheckout,
      onDismissed: () {
        _logEvent(
          GoodsEventType.overlayDismissed,
          null,
          'Custom goods overlay dismissed by user.',
        );
      },
    );
  }

  void _handleAddToCart(GoodsProduct product) {
    setState(() {
      _cartCount++;
    });
    _logEvent(
      GoodsEventType.addedToCart,
      product.sku,
      'Added "${product.title}" to cart (Total: $_cartCount).',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${product.title}" to cart!'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleCheckout() {
    _logEvent(
      GoodsEventType.readerClosed,
      null,
      'Invoked closeReaders() for checkout flow.',
    );
    try {
      InAppStoryManager.instance.closeReaders();
    } catch (_) {
      // Platform channel absent in tests — ignore.
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proceeding to checkout — story reader closed.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearLog() {
    setState(() {
      _events.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom GoodsWidget'),
        actions: [
          if (_cartCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Badge(
                  label: Text('$_cartCount'),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
              ),
            ),
        ],
      ),
      body: _configured
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Context Explanation Card
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.storefront,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Full UI Goods Override',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This screen demonstrates replacing the SDK goods widget with a '
                            'custom Flutter UI overlay. The host app receives SKU queries via '
                            'setGetSkusCallback and handles product presentation and interactions directly.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stories Feed Section
                  _buildSectionHeader('Stories Feed'),
                  const SizedBox(height: 8),
                  const SizedBox(
                    height: 140,
                    child: FeedStoriesWidget(feed: iasDefaultFeedSlug),
                  ),
                  const SizedBox(height: 16),

                  // Simulation & Preview Controls
                  _buildSectionHeader('Preview Custom Goods UI'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_presetNames.length, (index) {
                      return ChoiceChip(
                        key: Key('preset-chip-$index'),
                        label: Text(_presetNames[index]),
                        selected: _selectedPresetIndex == index,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedPresetIndex = index;
                            });
                          }
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    key: const Key('preview-overlay-button'),
                    onPressed: _previewCustomOverlay,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Preview Custom Goods Overlay'),
                  ),
                  const Divider(height: 32),

                  // Event Log Header & Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('Goods Interaction Log'),
                      TextButton.icon(
                        key: const Key('clear-log-button'),
                        onPressed: _events.isEmpty ? null : _clearLog,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Event Log View
                  if (_events.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'No events logged yet. Tap "Preview Custom Goods Overlay" or open a story with goods.',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _events.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return _buildEventTile(event);
                      },
                    ),
                ],
              ),
            )
          : const _SdkNotConfiguredWarning(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildEventTile(GoodsInteractionEvent event) {
    IconData icon;
    Color color;
    String label;

    switch (event.type) {
      case GoodsEventType.skuRequested:
        icon = Icons.search;
        color = Colors.blue;
        label = 'SKU Request';
        break;
      case GoodsEventType.itemSelected:
        icon = Icons.touch_app;
        color = Colors.purple;
        label = 'Item Selected';
        break;
      case GoodsEventType.addedToCart:
        icon = Icons.add_shopping_cart;
        color = Colors.green;
        label = 'Added to Cart';
        break;
      case GoodsEventType.overlayDismissed:
        icon = Icons.close;
        color = Colors.grey;
        label = 'Overlay Closed';
        break;
      case GoodsEventType.readerClosed:
        icon = Icons.exit_to_app;
        color = Colors.orange;
        label = 'Reader Closed';
        break;
    }

    final timeStr =
        '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}';

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: color.withAlpha(30),
        child: Icon(icon, size: 16, color: color),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeStr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
      subtitle: Text(
        event.details,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

/// Custom goods modal bottom sheet component replacing the default SDK goods UI.
class CustomGoodsOverlaySheet extends StatelessWidget {
  const CustomGoodsOverlaySheet({
    super.key,
    required this.products,
    required this.onAddToCart,
    required this.onProceedToCheckout,
  });

  final List<GoodsProduct> products;
  final void Function(GoodsProduct) onAddToCart;
  final VoidCallback onProceedToCheckout;

  /// Convenience method to display the modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required List<GoodsProduct> products,
    required void Function(GoodsProduct) onAddToCart,
    required VoidCallback onProceedToCheckout,
    VoidCallback? onDismissed,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => CustomGoodsOverlaySheet(
        products: products,
        onAddToCart: onAddToCart,
        onProceedToCheckout: onProceedToCheckout,
      ),
    ).then((_) {
      onDismissed?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Featured Products',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${products.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  key: const Key('close-overlay-button'),
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Product Cards List or Empty State
            if (products.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No products available for this story.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 340),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: products.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return CustomGoodsCard(
                      product: product,
                      onAddToCart: () => onAddToCart(product),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Footer Checkout Action
            if (products.isNotEmpty)
              ElevatedButton.icon(
                key: const Key('checkout-button'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onProceedToCheckout();
                },
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text('Proceed to Checkout'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom product card displaying styled details and interactive actions.
class CustomGoodsCard extends StatelessWidget {
  const CustomGoodsCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  final GoodsProduct product;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail / Icon Placeholder
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.shopping_bag,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Text(
                            product.badge!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Price & Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            product.price,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          if (product.oldPrice != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              product.oldPrice!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey[500],
                                  ),
                            ),
                          ],
                        ],
                      ),
                      FilledButton.tonalIcon(
                        key: Key('add-to-cart-${product.sku}'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: onAddToCart,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Warning widget displayed when [iasConfigured] is false.
class _SdkNotConfiguredWarning extends StatelessWidget {
  const _SdkNotConfiguredWarning();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 64, color: Colors.amber[800]),
            const SizedBox(height: 16),
            Text(
              'InAppStory SDK is not configured',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Set your API key in lib/sdk/ias_config.dart before running this example.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
