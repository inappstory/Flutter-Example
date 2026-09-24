// TODO: fill these in with your InAppStory project values.
//const iasApiKey = '<your api key>';
const iasApiKey = '<your api key>';
const iasUserId =
    '<your user id>'; // empty = anonymous device; set a stable id per user

// =============================================================================
// Example Content IDs & Configuration
// =============================================================================

/// Story ID opened by the Single Story example ([SingleStoryScreen]).
const String iasSingleStoryId = '<single story id>';

/// Named user ID used in the User Change example ([UserChangeScreen]).
const String iasUserChangeUserId = '<demo id>';

/// Optional user signature for signed users in the User Change example.
const String? iasUserChangeUserSign = null;

/// In-App Message ID used in the IAM example ([InAppMessagesScreen]).
const String iasIamMessageId = '<message id>';

/// In-App Message event name used in the IAM example ([InAppMessagesScreen]).
const String iasIamEventName = '<event name>';

/// Banner Place ID used in the Banners example ([BannersScreen]).
const String iasBannerPlaceId = '<banner place id>';

/// Default story feed slug used across feed examples.
const String iasDefaultFeedSlug = '<default feed slug>';

/// Custom story feed slug used in the Multi-Feed example ([MultiFeedScreen]).
const String iasCustomFeedSlug = '<custom feed slug>';

/// Onboarding feed slug used in the Onboarding example ([OnboardingScreen]).
/// `null` defaults to the SDK default (`'onboarding'`).
const String iasOnboardingFeed = '<onboarding feed slug>';

// =============================================================================
// SDK Readiness Check
// =============================================================================

/// Whether the placeholder API key has been replaced with a real one.
///
/// Note: this is NOT an "SDK initialized" check. The plugin exposes no runtime
/// init flag; its documented readiness signal is the `initWith` Future itself
/// (gate widgets behind it, e.g. FutureBuilder). Here init is awaited in
/// `main()` before `runApp()`, so every screen already builds post-init — the
/// only thing left to catch is a developer who never set a real key, since
/// `initWith` does not throw on a placeholder/empty key.
bool get iasConfigured => iasApiKey.isNotEmpty && iasApiKey != '<your api key>';
