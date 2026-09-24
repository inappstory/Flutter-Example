import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import '../sdk/ias_config.dart';
import '../sdk/reset_inappstory.dart';

/// Configures reader appearance for this example screen.
class ReaderCustomizationScreen extends StatefulWidget {
  const ReaderCustomizationScreen({super.key, bool? configured})
    : _configuredOverride = configured;

  /// Overrides [iasConfigured] for testing; defaults to the real SDK config.
  final bool? _configuredOverride;

  @override
  State<ReaderCustomizationScreen> createState() =>
      _ReaderCustomizationScreenState();
}

class _ReaderCustomizationScreenState extends State<ReaderCustomizationScreen> {
  bool get _configured => widget._configuredOverride ?? iasConfigured;

  @override
  void initState() {
    super.initState();
    if (_configured) _applyReaderAppearance();
  }

  /// Applies the reader appearance for this example before any reader opens.
  ///
  /// Wrapped in try/catch so a missing platform channel (e.g. in widget tests)
  /// never blocks the screen — same defensive style as [resetInAppStory].
  Future<void> _applyReaderAppearance() async {
    try {
      final appearance = AppearanceManager.instance;

      await appearance.setClosePosition(Position.bottomLeft);
      await appearance.setReaderScrollStyle(ScrollStyle.cube);
      await appearance.setReaderPresentationStyle(PresentationStyle.zoom);
      await appearance.setLikeIcon(
        'assets/icons/like_unselected.png',
        'assets/icons/like.png',
      );

      await appearance.setHasLike(true);
      await appearance.setHasFavorites(true);
      await appearance.setHasShare(true);
    } catch (_) {}
  }

  @override
  void dispose() {
    // Restore global reader appearance before another example opens.
    if (_configured) resetInAppStory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reader customization')),
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
