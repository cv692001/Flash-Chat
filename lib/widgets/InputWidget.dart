import 'package:flash_chat/pages/ConversationBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/config/color_palette.dart';

class InputWidget extends StatelessWidget {
  final TextEditingController textEditingController = TextEditingController();

  InputWidget();

  @override
  Widget build(BuildContext context) {
    return Material(
        elevation: 60.0,
        child: Container(
          child: Row(
            children: <Widget>[
              Material(
                child: new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 1.0),
                  child: new IconButton(
                    icon: new Icon(Icons.face),
                    color: Palette.accentColor,
                    // ignore: sdk_version_set_literal
                    onPressed: () => {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext bc) {
                            return Container(
                              child: ConversationBottomSheet(),
                            );
                          })
                    },
                  ),
                ),
                color: Colors.white,
              ),

              // Text input
              Flexible(
                child: Material(
                    child: Container(
                  child: TextField(
                    style: TextStyle(
                        color: Palette.primaryTextColor, fontSize: 15.0),
                    controller: textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type a message',
                      hintStyle: TextStyle(color: Palette.greyColor),
                    ),
                  ),
                )),
              ),

              // Send Message Button
              Material(
                child: new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 8.0),
                  child: new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: () => {},
                    color: Palette.accentColor,
                  ),
                ),
                color: Colors.white,
              ),
            ],
          ),
          width: double.infinity,
          height: 50.0,
          decoration: new BoxDecoration(
              border: new Border(
                  top: new BorderSide(color: Palette.greyColor, width: 0.5)),
              color: Colors.white),
        ));
  }
}
