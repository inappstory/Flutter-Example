import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example/sdk/reset_inappstory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('resetInAppStory (User Story 2)', () {
    test('completes gracefully without throwing uncaught exceptions', () async {
      // In a pure unit test environment without real native channel responses,
      // resetInAppStory catches errors internally, logs them, and returns cleanly.
      expect(resetInAppStory(), completes);
    });
  });
}
