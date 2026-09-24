import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

/// Resets InAppStory global SDK settings back to their documented defaults.
///
/// Restores:
/// - Targeting tags cleared (`setTags([])`)
/// - Text placeholders cleared (`setPlaceholders({})`)
/// - Options cleared (`setOptions({})`)
/// - Sound enabled (`changeSound(true)`)
/// - Cached content cleared (`clearCache()`)
/// - Appearance manager styling restored to defaults
///
/// Thrown exceptions are caught and logged so that callers are never blocked.
Future<void> resetInAppStory() async {
  try {
    final ias = InAppStoryManager.instance;
    await ias.setTags([]);
    await ias.setPlaceholders({});
    await ias.setOptions({});
    await ias.changeSound(true);
    await ias.clearCache();

    final appearance = AppearanceManager.instance;
    await appearance.setHasFavorites(false);
    await appearance.setHasLike(false);
    await appearance.setHasShare(false);
    await appearance.setReaderBackgroundColor(const Color(0xFF000000));
    await appearance.setReaderCornerRadius(0);
    await appearance.setClosePosition(Position.topRight);
    await appearance.setReaderScrollStyle(ScrollStyle.flat);
    await appearance.setReaderPresentationStyle(PresentationStyle.modal);
    await appearance.setCoverQuality(CoverQuality.Medium);
  } catch (error, stackTrace) {
    developer.log(
      'Failed to reset InAppStory SDK settings',
      name: 'resetInAppStory',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
