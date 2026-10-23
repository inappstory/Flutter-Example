import 'package:flutter/material.dart';
import '../examples/banners_screen.dart';
import '../examples/cell_customization_screen.dart';
import '../examples/checkout_screen.dart';
import '../examples/custom_cell_screen.dart';
import '../examples/custom_goods_screen.dart';
import '../examples/favorites_screen.dart';
import '../examples/in_app_messages_screen.dart';
import '../examples/multi_feed_screen.dart';
import '../examples/onboarding_screen.dart';
import '../examples/reader_customization_screen.dart';
import '../examples/simple_integration_screen.dart';
import '../examples/single_story_screen.dart';
import '../examples/tags_placeholders_screen.dart';
import '../examples/user_change_screen.dart';

/// Represents a single selectable entry in the examples start menu.
class ExampleEntry {
  const ExampleEntry({required this.title, required this.builder});

  /// Human-readable title displayed in the menu list row.
  final String title;

  /// Builder returning the destination screen for this example.
  final WidgetBuilder builder;
}

/// Central registry of all InAppStory examples.
///
/// Each entry routes to its dedicated screen or, until implemented,
/// to a minimal placeholder screen.
final List<ExampleEntry> kExamples = [
  ExampleEntry(
    title: 'Simple integration (Stories feed)',
    builder: (context) => const SimpleIntegrationScreen(),
  ),
  ExampleEntry(
    title: 'Cell customization',
    builder: (context) => const CellCustomizationScreen(),
  ),
  ExampleEntry(
    title: 'Custom cell',
    builder: (context) => const CustomCellScreen(),
  ),
  ExampleEntry(
    title: 'Single story',
    builder: (context) => const SingleStoryScreen(),
  ),
  ExampleEntry(
    title: 'Onboarding',
    builder: (context) => const OnboardingScreen(),
  ),
  ExampleEntry(
    title: 'In-App Messaging (IAM)',
    builder: (context) => const InAppMessagesScreen(),
  ),
  ExampleEntry(
    title: 'Custom GoodsWidget',
    builder: (context) => const CustomGoodsScreen(),
  ),
  ExampleEntry(title: 'Checkout', builder: (context) => const CheckoutScreen()),
  ExampleEntry(
    title: 'Favorites',
    builder: (context) => const FavoritesScreen(),
  ),
  ExampleEntry(title: 'Banners', builder: (context) => const BannersScreen()),
  ExampleEntry(
    title: 'Multi-feed',
    builder: (context) => const MultiFeedScreen(),
  ),
  ExampleEntry(
    title: 'User switching',
    builder: (context) => const UserChangeScreen(),
  ),
  ExampleEntry(
    title: 'Tags & Placeholders',
    builder: (context) => const TagsPlaceholdersScreen(),
  ),
  ExampleEntry(
    title: 'Reader customization',
    builder: (context) => const ReaderCustomizationScreen(),
  ),
];
