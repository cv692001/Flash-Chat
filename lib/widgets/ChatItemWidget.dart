import 'package:flutter/material.dart';
import 'package:flash_chat/config/color_palette.dart';
import 'package:intl/intl.dart';
import 'package:flash_chat/config/style.dart';


class ChatItemWidget extends StatelessWidget {
  const ChatItemWidget({
    @required this.text,
    @required this.INT,
  });


  final int INT;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      INT%2==0 ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment:
            INT%2==0 ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  DateFormat('dd MMM kk:mm')
                      .format(DateTime.fromMillisecondsSinceEpoch(1565888474278)),
                  style: Styles.date,
                ),
              ),
              Material(
                borderRadius: INT%2==0
                    ? BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                )
                    : BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                elevation: 5,
                color: INT%2==0 ? Palette.selfMessageBackgroundColor : Palette.otherMessageBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: INT%2==0 ? Colors.white : Colors.black,
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




