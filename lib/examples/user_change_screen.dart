import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import '../sdk/ias_config.dart';

/// The named (identified) user this example logs in to. Edit [iasUserChangeUserId]
/// and [iasUserChangeUserSign] in `lib/sdk/ias_config.dart` to a real user from
/// your InAppStory project. `userSign` is only needed for projects that use
/// signed users; leave it null otherwise.
const String userChangeUserId = iasUserChangeUserId;
const String? userChangeUserSign = iasUserChangeUserSign;

/// Demonstrates switching between anonymous and named users.
///
/// Models the "after login / logout" moment: the screen starts on the SDK's
/// **anonymous** user and the button toggles between anonymous and a preset
/// **named** user, reloading the feed under the new identity each time.
///
/// `changeUser` logs in the named user, and `userLogout` returns to anonymous.
/// The feed is refreshed with [FeedStoriesController.fetchFeedStories] after
/// each switch.
///
/// The SDK user is global state, so the screen logs out on [dispose] to avoid
/// affecting other examples.
class UserChangeScreen extends StatefulWidget {
  const UserChangeScreen({super.key, bool? configured})
    : _configuredOverride = configured;

  /// Overrides [iasConfigured] for testing; defaults to the real SDK config.
  final bool? _configuredOverride;

  @override
  State<UserChangeScreen> createState() => _UserChangeScreenState();
}

class _UserChangeScreenState extends State<UserChangeScreen> {
  bool get _configured => widget._configuredOverride ?? iasConfigured;

  /// Drives the feed reload after a switch; passed to [FeedStoriesWidget].
  late final FeedStoriesController _controller = FeedStoriesController();

  /// false = anonymous (start state), true = the named user is logged in.
  bool _isNamed = false;

  /// Guards against overlapping switches from rapid taps.
  bool _switching = false;

  /// Toggles the SDK user (anonymous ↔ named) and reloads the feed.
  ///
  /// Every SDK call is wrapped in try/catch so a missing platform channel
  /// (e.g. in widget tests) never throws — same defensive style as the other
  /// example screens.
  Future<void> _onSwitchUser() async {
    if (_switching) return;
    _switching = true;
    try {
      final ias = InAppStoryManager.instance;
      if (_isNamed) {
        // Named → anonymous (logout).
        await ias.userLogout();
      } else {
        // Anonymous → named (login).
        await ias.changeUser(userChangeUserId, userSign: userChangeUserSign);
      }
      // Reload the feed so it re-fetches under the now-current identity.
      await _controller.fetchFeedStories();
      if (mounted) setState(() => _isNamed = !_isNamed);
    } catch (_) {
      // No live SDK (tests) or a switch failure — keep the UI usable.
    } finally {
      _switching = false;
    }
  }

  @override
  void dispose() {
    // Current user is global state — return to the anonymous baseline so the
    // switched user does not leak into other examples.
    if (_configured) {
      try {
        InAppStoryManager.instance.userLogout();
      } catch (_) {
        // No live SDK — nothing to reset.
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Change')),
      body: _configured
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FeedStoriesWidget(
                  feed: iasDefaultFeedSlug,
                  controller: _controller,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        _isNamed
                            ? 'Current user: named'
                            : 'Current user: anonymous',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _onSwitchUser,
                        child: const Text('Switch user'),
                      ),
                    ],
                  ),
                ),
              ],
            )
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
