import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/config/style.dart';
import 'package:flash_chat/pages/RegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/config/color_palette.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height = 80;
  @override
  Widget build(BuildContext context) {
    Future<Null> logoutUser() async {
      await FirebaseAuth.instance.signOut();
      await googleSignIn.disconnect();
      await googleSignIn.signOut();

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => RegisterPage()),
          (Route<dynamic> route) => false);
    }

    return Material(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: kElevationToShadow[5],
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
                        child: GestureDetector(
                          onTap: logoutUser,
                          child: Center(
                            child: Icon(
                              Icons.close,
                              color: Palette.secondaryColor,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('Chirag Vaishnav',
                                  style: Styles.textHeading),
                            ],
                          ),
                        ),
                      ),
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
                      backgroundImage: AssetImage('images/user.jpg'),
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

  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  Size get preferredSize => Size.fromHeight(height);
}
