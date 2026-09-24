import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

import '../sdk/ias_config.dart';
import '../sdk/reset_inappstory.dart';

/// Demonstrates presenting onboarding with custom content and reader options.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, bool? configured})
    : _configuredOverride = configured;

  /// Overrides [iasConfigured] for testing; defaults to the real SDK config.
  final bool? _configuredOverride;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with IASOnboardingLoadCallback {
  bool get _configured => widget._configuredOverride ?? iasConfigured;

  /// Maximum onboarding stories requested per call.
  static const int _limit = 10;

  /// Feed to present; `null` uses the SDK default (`'onboarding'`).
  static const String _feed = iasOnboardingFeed;

  /// Tag overrides for content selection; `null` keeps the user's settings tags.
  static const List<String>? _tags = null;

  static const bool _panelHasLike = true;
  static const bool _panelHasFavorites = true;
  static const bool _panelHasShare = true;

  @override
  void initState() {
    super.initState();
    if (_configured) _applyPanelSettings();
  }

  /// Configures the global reader panel before presentation.
  ///
  /// Guarded so a missing platform channel (widget tests) never blocks the screen.
  Future<void> _applyPanelSettings() async {
    try {
      final appearance = AppearanceManager.instance;
      await appearance.setHasLike(_panelHasLike);
      await appearance.setHasFavorites(_panelHasFavorites);
      await appearance.setHasShare(_panelHasShare);
    } catch (_) {
      // Ignored: no live SDK (tests). Presentation is unaffected.
    }
  }

  /// Requests onboarding presentation in the SDK reader.
  void _showOnboarding() {
    try {
      InAppStoryManager.instance.showOnboarding(
        _limit,
        feed: _feed,
        tags: _tags,
      );
    } catch (_) {
      // Ignored: no live SDK (tests); screen stays usable.
    }
  }

  @override
  void onboardingLoadSuccess(int count, String feed) {
    // count == 0 → nothing to show (all seen, or feed/tags matched nothing).
    // Not an error: no matching content simply means nothing is presented.
    developer.log(
      'onboarding loaded: count=$count feed=$feed'
      '${count == 0 ? ' (no content — nothing presented)' : ''}',
      name: 'OnboardingScreen',
    );
    super.onboardingLoadSuccess(count, feed);
  }

  @override
  void onboardingLoadError(String feed, String? reason) {
    // Surface the load failure without crashing or blocking the screen.
    developer.log(
      'onboarding load error: feed=$feed reason=${reason ?? 'unknown'}',
      name: 'OnboardingScreen',
    );
    super.onboardingLoadError(feed, reason);
  }

  @override
  void dispose() {
    // Panel settings are global state; restore defaults for other examples.
    if (_configured) resetInAppStory();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: _configured
          ? Center(
              child: FilledButton.icon(
                onPressed: _showOnboarding,
                icon: const Icon(Icons.auto_stories_outlined),
                label: const Text('Show onboarding'),
              ),
            )
          : const _SdkNotConfiguredWarning(),
    );
  }
}

/// Shown instead of the button when [iasConfigured] is false.
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
