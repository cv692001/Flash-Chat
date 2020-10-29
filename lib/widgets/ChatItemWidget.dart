import 'package:flutter/material.dart';
import 'package:flash_chat/config/color_palette.dart';
import 'package:intl/intl.dart';


class ChatItemWidget extends StatelessWidget {
  ChatItemWidget({
    @required this.text,
    @required this.INT,

  });


  final int INT;
  final String text;
  bool isME;
  
  bool Check(int INT){
    if ((INT%2) == 0 ){
      return true;
    }else {
      return false;
  }
  }
  


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      Check(INT) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment:
            Check(INT) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  DateFormat('dd MMM kk:mm')
                      .format(DateTime.fromMillisecondsSinceEpoch(1565888474278)),
                  style: TextStyle(
                      color: Palette.timeColor,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Material(
                borderRadius: Check(INT)
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
                color: Check(INT) ? Palette.selfMessageBackgroundColor : Palette.otherMessageBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Check(INT) ? Colors.white : Colors.black,
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




