import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import '../sdk/ias_config.dart';
import '../sdk/reset_inappstory.dart';

/// Simple multi-feed screen that shows two independent story feeds in one view.
class MultiFeedScreen extends StatefulWidget {
  const MultiFeedScreen({super.key, bool? configured})
    : _configuredOverride = configured;

  final bool? _configuredOverride;

  @override
  State<MultiFeedScreen> createState() => _MultiFeedScreenState();
}

class _MultiFeedScreenState extends State<MultiFeedScreen> {
  bool get _configured => widget._configuredOverride ?? iasConfigured;

  late final FeedStoriesController _defaultFeedController =
      FeedStoriesController();
  late final FeedStoriesController _customFeedController =
      FeedStoriesController();

  static const String defaultFeedSlug = iasDefaultFeedSlug;
  static const String customFeedSlug = iasCustomFeedSlug;

  bool _isRefreshingDefault = false;
  bool _isRefreshingCustom = false;

  @override
  void dispose() {
    if (_configured) {
      try {
        resetInAppStory();
      } catch (_) {
        // Platform channel absent in tests — ignore.
      }
    }
    super.dispose();
  }

  Future<void> _refreshDefaultFeed() async {
    if (_isRefreshingDefault) return;

    setState(() => _isRefreshingDefault = true);

    try {
      await _defaultFeedController.fetchFeedStories().timeout(
        const Duration(milliseconds: 300),
      );
    } catch (_) {
      // Platform channel absent in tests or timed out — ignore.
    } finally {
      if (mounted) {
        setState(() => _isRefreshingDefault = false);
      }
    }
  }

  Future<void> _refreshCustomFeed() async {
    if (_isRefreshingCustom) return;

    setState(() => _isRefreshingCustom = true);

    try {
      await _customFeedController.fetchFeedStories().timeout(
        const Duration(milliseconds: 300),
      );
    } catch (_) {
      // Platform channel absent in tests or timed out — ignore.
    } finally {
      if (mounted) {
        setState(() => _isRefreshingCustom = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi Feed')),
      body: _configured
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildFeedRow(
                    title: 'Default Feed',
                    feedSlug: defaultFeedSlug,
                    refreshButtonKey: const Key('refresh-default-feed-button'),
                    isRefreshing: _isRefreshingDefault,
                    onRefresh: _refreshDefaultFeed,
                    widgetKey: const Key('default-feed-widget'),
                    controller: _defaultFeedController,
                  ),
                  const SizedBox(height: 16),
                  _buildFeedRow(
                    title: 'Custom Feed',
                    feedSlug: customFeedSlug,
                    refreshButtonKey: const Key('refresh-custom-feed-button'),
                    isRefreshing: _isRefreshingCustom,
                    onRefresh: _refreshCustomFeed,
                    widgetKey: const Key('custom-feed-widget'),
                    controller: _customFeedController,
                  ),
                ],
              ),
            )
          : const _SdkNotConfiguredWarning(),
    );
  }

  Widget _buildFeedRow({
    required String title,
    required String feedSlug,
    required Key refreshButtonKey,
    required bool isRefreshing,
    required VoidCallback onRefresh,
    required Key widgetKey,
    required FeedStoriesController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              key: refreshButtonKey,
              onPressed: isRefreshing ? null : onRefresh,
              icon: isRefreshing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'slug: $feedSlug',
          style: TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: FeedStoriesWidget(
            key: widgetKey,
            feed: feedSlug,
            controller: controller,
          ),
        ),
      ],
    );
  }
}

/// Shown instead of the feeds when [iasConfigured] is false.
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
