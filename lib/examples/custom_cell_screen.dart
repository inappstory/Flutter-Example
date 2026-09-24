import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import '../sdk/ias_config.dart';

/// Maximum cell customization — a fully app-authored cell layout.
///
/// Unlike "Cell customization", which only restyles the default cell via a
/// [FeedStoryDecorator], this screen replaces the cell entirely through
/// [FeedStoriesWidget.storyBuilder]: we return our own widget per story, drawing
/// a custom frame, the real cover ([StoryContentWidget]), the title, and an
/// unread indicator ([Story.opened]). Tap is wired by hand to [Story.showReader]
/// because a custom builder disables the default tap handling.
class CustomCellScreen extends StatelessWidget {
  const CustomCellScreen({super.key, bool? configured})
      : _configuredOverride = configured;

  /// Overrides [iasConfigured] for testing; defaults to the real SDK config.
  final bool? _configuredOverride;

  @override
  Widget build(BuildContext context) {
    final configured = _configuredOverride ?? iasConfigured;
    return Scaffold(
      appBar: AppBar(title: const Text('Custom cell')),
      body: configured
          ? FeedStoriesWidget(
              feed: iasDefaultFeedSlug,
              height: 96,
              // storyPadding is the ONLY real gap between cells now — each cell
              // fills its (aspect-ratio-driven) slot, see [customStoryCell].
              decorator: const FeedStoryDecorator(
                feedPadding: EdgeInsets.symmetric(horizontal: 12),
                storyPadding: 8,
              ),
              storyBuilder: customStoryCell,
            )
          : const _SdkNotConfiguredWarning(),
    );
  }
}

/// The custom cell: an app-authored widget for one [story].
///
/// Deliberately a shape the default [FeedStoryDecorator] cannot produce: a
/// circular "stories" avatar with a gradient unread ring and the title inside a
/// bottom scrim. The plugin wraps every cell in an [AspectRatio] sized from the
/// story's own ratio, so the cell fills that slot (via [LayoutBuilder]) instead
/// of using a fixed width — otherwise a smaller avatar would leave large gaps
/// between cells.
///
/// Extracted as a top-level function so it can be unit-pumped with a stub
/// [Story] in tests. The [decorator] argument (the feed widget's own decorator)
/// is intentionally unused here — this cell owns its whole appearance.
Widget customStoryCell(Story story, FeedStoryDecorator decorator) {
  final unread = !story.opened;
  return LayoutBuilder(
    builder: (context, constraints) {
      final diameter = constraints.biggest.shortestSide;
      return GestureDetector(
        onTap: () => story.showReader(),
        child: Center(
          child: Container(
            width: diameter,
            height: diameter,
            padding: const EdgeInsets.all(3),
            // Ring: a gradient when unread, flat grey when read.
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: unread
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7B2FF7),
                        Color(0xFFF107A3),
                        Color(0xFFFFB199),
                      ],
                    )
                  : null,
              color: unread ? null : Colors.grey.shade400,
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    StoryContentWidget(story: story),
                    // Scrim (a DecoratedBox, not a Container — keeps the ring
                    // the only gradient Container, which the tests key on).
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 4, right: 4),
                        child: Text(
                          story.title,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
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
