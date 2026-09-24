import 'package:flutter/material.dart';
import '../sdk/reset_inappstory.dart';
import 'example_entry.dart';

/// The start screen displaying the catalog of InAppStory examples.
class ExamplesMenuScreen extends StatefulWidget {
  const ExamplesMenuScreen({super.key, this.entries, this.onReset});

  /// Optional list of example entries to display; defaults to [kExamples].
  final List<ExampleEntry>? entries;

  /// Optional reset callback; defaults to [resetInAppStory].
  final Future<void> Function()? onReset;

  @override
  State<ExamplesMenuScreen> createState() => _ExamplesMenuScreenState();
}

class _ExamplesMenuScreenState extends State<ExamplesMenuScreen> {
  late final List<ExampleEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = widget.entries ?? kExamples;
    _runReset();
  }

  Future<void> _runReset() async {
    try {
      if (widget.onReset != null) {
        await widget.onReset!();
      } else {
        await resetInAppStory();
      }
    } catch (_) {
      // Best-effort: errors are swallowed so the menu remains navigable.
    }
  }

  Future<void> _onExampleTap(ExampleEntry entry) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: entry.builder));
    if (mounted) {
      await _runReset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InAppStory Examples')),
      body: ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          return ListTile(
            title: Text(entry.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _onExampleTap(entry),
          );
        },
      ),
    );
  }
}
