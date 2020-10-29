import 'package:flutter_test/flutter_test.dart';
import 'package:flash_chat/main.dart';
import 'package:flash_chat/pages/ConversationPageList.dart';

void main() {
  testWidgets('Main UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(Messio());

    expect(find.byType(ConversationPageList),findsOneWidget);

  });
}