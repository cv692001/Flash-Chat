import 'package:flutter/material.dart';
import 'package:rubber/rubber.dart';
import 'ConversationPage.dart';
import 'package:flash_chat/pages/ConversationBottomSheet.dart';
import 'package:flash_chat/widgets/InputWidget.dart';

class ConversationPageSlide extends StatefulWidget {
  final String currentUserId;

  ConversationPageSlide({
    Key key,
    @required this.currentUserId,
  }) : super(key: key);

  @override
  _ConversationPageSlideState createState() =>
      _ConversationPageSlideState(currentUserId: currentUserId);
}

class _ConversationPageSlideState extends State<ConversationPageSlide>
    with SingleTickerProviderStateMixin {
  _ConversationPageSlideState({
    Key key,
    this.currentUserId,
  });

  var controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final String currentUserId;

  @override
  void initState() {
    controller = RubberAnimationController(
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                children: <Widget>[
                  ConversationPage(),
                  ConversationPage(),
                  ConversationPage()
                ],
              ),
            ),
            Container(
              child: GestureDetector(
                child: InputWidget(),
                onPanUpdate: (details) {
                  if (details.delta.dy < 0) {
                    _scaffoldKey.currentState
                        .showBottomSheet<Null>((BuildContext context) {
                      return ConversationBottomSheet(
                        currentUser: currentUserId,
                      );
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
