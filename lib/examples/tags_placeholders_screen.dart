import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import '../sdk/ias_config.dart';

class TagsPlaceholdersScreen extends StatefulWidget {
  const TagsPlaceholdersScreen({super.key, bool? configured})
    : _configuredOverride = configured;

  /// Overrides [iasConfigured] for testing; defaults to the real SDK config.
  final bool? _configuredOverride;

  @override
  State<TagsPlaceholdersScreen> createState() => _TagsPlaceholdersScreenState();
}

class _TagsPlaceholdersScreenState extends State<TagsPlaceholdersScreen> {
  bool get _configured => widget._configuredOverride ?? iasConfigured;

  late final FeedStoriesController _feedController = FeedStoriesController();
  final _tagsController = TextEditingController(text: 'tag1');
  final _placeholdersController = TextEditingController(
    text: 'name=Alex, discount=20%, avatar=https://placehold.co/100x100.png',
  );
  bool _isApplying = false;

  @override
  void dispose() {
    _tagsController.dispose();
    _placeholdersController.dispose();
    if (_configured) {
      try {
        InAppStoryManager.instance.setTags([]);
        InAppStoryManager.instance.setPlaceholders({});
      } catch (_) {
        // Platform channel absent in tests — ignore.
      }
    }
    super.dispose();
  }

  Future<void> _onApplyAndRefresh() async {
    if (_isApplying) return;
    setState(() => _isApplying = true);
    try {
      final ias = InAppStoryManager.instance;
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
      final placeholders = <String, String>{};
      for (final entry in _placeholdersController.text.split(',')) {
        final separator = entry.indexOf('=');
        if (separator > 0) {
          final key = entry.substring(0, separator).trim().replaceAll('%', '');
          final value = entry.substring(separator + 1).trim();
          if (key.isNotEmpty && value.isNotEmpty) placeholders[key] = value;
        }
      }
      await ias.setTags(tags);
      await ias.setPlaceholders(placeholders);
      await _feedController.fetchFeedStories();
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  Future<void> _onClearAll() async {
    if (_isApplying) return;
    setState(() {
      _isApplying = true;
      _tagsController.clear();
      _placeholdersController.clear();
    });
    try {
      final ias = InAppStoryManager.instance;
      await ias.setTags([]);
      await ias.setPlaceholders({});
      await _feedController.fetchFeedStories();
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tags & Placeholders')),
      body: _configured
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FeedStoriesWidget(
                    feed: iasDefaultFeedSlug,
                    controller: _feedController,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          key: const Key('tags-field'),
                          controller: _tagsController,
                          decoration: const InputDecoration(
                            labelText: 'Tags',
                            hintText: 'tag1, vip, promo',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          key: const Key('placeholders-field'),
                          controller: _placeholdersController,
                          minLines: 2,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Placeholders',
                            hintText:
                                'name=Alex, avatar=https://example.com/avatar.png',
                            helperText: 'Text values and image URLs',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                key: const Key('apply-refresh-button'),
                                onPressed: _isApplying
                                    ? null
                                    : _onApplyAndRefresh,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Apply'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                key: const Key('clear-all-button'),
                                onPressed: _isApplying ? null : _onClearAll,
                                icon: const Icon(Icons.clear_all),
                                label: const Text('Clear'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const _SdkNotConfiguredWarning(),
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
