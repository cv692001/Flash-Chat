import 'package:flutter/material.dart';
import 'pages/ConversationPageList.dart';
import 'package:flash_chat/pages/ConversationPageSlide.dart';
import 'package:flash_chat/pages/ConversationBottomSheet.dart';
import 'package:flash_chat/pages/ConversationPage.dart';
import 'config/color_palette.dart';
import 'package:flash_chat/pages/RegisterPage.dart';

void main() => runApp(Messio());

class Messio extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RegisterPage(),
    );
  }
}

