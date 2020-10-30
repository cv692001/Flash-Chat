import 'package:flash_chat/config/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/widgets/ChatAppBar.dart';
import 'package:flash_chat/widgets/ChatListWidget.dart';


class ConversationPage extends StatefulWidget {
  @override
  _ConversationPageState createState() => _ConversationPageState();
  const ConversationPage();
}

class _ConversationPageState extends State<ConversationPage> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(flex: 2, child: ChatAppBar()),
        Expanded(
            flex: 11,
            child: Container(
              color: Palette.chatBackgroundColor,
              child: ChatListWidget(),
            ))
      ],
    );
  }
}
