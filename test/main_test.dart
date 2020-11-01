import 'package:flash_chat/pages/ConversationPageSlide.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flash_chat/pages/RegisterPage.dart';
import 'package:flash_chat/main.dart';
import 'package:flash_chat/pages/ConversationPageSlide.dart';

void main() {
  testWidgets('Main UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(Messio());

    expect(find.byType(RegisterPage),findsOneWidget);

  });
}