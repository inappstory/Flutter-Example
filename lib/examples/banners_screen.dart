import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import '../sdk/ias_config.dart';

enum BannerEventType { load, scroll, action, control }

class BannerEventEntry {
  const BannerEventEntry({
    required this.timestamp,
    required this.type,
    required this.title,
    this.bannerId,
    this.placeId,
    this.index,
    this.data,
  });

  final DateTime timestamp;
  final BannerEventType type;
  final String title;
  final String? bannerId;
  final String? placeId;
  final int? index;
  final Map<String, dynamic>? data;

  String get formattedTime =>
      '${timestamp.hour.toString().padLeft(2, '0')}:'
      '${timestamp.minute.toString().padLeft(2, '0')}:'
      '${timestamp.second.toString().padLeft(2, '0')}';
}

class DotNavigationIndicator extends StatelessWidget {
  const DotNavigationIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.onDotTapped,
  });

  final int count;
  final int currentIndex;
  final ValueChanged<int> onDotTapped;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return InkWell(
          key: Key('dot-indicator-$index'),
          onTap: () => onDotTapped(index),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: isActive ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? colors.primary : colors.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class BannersScreen extends StatefulWidget {
  const BannersScreen({super.key, bool? configured})
    : _configuredOverride = configured;

  final bool? _configuredOverride;

  @override
  State<BannersScreen> createState() => BannersScreenState();
}

class BannersScreenState extends State<BannersScreen> {
  bool get _configured => widget._configuredOverride ?? iasConfigured;

  late final TextEditingController _placeIdController;

  double _bannerPlaceHeight = 140;
  int _bannerCount = 3;
  int _currentIndex = 0;
  bool _isAutoscrollPaused = false;
  final List<BannerEventEntry> _events = [];

  String get _placeId => _placeIdController.text.trim();

  @override
  void initState() {
    super.initState();
    _placeIdController = TextEditingController(text: iasBannerPlaceId);
  }

  @override
  void dispose() {
    _placeIdController.dispose();
    super.dispose();
  }

  void _addLog({
    required BannerEventType type,
    required String title,
    String? bannerId,
    String? placeId,
    int? index,
    Map<String, dynamic>? data,
  }) {
    setState(() {
      _events.insert(
        0,
        BannerEventEntry(
          timestamp: DateTime.now(),
          type: type,
          title: title,
          bannerId: bannerId,
          placeId: placeId,
          index: index,
          data: data,
        ),
      );
    });
  }

  void handleBannerPlaceLoaded(int size, int widgetHeight) {
    setState(() {
      if (size > 0) _bannerCount = size;
      if (widgetHeight > 0) _bannerPlaceHeight = widgetHeight.toDouble();
    });
    _addLog(
      type: BannerEventType.load,
      title: 'Banner place loaded ($size items, height: ${widgetHeight}px)',
      placeId: _placeId,
      data: {'size': size, 'widgetHeight': widgetHeight},
    );
  }

  void handleBannerScroll(int index) {
    setState(() => _currentIndex = index);
    _addLog(
      type: BannerEventType.scroll,
      title: 'Scrolled to banner index $index',
      index: index,
      placeId: _placeId,
    );
  }

  void handleActionWith(
    BannerData bannerData,
    String widgetEventName,
    Map<String, Object?>? widgetData,
  ) {
    _addLog(
      type: BannerEventType.action,
      title: 'Action in banner: $widgetEventName',
      bannerId: bannerData.id,
      placeId: bannerData.bannerPlace ?? _placeId,
      data: widgetData?.map((key, value) => MapEntry(key, value)),
    );
  }

  Future<void> showNext() async {
    final placeId = _placeId;
    _addLog(
      type: BannerEventType.control,
      title: 'Next banner requested',
      placeId: placeId,
    );
    try {
      await BannerPlaceManager.instance.showNext(placeId);
    } catch (error) {
      _addLog(
        type: BannerEventType.control,
        title: 'Error navigating to next banner: $error',
      );
    }
  }

  Future<void> showPrevious() async {
    final placeId = _placeId;
    _addLog(
      type: BannerEventType.control,
      title: 'Previous banner requested',
      placeId: placeId,
    );
    try {
      await BannerPlaceManager.instance.showPrevious(placeId);
    } catch (error) {
      _addLog(
        type: BannerEventType.control,
        title: 'Error navigating to previous banner: $error',
      );
    }
  }

  Future<void> showByIndex(int index) async {
    final placeId = _placeId;
    setState(() => _currentIndex = index);
    _addLog(
      type: BannerEventType.control,
      title: 'Jump to banner index $index requested',
      index: index,
      placeId: placeId,
    );
    try {
      await BannerPlaceManager.instance.showByIndex(
        placeId: placeId,
        index: index,
      );
    } catch (error) {
      _addLog(
        type: BannerEventType.control,
        title: 'Error navigating to index $index: $error',
      );
    }
  }

  Future<void> toggleAutoscroll() async {
    final placeId = _placeId;
    final nextPaused = !_isAutoscrollPaused;
    setState(() => _isAutoscrollPaused = nextPaused);
    _addLog(
      type: BannerEventType.control,
      title: nextPaused
          ? 'Pause autoscroll requested'
          : 'Resume autoscroll requested',
      placeId: placeId,
    );
    try {
      if (nextPaused) {
        await BannerPlaceManager.instance.pauseAutoscroll(placeId);
      } else {
        await BannerPlaceManager.instance.resumeAutoscroll(placeId);
      }
    } catch (error) {
      _addLog(
        type: BannerEventType.control,
        title: 'Error toggling autoscroll: $error',
      );
    }
  }

  Future<void> reloadBanners() async {
    final placeId = _placeId;
    _addLog(
      type: BannerEventType.control,
      title: 'Reload requested for place "$placeId"',
      placeId: placeId,
    );
    try {
      await BannerPlaceManager.instance.load(placeId);
    } catch (error) {
      _addLog(
        type: BannerEventType.control,
        title: 'Error reloading banners: $error',
      );
    }
  }

  Future<void> preloadBanners() async {
    final placeId = _placeId;
    _addLog(
      type: BannerEventType.control,
      title: 'Preload requested for place "$placeId"',
      placeId: placeId,
    );
    try {
      await BannerPlaceManager.instance.preloadBannerPlace(placeId);
    } catch (error) {
      _addLog(
        type: BannerEventType.control,
        title: 'Error preloading banners: $error',
      );
    }
  }

  void _clearLog() => setState(_events.clear);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banners')),
      body: _configured
          ? _buildContent(context)
          : const _SdkNotConfiguredWarning(),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBannerCarousel(),
          const SizedBox(height: 12),
          _buildControls(),
          const SizedBox(height: 12),
          _buildEventLog(context),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: BannerPlace(
            key: const Key('banner-place-widget'),
            placeId: _placeId,
            height: _bannerPlaceHeight,
            placeDecoration: BannerPlaceDecoration(
              bannerOffset: 16,
              bannersGap: 12,
              cornerRadius: 16,
              loop: true,
            ),
            bannerDecoration: BannerDecoration(
              color: Colors.grey.withValues(alpha: 0.15),
            ),
            onBannerPlaceLoaded: handleBannerPlaceLoaded,
            onBannerScroll: handleBannerScroll,
            onActionWith: handleActionWith,
          ),
        ),
        const SizedBox(height: 8),
        DotNavigationIndicator(
          key: const Key('dot-navigation-indicator'),
          count: _bannerCount,
          currentIndex: _currentIndex,
          onDotTapped: showByIndex,
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('banner-place-id-input'),
          controller: _placeIdController,
          decoration: const InputDecoration(
            labelText: 'Banner Place ID',
            hintText: 'e.g. banners, promo_place',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onSubmitted: (_) => reloadBanners(),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              key: const Key('prev-banner-button'),
              onPressed: showPrevious,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Prev'),
            ),
            ElevatedButton.icon(
              key: const Key('autoscroll-toggle-button'),
              onPressed: toggleAutoscroll,
              icon: Icon(
                _isAutoscrollPaused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                size: 18,
              ),
              label: Text(_isAutoscrollPaused ? 'Resume' : 'Pause Autoscroll'),
            ),
            OutlinedButton.icon(
              key: const Key('next-banner-button'),
              onPressed: showNext,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Next'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('reload-banners-button'),
                onPressed: reloadBanners,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reload'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('preload-banners-button'),
                onPressed: preloadBanners,
                icon: const Icon(Icons.download_for_offline, size: 18),
                label: const Text('Preload'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventLog(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Banner Event Log',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${_events.length}'),
              ],
            ),
            TextButton.icon(
              key: const Key('clear-banner-log-button'),
              onPressed: _events.isEmpty ? null : _clearLog,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Clear'),
            ),
          ],
        ),
        const Divider(),
        if (_events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No banner events logged yet',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          )
        else ...[
          for (var index = 0; index < _events.length; index++) ...[
            if (index > 0) const Divider(height: 16),
            _buildLogTile(context, _events[index]),
          ],
        ],
      ],
    );
  }

  Widget _buildLogTile(BuildContext context, BannerEventEntry item) {
    final (badgeColor, badgeLabel, badgeIcon) = switch (item.type) {
      BannerEventType.load => (
        Colors.green,
        'LOAD',
        Icons.check_circle_outline,
      ),
      BannerEventType.scroll => (Colors.blue, 'SCROLL', Icons.swipe),
      BannerEventType.action => (Colors.purple, 'ACTION', Icons.touch_app),
      BannerEventType.control => (Colors.orange, 'CONTROL', Icons.smart_button),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(badgeIcon, size: 14, color: badgeColor),
            const SizedBox(width: 6),
            Text(
              badgeLabel,
              style: TextStyle(
                color: badgeColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item.formattedTime,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        if (item.bannerId != null) Text('Banner ID: ${item.bannerId}'),
        if (item.placeId != null) Text('Place ID: ${item.placeId}'),
        if (item.data != null && item.data!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Data: ${item.data}',
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
      ],
    );
  }
}

class _SdkNotConfiguredWarning extends StatelessWidget {
  const _SdkNotConfiguredWarning();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
