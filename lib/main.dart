import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'menu/examples_menu_screen.dart';
import 'sdk/ias_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InAppStoryPlugin().initWith(
    iasApiKey,
    iasUserId,
    anonymous: iasUserId.isEmpty,
  );
  runApp(const InAppStoryExampleApp());
}

class InAppStoryExampleApp extends StatelessWidget {
  const InAppStoryExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InAppStory Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExamplesMenuScreen(),
    );
  }
}
