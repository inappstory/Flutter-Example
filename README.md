# InAppStory Flutter Example

This project demonstrates the basics of integrating and using the InAppStory SDK in a Flutter application. It includes examples for stories, reader customization, favorites, banners, in-app messages, and other SDK features.

Full documentation for the Flutter SDK is available in the [InAppStory documentation](https://docs.inappstory.com/sdk-guides/flutter/).

## Get Started

To run the example application:

1. Clone this repository and open the project directory.
2. Install Flutter dependencies:

	```sh
	flutter pub get
	```

3. Set your InAppStory integration key in [`lib/sdk/ias_config.dart`](lib/sdk/ias_config.dart). This file also contains IDs and other settings used by individual examples, such as story, feed, In-App Message, and banner placement IDs.
4. Run the application:

	```sh
	flutter run
	```

The Android host is configured to initialize the SDK natively. For iOS, Flutter installs the CocoaPods dependencies as part of the normal build; if needed, run `pod install` from the `ios/` directory after `flutter pub get`.

## Example Screens

- **Simple integration (Stories feed)** - displays a basic stories feed and opens the reader.
- **Cell customization** - customizes the appearance and layout of story cells.
- **Custom cell** - demonstrates a heavily customized story cell.
- **Single story** - opens a story by its ID.
- **Onboarding** - displays onboarding stories.
- **In-App Messaging (IAM)** - shows in-app messages by ID or event.
- **Custom GoodsWidget** - demonstrates a custom product widget in a story.
- **Favorites** - enables favorite stories and displays the favorites list.
- **Banners** - displays banners from a configured placement.
- **Multi-feed** - displays multiple story feeds.
- **User switching** - changes the active SDK user.
- **Tags & Placeholders** - demonstrates audience tags and content placeholders.
- **Reader customization** - customizes the story reader appearance and controls.
