import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import '../sdk/ias_config.dart';

/// Categories of IAM events for logging and color-coding.
enum IamEventType {
  show,
  close,
  widgetEvent,
  action,
}

/// Represents a single recorded IAM event or action in the demonstration log.
class IamEventEntry {
  const IamEventEntry({
    required this.timestamp,
    required this.type,
    this.messageId,
    this.title,
    this.eventName,
    this.data,
  });

  final DateTime timestamp;
  final IamEventType type;
  final String? messageId;
  final String? title;
  final String? eventName;
  final Map<String, dynamic>? data;

  String get formattedTime =>
      '${timestamp.hour.toString().padLeft(2, '0')}:'
      '${timestamp.minute.toString().padLeft(2, '0')}:'
      '${timestamp.second.toString().padLeft(2, '0')}';
}

/// In-App Messaging (IAM) example screen.
///
/// Demonstrates:
/// - Triggering In-App Messages by Message ID ([InAppStoryManager.instance.showIAMById])
/// - Triggering In-App Messages by Event name ([InAppStoryManager.instance.showIAMByEvent])
/// - Preloading In-App Messages ([InAppStoryManager.instance.preloadInAppMessages])
/// - Limiting display to only preloaded messages (`onlyPreloaded: true`)
/// - Listening to IAM lifecycle and widget events via [IASInAppMessageCallback]
/// - Real-time event logging panel
///
class InAppMessagesScreen extends StatefulWidget {
  const InAppMessagesScreen({super.key, bool? configured})
      : _configuredOverride = configured;

  /// Overrides [iasConfigured] for testing; defaults to real SDK configuration.
  final bool? _configuredOverride;

  @override
  State<InAppMessagesScreen> createState() => _InAppMessagesScreenState();
}

class _InAppMessagesScreenState extends State<InAppMessagesScreen>
    with IASInAppMessageCallback {
  bool get _configured => widget._configuredOverride ?? iasConfigured;

  late final TextEditingController _idController;
  late final TextEditingController _eventController;

  bool _onlyPreloaded = false;
  final List<IamEventEntry> _events = [];

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: iasIamMessageId);
    _eventController = TextEditingController(text: iasIamEventName);
  }

  @override
  void dispose() {
    _idController.dispose();
    _eventController.dispose();
    super.dispose();
  }

  void _addLog({
    required IamEventType type,
    String? messageId,
    String? title,
    String? eventName,
    Map<String, dynamic>? data,
  }) {
    setState(() {
      _events.insert(
        0,
        IamEventEntry(
          timestamp: DateTime.now(),
          type: type,
          messageId: messageId,
          title: title,
          eventName: eventName,
          data: data,
        ),
      );
    });
  }

  // --- IASInAppMessageCallback overrides ---

  @override
  void onShowInAppMessage(InAppMessageDataDto? inAppMessageData) {
    _addLog(
      type: IamEventType.show,
      messageId: inAppMessageData?.id.toString(),
      title: inAppMessageData?.title,
      eventName: inAppMessageData?.event,
    );
  }

  @override
  void onCloseInAppMessage(InAppMessageDataDto? inAppMessageData) {
    _addLog(
      type: IamEventType.close,
      messageId: inAppMessageData?.id.toString(),
      title: inAppMessageData?.title,
      eventName: inAppMessageData?.event,
    );
  }

  @override
  void onInAppMessageWidgetEvent(
    InAppMessageDataDto? inAppMessageData,
    String? name,
    Map<String?, Object?>? data,
  ) {
    _addLog(
      type: IamEventType.widgetEvent,
      messageId: inAppMessageData?.id.toString(),
      title: inAppMessageData?.title,
      eventName: name,
      data: data?.map((k, v) => MapEntry(k ?? '', v)),
    );
  }

  // --- IAM Trigger Actions ---

  Future<void> _showById() async {
    final id = _idController.text.trim();
    if (id.isEmpty) return;

    _addLog(
      type: IamEventType.action,
      messageId: id,
      title: 'Show requested by ID (onlyPreloaded: $_onlyPreloaded)',
    );

    try {
      await InAppStoryManager.instance
          .showIAMById(
            id,
            onlyPreloaded: _onlyPreloaded,
          )
          .valueOrCancellation(false);
    } catch (e) {
      _addLog(
        type: IamEventType.action,
        messageId: id,
        title: 'Error showing IAM by ID: $e',
      );
    }
  }

  Future<void> _showByEvent() async {
    final event = _eventController.text.trim();
    if (event.isEmpty) return;

    _addLog(
      type: IamEventType.action,
      eventName: event,
      title: 'Show requested by Event (onlyPreloaded: $_onlyPreloaded)',
    );

    try {
      await InAppStoryManager.instance
          .showIAMByEvent(
            event,
            onlyPreloaded: _onlyPreloaded,
          )
          .valueOrCancellation(false);
    } catch (e) {
      _addLog(
        type: IamEventType.action,
        eventName: event,
        title: 'Error showing IAM by Event: $e',
      );
    }
  }

  Future<void> _preloadAll() async {
    _addLog(
      type: IamEventType.action,
      title: 'Preload all messages requested',
    );

    try {
      await InAppStoryManager.instance.preloadInAppMessages();
      _addLog(
        type: IamEventType.action,
        title: 'Preload all messages dispatched',
      );
    } catch (e) {
      _addLog(
        type: IamEventType.action,
        title: 'Error preloading all messages: $e',
      );
    }
  }

  Future<void> _preloadById() async {
    final id = _idController.text.trim();
    if (id.isEmpty) return;

    _addLog(
      type: IamEventType.action,
      messageId: id,
      title: 'Preload by ID requested',
    );

    try {
      await InAppStoryManager.instance.preloadInAppMessages(ids: [id]);
      _addLog(
        type: IamEventType.action,
        messageId: id,
        title: 'Preload by ID dispatched',
      );
    } catch (e) {
      _addLog(
        type: IamEventType.action,
        messageId: id,
        title: 'Error preloading by ID: $e',
      );
    }
  }

  void _clearLog() {
    setState(() {
      _events.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('In-App Messaging')),
      body: _configured
          ? _buildContent(context)
          : const _SdkNotConfiguredWarning(),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(context),
          const SizedBox(height: 16),
          _buildTriggerByIdCard(context),
          const SizedBox(height: 16),
          _buildTriggerByEventCard(context),
          const SizedBox(height: 16),
          _buildOptionsCard(context),
          const SizedBox(height: 16),
          _buildEventLogCard(context),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'In-App Messages (IAM)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Display targeted in-app popups, toasts, or modals triggered by direct Message ID or application events. Preload messages to ensure instant presentation.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerByIdCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Show by Message ID',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('iam-message-id-input'),
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Message ID',
                hintText: 'Enter numeric or string ID',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              key: const Key('show-iam-by-id-button'),
              onPressed: _showById,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Show by ID'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerByEventCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Show by Event Name',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('iam-event-name-input'),
              controller: _eventController,
              decoration: const InputDecoration(
                labelText: 'Event Name',
                hintText: 'e.g. test_event, on_login',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              key: const Key('show-iam-by-event-button'),
              onPressed: _showByEvent,
              icon: const Icon(Icons.bolt),
              label: const Text('Show by event'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Preloading & Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              key: const Key('only-preloaded-switch'),
              title: const Text('Only Preloaded'),
              subtitle: const Text(
                'Suppress display if message is not preloaded locally',
                style: TextStyle(fontSize: 12),
              ),
              value: _onlyPreloaded,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                setState(() {
                  _onlyPreloaded = val;
                });
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const Key('preload-all-button'),
                  onPressed: _preloadAll,
                  icon: const Icon(Icons.download),
                  label: const Text('Preload All'),
                ),
                OutlinedButton.icon(
                  key: const Key('preload-by-id-button'),
                  onPressed: _preloadById,
                  icon: const Icon(Icons.download_for_offline),
                  label: const Text('Preload Current ID'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventLogCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'IAM Event Log',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_events.length}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  key: const Key('clear-iam-log-button'),
                  onPressed: _events.isEmpty ? null : _clearLog,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const Divider(),
            if (_events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(
                    'No IAM events logged yet',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _events.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _events[index];
                  return _buildLogTile(context, item);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogTile(BuildContext context, IamEventEntry item) {
    Color badgeColor;
    String badgeLabel;
    IconData badgeIcon;

    switch (item.type) {
      case IamEventType.show:
        badgeColor = Colors.green;
        badgeLabel = 'SHOW';
        badgeIcon = Icons.visibility;
        break;
      case IamEventType.close:
        badgeColor = Colors.orange;
        badgeLabel = 'CLOSE';
        badgeIcon = Icons.close;
        break;
      case IamEventType.widgetEvent:
        badgeColor = Colors.purple;
        badgeLabel = 'WIDGET';
        badgeIcon = Icons.touch_app;
        break;
      case IamEventType.action:
        badgeColor = Colors.blue;
        badgeLabel = 'ACTION';
        badgeIcon = Icons.send;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      badgeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.formattedTime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (item.title != null)
            Text(
              item.title!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          if (item.messageId != null)
            Text(
              'Message ID: ${item.messageId}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[800],
              ),
            ),
          if (item.eventName != null)
            Text(
              'Event: ${item.eventName}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[800],
              ),
            ),
          if (item.data != null && item.data!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Data: ${item.data}',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Colors.grey[700],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shown when [iasConfigured] is false.
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
