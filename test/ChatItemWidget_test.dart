import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flash_chat/widgets/ChatItemWidget.dart';

void main(){
  const MaterialApp app = MaterialApp(
    home: Scaffold(
        body:  const ChatItemWidget()
    ),
  );
  testWidgets('ChatItemWidget UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(app);

    expect(find.byType(Container),findsNWidgets(0));
    expect(find.byType(Column),findsNWidgets(2));
    expect(find.byType(Row),findsNWidgets(0));
    expect(find.byType(Text),findsNWidgets(2));
  });
}