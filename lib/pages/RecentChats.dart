import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/config/style.dart';
import 'package:flash_chat/models/user.dart';
import 'package:flash_chat/pages/AllUser.dart';
import 'package:flash_chat/pages/WhoLikedYou.dart';
import 'package:flash_chat/widgets/NavigationPillWIdget.dart';
import 'package:flash_chat/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/pages/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ConversationPageList.dart';
import 'package:intl/intl.dart';
import 'package:flash_chat/pages/ChatPage.dart';
import 'package:flash_chat/pages/UserResult.dart';
import 'package:google_fonts/google_fonts.dart';


class RecentChat extends StatefulWidget {
  final String currentUser;
  final bool first_entry;


  RecentChat({
    this.currentUser,
    this.first_entry,
  });
  @override
  _RecentChatState createState() =>
      _RecentChatState(currentUser: currentUser);
}

class _RecentChatState extends State<RecentChat> {
  TextEditingController searchTextController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;
  Future<QuerySnapshot> futureSearchResultsfirst;

  _RecentChatState({
    Key key,
    this.currentUser,

  });
  final String currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controlSearchingfirst();


  }
  bool oneSelected = true ;
  bool twoSelected = false;

  final FocusNode searchFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return MaterialApp(
      home: DefaultTabController(

        length: 2,
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(93),
              child: AppBar(
                backgroundColor: Colors.white,


                bottom: TabBar(
                  labelColor: Colors.blue,

                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(child: Text("Recent Chats",
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      letterSpacing: 1,
                      color: Colors.blue.shade900
                    ),
                    ),


                    ),
                    Tab(
                      child: Text("Who Liked You !!",
                        style: GoogleFonts.quicksand(
                            fontSize: 16,
                            letterSpacing: 1,
                            color: Colors.blue.shade900
                        ),
                      ),
                    ),

                  ],
                ),
                title: Text('TABS TITLE TEXT'),
              ),
            ),
            body: TabBarView(
              children: [
                futureSearchResults == null
                    ? displayNoUserResultScreen()
                    : displayUserFoundScreen(),

                WhoLikedYou(
                  currentUser: currentUser,
                )
              ],
            )



        ),
      ),
    );
  }

  displayNoUserResultScreen() {
    return FutureBuilder(
      future: futureSearchResultsfirst,
      builder: (context, datasnapshot) {
        if (!datasnapshot.hasData) {
          return  Center(
            child: Container(
                height: 110,
                width: 110,
                child:  CircularProgressIndicator(

                  strokeWidth: 1,
                )
            ),
          );
        }

        List<UserResult> searchUserResult = [];
        List a;
         bool isblocked ;
        datasnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(
              recent: true,
              eachUser: eachUser);

          a = eachUser.blockedto;

          print(a);
          if(a.contains(currentUser)){
            isblocked = true;
          }else{
            isblocked = false;
          }

          print(isblocked);

          if (currentUser != document["id"] && isblocked == false) {
            searchUserResult.add(userResult);
          }
        });

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 110,
              ),
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                mainAxisSpacing: 18,
                crossAxisSpacing: 8,
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: (2/2.9 ),

                children: searchUserResult,

              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        );

        // return Row(
        //   children: searchUserResult,
        // );
      },
    );
  }

  displayUserFoundScreen() {
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, datasnapshot) {
        if (!datasnapshot.hasData) {
          return  Center(
            child: Container(
                height: 110,
                width: 110,
                child:  CircularProgressIndicator(

                  strokeWidth: 1,
                )
            ),
          );
        }

        List<UserResult> searchUserResult = [];
        List a;
        bool isblocked;

        datasnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser: eachUser,
          recent: true,
          );

          a = eachUser.blockedto;

          print(a);
          if(a.contains(currentUser)){
            isblocked = true;
          }else{
            isblocked = false;
          }

          print(isblocked);

          if (currentUser != document["id"] && isblocked == false) {
            searchUserResult.add(userResult);
          }
        });

        return  SingleChildScrollView(
          child: Column(

            children: [
              SizedBox(
                height: 20,
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
              SizedBox(
                height: 20,
              )
            ],
          ),
        );
      },
    );
  }

  emptyTextFormField() {
    searchTextController.clear();
  }



  controlSearchingfirst() {

    Future<QuerySnapshot> allFoundUsers = Firestore.instance
        .collection("users")
        .where("activeChat" , arrayContains: currentUser)
        .getDocuments();




    setState(() {
      futureSearchResults = allFoundUsers;
    });

  }
}

