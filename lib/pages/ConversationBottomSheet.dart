import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'RegisterPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/models/user.dart';
import 'package:flash_chat/widgets/ProgressWidget.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/config/color_palette.dart';
import 'package:flash_chat/config/style.dart';
import 'package:flash_chat/widgets/ChatRowWidget.dart';
import 'package:flash_chat/widgets/NavigationPillWIdget.dart';
import 'package:flash_chat/pages/settings.dart';
import 'package:intl/intl.dart';
import 'serachPage.dart';
import 'settings.dart';

import 'package:flash_chat/pages/ChatPage.dart';

class ConversationBottomSheet extends StatefulWidget {
  final String currentUser;
  final bool first_entry;

  ConversationBottomSheet({
    this.currentUser,
    this.first_entry,
  });
  @override
  _ConversationBottomSheetState createState() =>
      _ConversationBottomSheetState(currentUser: currentUser);
}

class _ConversationBottomSheetState extends State<ConversationBottomSheet> {
  TextEditingController searchTextController = TextEditingController();

  final bool first_entry;

  _ConversationBottomSheetState({
    Key key,
    this.currentUser,
    this.first_entry,
  });
  final String currentUser;

  Future<QuerySnapshot> futureSearchResults;

  bool first;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controlSearching();
    if (first_entry == false) {
      first = true;
    }
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => RegisterPage()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Material(
        child: WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          floatingActionButton: SpeedDial(
            backgroundColor: Colors.blue[100],
            curve: Curves.bounceInOut,
            animatedIcon: AnimatedIcons.menu_close,
            overlayOpacity: 0.5,
            animatedIconTheme: IconThemeData.fallback(),
            shape: CircleBorder(),
            children: [
              SpeedDialChild(
                  onTap: () {
                    logoutUser();
                  },
                  child: Icon(
                    Icons.exit_to_app,
                    color: Colors.black38,
                  ),
                  label: "Log Out",
                  backgroundColor: Colors.white),
              SpeedDialChild(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingScreen()));
                  },
                  child: Icon(
                    Icons.settings,
                    color: Colors.black38,
                  ),
                  label: "Your Profile",
                  backgroundColor: Colors.white),
              SpeedDialChild(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.search,
                  color: Colors.black38,
                ),
                label: "Search User",
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => searchScreen(
                                currentUser: currentUser,
                              )));
                },
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: Column(children: <Widget>[
            Container(
              decoration: new BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(
                        MediaQuery.of(context).size.width, 90.0)),
              ),
              child: ListView(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                children: <Widget>[
                  NavigationPillWidget(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                          child: Text('Messages',
                              style: TextStyle(
                                fontSize: 22,
                              ))),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            futureSearchResults == null
                ? displayNoSearchResultScreen()
                : displayUserFoundScreen(),
          ])),
    ));
  }

  displayNoSearchResultScreen() {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      child: Center(
        child: ListView(
          children: <Widget>[
            Icon(
              Icons.group,
              color: Colors.grey,
              size: 150,
            ),
            Text(
              "Welcome To Flash Chat",
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontWeight: FontWeight.w500,
                fontSize: 50,
              ),
            )
          ],
        ),
      ),
    );
  }

  displayUserFoundScreen() {
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, datasnapshot) {
        if (!datasnapshot.hasData) {
          return circularProgress();
        }

        List<UserResult> searchUserResult = [];

        datasnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser: eachUser);

          if (currentUser != document["id"]) {
            searchUserResult.add(userResult);
          }
        });

        return Column(
          children: searchUserResult,
        );
      },
    );
  }

  emptyTextFormField() {
    searchTextController.clear();
  }

  controlSearching() {
    Future<QuerySnapshot> allFoundUsers = Firestore.instance
        .collection("users")
        .where("nickname", isGreaterThan: "")
        .getDocuments();

    setState(() {
      futureSearchResults = allFoundUsers;
    });
  }
}

class UserResult extends StatelessWidget {
  final User eachUser;

  UserResult({
    @required this.eachUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => sendUserToChatPage(context),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage:
                        CachedNetworkImageProvider(eachUser.photourl),
                    radius: 30,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                        eachUser.nickname[0].toUpperCase() +
                            eachUser.nickname.substring(1),
                        style: Styles.text),
                  ),
                  subtitle: Text(
                    "joined " +
                        DateFormat("dd MM yyyy - hh:mm").format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(eachUser.createdAt))),
                    style: Styles.subText,

                    // ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 70, vertical: 0),
                  child: Divider(
                    color: Colors.black12,
                    thickness: 1.3,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  sendUserToChatPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (value) => chat(
                  recieverId: eachUser.id,
                  recieverName: eachUser.nickname,
                  recieverAvatar: eachUser.photourl,
                  recieverAbout: eachUser.aboutMe,
                )));
  }
}
