import 'dart:html';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RegisterPage.dart';
import 'package:flash_chat/widgets/NumberPicker.dart';
import 'package:flash_chat/config/style.dart';
import 'package:flash_chat/config/color_palette.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  SharedPreferences preferences;

  AnimationController usernameFieldAnimationController;
  Animation profilePicHeightAnimation,
      usernameAnimation,
      ageAnimation,
      picAnimation;
  FocusNode usernameFocusNode = FocusNode();
  var isKeyboardOpen = false;
  int age = 18;
  AnimationController controller;
  Animation animation;

  Alignment begin = Alignment.center;
  Alignment end = Alignment.bottomRight;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    usernameFieldAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    profilePicHeightAnimation =
        Tween(begin: 100.0, end: 0.0).animate(usernameFieldAnimationController)
          ..addListener(() {
            setState(() {});
          });
    usernameAnimation =
        Tween(begin: 30.0, end: 0.0).animate(usernameFieldAnimationController)
          ..addListener(() {
            setState(() {});
          });
    ageAnimation =
        Tween(begin: 80.0, end: 35.0).animate(usernameFieldAnimationController)
          ..addListener(() {
            setState(() {});
          });

    picAnimation =
        Tween(begin: 60.0, end: 45.0).animate(usernameFieldAnimationController)
          ..addListener(() {
            setState(() {});
          });

    usernameFocusNode.addListener(() {
      if (usernameFocusNode.hasFocus) {
        usernameFieldAnimationController.forward();
      } else {
        usernameFieldAnimationController.reverse();
      }
    });

    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });

    super.initState();

    readDataFromLocal();
  }

  TextEditingController nicknameTextEditingController = TextEditingController();
  TextEditingController aboutMeTextEditingController = TextEditingController();

  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photourl = "";
  File imageFileAvatar;
  bool isLoading = false;

  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();

    id = preferences.getString("id");
    nickname = preferences.getString("nickname");
    aboutMe = preferences.getString("aboutMe");
    photourl = preferences.getString("photourl");

    nicknameTextEditingController = TextEditingController(
      text: nickname,
    );

    aboutMeTextEditingController = TextEditingController(
      text: aboutMe,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.blue[600],
              Colors.blue[200],
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: profilePicHeightAnimation.value * .6),
            Container(
                child: Flexible(
              child: CircleAvatar(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.camera,
                      color: Colors.white,
                      size: 15,
                    ),
                    Text(
                      'Set Profile Picture',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    )
                  ],
                ),
                backgroundImage: Image.asset('images/user.jpg').image,
                radius: picAnimation.value,
              ),
            )),
            SizedBox(
              height: ageAnimation.value,
            ),
            Container(
              child: Text(
                'Choose a username',
                style: Styles.questionLight,
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              style: Styles.subHeadingLight,
              focusNode: usernameFocusNode,
              decoration: InputDecoration(
                hintText: '@username',
                hintStyle: Styles.hintTextLight,
                contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Palette.primaryColor, width: 0.1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Palette.primaryColor, width: 0.1),
                ),
              ),
            ),
            SizedBox(
              height: ageAnimation.value,
            ),
            Container(
              child: Text(
                'Choose a username',
                style: Styles.questionLight,
              ),
            ),
            TextField(
              textAlign: TextAlign.center,
              style: Styles.subHeadingLight,
              focusNode: usernameFocusNode,
              decoration: InputDecoration(
                hintText: '@username',
                hintStyle: Styles.hintTextLight,
                contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Palette.primaryColor, width: 0.1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Palette.primaryColor, width: 0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    usernameFieldAnimationController.dispose();
    usernameFocusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final value = MediaQuery.of(context).viewInsets.bottom;
    if (value > 0) {
      if (isKeyboardOpen) {
        onKeyboardChanged(false);
      }
      isKeyboardOpen = false;
    } else {
      isKeyboardOpen = true;
      onKeyboardChanged(true);
    }
  }

  onKeyboardChanged(bool isVisible) {
    if (!isVisible) {
      FocusScope.of(context).requestFocus(FocusNode());
      usernameFieldAnimationController.reverse();
    }
  }
}
