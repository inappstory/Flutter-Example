import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import '../sdk/ias_config.dart';

/// Minimal reference integration: a single default-feed stories widget.
///
/// The InAppStory manager is initialized once, globally, in `main.dart`
/// before `runApp()` runs — this screen intentionally does NOT call
/// `initWith` again. Because init is awaited before `runApp()`, every
/// screen (including this one) is guaranteed to build only after the
/// manager is ready, so no separate readiness check is needed. If the
/// developer never set a real API key, [iasConfigured] catches that and
/// this screen shows a warning instead of a feed that would just fail.
class SimpleIntegrationScreen extends StatelessWidget {
  const SimpleIntegrationScreen({super.key, bool? configured})
      : _configuredOverride = configured;

  /// Overrides [iasConfigured] for testing; defaults to the real SDK config.
  final bool? _configuredOverride;

  @override
  Widget build(BuildContext context) {
    final configured = _configuredOverride ?? iasConfigured;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Integration'),
      ),
      body: configured
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
