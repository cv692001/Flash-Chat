import 'package:flutter/material.dart';
import 'ConversationPage.dart';

class ConversationPageList extends StatefulWidget {

  final String currentUserId;

  ConversationPageList({
    Key key,
    @required this.currentUserId,
}) : super (key : key);

  @override
  _ConversationPageListState createState() => _ConversationPageListState();

}

class _ConversationPageListState extends State<ConversationPageList> {
  @override
  Widget build(BuildContext context) {
    return PageView(
      children: <Widget>[
        ConversationPage(),
        ConversationPage(),
        ConversationPage(),

      ],

    );
  }
}

