import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import '../sdk/ias_config.dart';

/// Customizes story cells with standard SDK means.
///
/// A [FeedStoryDecorator] passed to [FeedStoriesWidget] controls each cell's
/// appearance. The decorator is scoped to this screen and does not affect other
/// examples.
///
/// A title-visibility toggle swaps between two decorators. The plugin exposes
/// no native `showTitle` flag, so the "hidden" variant collapses the title via
/// its text style.
class CellCustomizationScreen extends StatefulWidget {
  const CellCustomizationScreen({super.key, bool? configured})
      : _configuredOverride = configured;

  /// Overrides [iasConfigured] for testing; defaults to the real SDK config.
  final bool? _configuredOverride;

  @override
  State<CellCustomizationScreen> createState() =>
      _CellCustomizationScreenState();
}

class _CellCustomizationScreenState extends State<CellCustomizationScreen> {
  bool _titleVisible = true;

  @override
  Widget build(BuildContext context) {
    final configured = widget._configuredOverride ?? iasConfigured;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cell customization'),
        actions: configured
            ? [
                const Center(child: Text('Title')),
                Switch(
                  value: _titleVisible,
                  onChanged: (value) => setState(() => _titleVisible = value),
                ),
              ]
            : null,
      ),
      body: configured
          // FeedStoriesWidget captures its decorator once in initState and
          // ignores later decorator changes, so a changing key is required to
          // force a rebuild when the title toggle flips.
          // ponytail: rebuild refetches the feed on toggle; drop the key if a
          // future plugin version applies decorator changes live.
          ? FeedStoriesWidget(
              key: ValueKey(_titleVisible),
              feed: iasDefaultFeedSlug,
              height: 160,
              decorator: _titleVisible ? _titledCell : _hiddenTitleCell,
            )
          : const _SdkNotConfiguredWarning(),
    );
  }
}

/// Cell appearance with a visible, customized title.
const _titledCell = FeedStoryDecorator(
  borderRadius: BorderRadius.all(Radius.circular(20)),
  showBorder: true,
  borderWidth: 3,
  borderColor: Colors.deepPurple,
  borderPadding: 4,
  feedPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  storyPadding: 16,
  textPadding: EdgeInsets.all(8),
  textStyle: TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),
);

/// Same cell, title collapsed.
///
/// ponytail: plugin has no `showTitle`; collapse via zero-size transparent
/// text. Switch to a real flag if a future plugin version adds one.
const _hiddenTitleCell = FeedStoryDecorator(
  borderRadius: BorderRadius.all(Radius.circular(20)),
  showBorder: true,
  borderWidth: 3,
  borderColor: Colors.deepPurple,
  borderPadding: 4,
  feedPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  storyPadding: 16,
  textPadding: EdgeInsets.zero,
  textStyle: TextStyle(color: Colors.transparent, fontSize: 0, height: 0),
);

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
