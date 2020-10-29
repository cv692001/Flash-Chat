import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flash_chat/config/assets.dart';
import 'package:flash_chat/config/color_palette.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget{
  final double height = 80;
  const ChatAppBar();
  @override
  Widget build(BuildContext context) {
    var textHeading = TextStyle(color: Palette.primaryTextColor,fontSize: 20,);
    var textStyle = TextStyle(color: Palette.secondaryTextColor);

    return Material(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius : 5.0,
            )
          ]
        ),
        child: Container(
          color: Palette.primaryBackgroundColor,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Center(
                  child: Row(
                    children: <Widget>[

                      Expanded(
                          flex: 2,
                          child: Center(
                              child: Icon(
                                Icons.attach_file,
                                color: Palette.secondaryColor,
                              ),),),
                      Expanded(
                          flex: 6,
                          child: Container(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text('Chirag Vaishnav', style: textHeading),
                                ],
                              ),),),

                    ],
                  ),
                ),
              ),
          Expanded(
            flex: 3,
            child: Container(
              child: Center(
                child: CircleAvatar(
                radius: 30,
                  backgroundImage: AssetImage('images/user.jpg')
                ),
              ),
            ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
