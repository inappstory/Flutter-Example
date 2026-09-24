import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import '../sdk/ias_config.dart';
import '../sdk/reset_inappstory.dart';

/// Demonstrates the SDK's built-in favorites controls.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, bool? configured})
    : _configuredOverride = configured;

  /// Overrides [iasConfigured] for testing; defaults to the real SDK config.
  final bool? _configuredOverride;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool get _configured => widget._configuredOverride ?? iasConfigured;

  @override
  void initState() {
    super.initState();
    if (_configured) _enableFavorites();
  }

  /// Enables the reader's favorite button and (optionally) a custom icon.
  ///
  /// Wrapped in try/catch so a missing platform channel (e.g. in widget tests)
  /// never blocks the screen — same defensive style as [resetInAppStory].
  Future<void> _enableFavorites() async {
    try {
      final appearance = AppearanceManager.instance;
      await appearance.setHasFavorites(true);

      // `setFavoriteIcon` expects native resource identifiers, not Flutter asset keys.
      //
      // await appearance.setFavoriteIcon('ic_favorite', 'ic_favorite_selected');
    } catch (_) {
      // Ignored: no live SDK (tests) — reader-driven favoriting is unaffected.
    }
  }

  @override
  void dispose() {
    // Favorites is global state — restore defaults so other examples are clean.
    if (_configured) resetInAppStory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      // The SDK default provides the favorites cell and modal grid.
      body: _configured
          ? const FeedStoriesWidget(feed: iasDefaultFeedSlug)
          : const _SdkNotConfiguredWarning(),
    );
  }
}

/// Shown instead of the feed when [iasConfigured] is false.
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
