import 'package:flutter/material.dart';
import 'ChatItemWidget.dart';

class ChatListWidget extends StatelessWidget {
  final ScrollController listScrollController = new ScrollController();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemBuilder: (context, index) =>
          ChatItemWidget(text: "This is a message", INT: index),
      itemCount: 20,
      reverse: true,
      controller: listScrollController,
    );
  }
}
