
import 'dart:math';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash_chat/pages/AllUser.dart';
import 'package:flash_chat/pages/BottomNavigation.dart';
import 'package:flash_chat/pages/RecentChats.dart';
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
import 'package:google_fonts/google_fonts.dart';
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
  PageController _pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controlSearching();
    _pageController = PageController();

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
  int selectedIndex=0;



  @override

  Widget build(BuildContext context) {
    List children = [
      AllUsers(
        currentUser: currentUser,
      ),
      searchScreen(
        currentUser: currentUser,
      ),
      RecentChat(
        currentUser: currentUser,
      ),

      SettingScreen()


    ];
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Material(
        child: WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            bottomNavigationBar: BottomNavyBar(

              backgroundColor: Colors.white,
              selectedIndex: selectedIndex,
              showElevation: true, // use this to remove appBar's elevation
              onItemSelected: (index) => setState(() {
                selectedIndex = index;
                _pageController.jumpToPage(index);

              }),



              items: <BottomNavyBarItem> [
                BottomNavyBarItem(
                  icon: Icon(Icons.flash_on_rounded,
                  color: Colors.red,
                  ),
                  title: Text('Flash Chat',
                    style: GoogleFonts.quicksand(
                      textStyle:  TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.normal
                      ),
                    )
                  ),
                  activeColor: Colors.blueAccent,
                ),
                BottomNavyBarItem(
                    icon: Icon(Icons.search,

                    color: Colors.blue.shade700,),
                    title: Text('   Search',
                      style: GoogleFonts.quicksand(
                        textStyle:  TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.normal

                        ),
                      )


                    ),
                    activeColor: Colors.blueAccent
                ),
                BottomNavyBarItem(
                    icon: Icon(Icons.message,
                    color: Colors.blue.shade700,
                    ),
                    title: Text('     Chat',
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.normal
                        ),
                      )


                    ),
                    activeColor: Colors.blueAccent
                ),
                BottomNavyBarItem(
                    icon: Icon(Icons.person,
                    color: Colors.blue.shade700,
                    ),
                    title: Text('    User ',
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            color: Colors.blue,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ),
                    activeColor: Colors.blueAccent
                ),
              ],
            ),

              backgroundColor: Colors.white,
              body: SizedBox.expand(
                child: Stack(
                  children: [
                    PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => selectedIndex = index);
                      },
                      children: <Widget>[
                        AllUsers(
                          currentUser: currentUser,
                        ),
                        searchScreen(
                          currentUser: currentUser,
                        ),
                        RecentChat(
                          currentUser: currentUser,
                        ),

                        SettingScreen()

                      ],
                    ),
                    Container(
                      decoration: new BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: selectedIndex == 1 || selectedIndex == 2 ? Colors.transparent: Colors.grey.withOpacity(0.3) ,
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],

                      ),
                      child: ListView(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Icon(
                                    Icons.flash_on_rounded,
                                    color: Colors.yellow.shade900,
                                    size: 30,
                                  ),
                                  Text('Flash Chat',
                                    style: GoogleFonts.quicksand(
                                        textStyle: TextStyle(
                                          fontSize: 22,
                                          letterSpacing: 3,
                                          color: Colors.black,

                                        )
                                    ),

                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

          ),
        ));
  }

  displayNoSearchResultScreen() {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return circularProgress();

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
              height: 70 ,
            ),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              mainAxisSpacing: 15,
              crossAxisSpacing: 8,
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: (2/3 ),

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

