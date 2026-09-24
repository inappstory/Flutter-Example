import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import '../sdk/ias_config.dart';
import '../sdk/reset_inappstory.dart';

/// The story opened by the "Single story" example. Edit [iasSingleStoryId] in
/// `lib/sdk/ias_config.dart` to a real story ID from your InAppStory project.
const String singleStoryId = iasSingleStoryId;

/// Opens one story by ID and temporarily enables the reader's bottom-panel controls.
///
/// Panel settings are global singleton state, and [AppearanceManager] has no
/// getters to capture the previous values. This example restores the known app
/// baseline when the reader closes, when opening fails, and when the screen exits.
class SingleStoryScreen extends StatefulWidget {
  const SingleStoryScreen({super.key, bool? configured})
    : _configuredOverride = configured;

  /// Overrides [iasConfigured] for testing; defaults to the real SDK config.
  final bool? _configuredOverride;

  @override
  State<SingleStoryScreen> createState() => _SingleStoryScreenState();
}

class _SingleStoryScreenState extends State<SingleStoryScreen>
    with IASCallbacks {
  bool get _configured => widget._configuredOverride ?? iasConfigured;

  /// Applies this example's per-show panel override, then shows the story.
  ///
  /// Wrapped in try/catch so a missing platform channel (e.g. widget tests)
  /// never throws — same defensive style as [resetInAppStory].
  Future<void> _showSingleStory() async {
    try {
      final appearance = AppearanceManager.instance;
      await appearance.setHasLike(true);
      await appearance.setHasFavorites(true);
      await appearance.setHasShare(true);

      // If the reader did not open, onCloseStory will not fire; restore now.
      final shown = await InAppStoryManager.instance
          .showStory(singleStoryId)
          .valueOrCancellation(false);
      if (shown != true) _restoreBaseline();
    } catch (_) {
      // No live SDK (tests) — nothing shown; keep baseline clean.
      _restoreBaseline();
    }
  }

  /// Restores the app baseline panel configuration (all controls off).
  void _restoreBaseline() {
    if (_configured) resetInAppStory();
  }

  @override
  void onCloseStory(SlideDataDto? slideData) {
    // Restore the baseline so this example's settings do not affect other screens.
    _restoreBaseline();
  }

  @override
  void dispose() {
    // Safety net if the screen is popped before a close callback arrives.
    _restoreBaseline();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Single story')),
      body: _configured
          ? Center(
              child: ElevatedButton(
                onPressed: _showSingleStory,
                child: const Text('Show story'),
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
