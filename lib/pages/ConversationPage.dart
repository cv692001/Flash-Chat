import 'package:flash_chat/config/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/widgets/InputWidget.dart';
import 'package:flash_chat/widgets/ChatAppBar.dart';
import 'package:flash_chat/widgets/ChatListWidget.dart';
import 'package:flash_chat/pages/ConversationBottomSheet.dart';

class ConversationPage extends StatefulWidget {
  @override
  _ConversationPageState createState() => _ConversationPageState();
  const ConversationPage();
}

class _ConversationPageState extends State<ConversationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: ChatAppBar(),
        body: Container(
          color: Palette.chatBackgroundColor,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  ChatListWidget(),
                  GestureDetector(
                      child: InputWidget(),
                      onPanUpdate: (details) {
                        if (details.delta.dy <0) {
                          _scaffoldKey.currentState
                              .showBottomSheet<void>((BuildContext context) {
                            return ConversationBottomSheet();
                          }
                          );

                        }
                      })
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
