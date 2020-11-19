import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flash_chat/config/style.dart';

class ChatRowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          padding: EdgeInsets.fromLTRB(15, 5, 0, 5),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('images/user.jpg'),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Container(
                        child: Column(
                      children: <Widget>[
                        Text('Chirag Vaishnav', style: Styles.subHeading),
                        Text(
                          'What\'s up?',
                          style: Styles.subText,
                        )
                      ],
                    ))
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      DateFormat('kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(1565888474278)),
                      style: Styles.date,
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}
