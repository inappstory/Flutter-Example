import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example/main.dart';

void main() {
  testWidgets('InAppStoryExampleApp builds and displays start menu',
      (WidgetTester tester) async {
    await tester.pumpWidget(const InAppStoryExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('InAppStory Examples'), findsOneWidget);
    expect(find.text('Simple integration (Stories feed)'), findsOneWidget);
  });
}
