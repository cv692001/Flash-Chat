
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash_chat/pages/serachPage.dart';
import 'RegisterPage.dart';
import 'package:flash_chat/pages/UserResult.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';
import 'package:shimmer/shimmer.dart';
import 'package:like_button/like_button.dart';


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

  SharedPreferences preferences;



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
                backgroundColor: Colors.orange,
                curve: Curves.bounceInOut,
                // animatedIcon: AnimatedIcons.menu_close,

                animatedIcon: AnimatedIcons.menu_close,
                animatedIconTheme: IconThemeData(size: 22.0),


                overlayOpacity: 0.5,

                shape: CircleBorder(),
                children: [
                  SpeedDialChild(
                      onTap: () {
                        logoutUser();
                      },
                      child: Icon(
                        Icons.exit_to_app,
                        color: Colors.orange,
                      ),
                      label: "Log Out",
                      labelStyle: TextStyle(
                          color: Colors.deepOrange,
                          fontSize:15
                      ),

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
                        color: Colors.orange,
                      ),
                      label: "Your Profile",
                      labelStyle: TextStyle(
                          color: Colors.deepOrange,
                          fontSize:15
                      ),
                      backgroundColor: Colors.white),
                  SpeedDialChild(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.search,
                      color: Colors.orange,
                    ),
                    label: "Search User",
                    labelStyle: TextStyle(
                        color: Colors.deepOrange,
                        fontSize:15
                    ),
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
              body: Stack(
                children: [

                  SingleChildScrollView(
                    child: Column(children: <Widget>[

                      SizedBox(
                        height: 20,
                      ),
                      futureSearchResults == null
                          ? displayNoSearchResultScreen()
                          : displayUserFoundScreen(),
                    ]),
                  ),
                  Container(
                    decoration: new BoxDecoration(
                      color: Colors.orange,
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
                                        color: Colors.white
                                    ))),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              )

          ),
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
          children: [
            SizedBox(
              height: 70,
            ),
            GridView.count(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              crossAxisCount: 2,

              children: searchUserResult,

            ),
          ],
        );

        // return Row(
        //   children: searchUserResult,
        // );
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

