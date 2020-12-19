import 'package:flutter/material.dart';
import 'package:flash_chat/config/color_palette.dart';
import 'package:intl/intl.dart';
import 'package:flash_chat/config/style.dart';

class ChatItemWidget extends StatelessWidget {
  const ChatItemWidget({
    @required this.text,
    // ignore: non_constant_identifier_names
    @required this.INT,
  });

  // ignore: non_constant_identifier_names
  final int INT;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          INT % 2 == 0 ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Material(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
                elevation: 5,
                color: Palette.selfMessageBackgroundColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Material(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
                elevation: 5,
                color: Palette.otherMessageBackgroundColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
