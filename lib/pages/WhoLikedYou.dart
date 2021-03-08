import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/config/style.dart';
import 'package:flash_chat/models/user.dart';
import 'package:flash_chat/widgets/NavigationPillWIdget.dart';
import 'package:flash_chat/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/pages/settings.dart';
import 'ConversationPageList.dart';
import 'package:intl/intl.dart';
import 'package:flash_chat/pages/ChatPage.dart';
import 'package:flash_chat/pages/UserResult.dart';
import 'package:google_fonts/google_fonts.dart';


class WhoLikedYou extends StatefulWidget {
  final String currentUser;
  final bool first_entry;

  WhoLikedYou({
    this.currentUser,
    this.first_entry,
});
  @override
  _WhoLikedYouState createState() => _WhoLikedYouState(
    currentUser: currentUser,
  );
}

class _WhoLikedYouState extends State<WhoLikedYou> {
  TextEditingController searchTextController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;
  Future<QuerySnapshot> futureSearchResultsfirst;


  _WhoLikedYouState({
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

  final FocusNode searchFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(

        body: Stack(
          children: [
            futureSearchResults == null
                ? displayNoUserResultScreen()
                : displayUserFoundScreen(),


          ],
        )



    );
  }

  displayNoUserResultScreen() {
    return FutureBuilder(
      future: futureSearchResultsfirst,
      builder: (context, datasnapshot) {
        if (!datasnapshot.hasData) {
          return Center(
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
          UserResult userResult = UserResult(
                           eachUser: eachUser,
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

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
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
          return circularProgress();
        }

        List<UserResult> searchUserResult = [];
        bool isblocked;
        List a;


        datasnapshot.data.documents.forEach((document) {
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser: eachUser
          ,recent: true,
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
                height: 110,
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

  controlSearching(String userName) {

    Future<QuerySnapshot> allFoundUsersfirst =


    Firestore.instance
        .collection("users")
        .where("nickname", isGreaterThanOrEqualTo: "" ).getDocuments();

    Future<QuerySnapshot> allFoundUsers =


    Firestore.instance
        .collection("users")
        .where("nickname", isGreaterThanOrEqualTo: userName ).getDocuments();

    setState(() {
      futureSearchResultsfirst = allFoundUsersfirst;
      futureSearchResults = allFoundUsers;
    });
  }

  controlSearchingfirst() {

    Future<QuerySnapshot> allFoundUsersfirst =


    Firestore.instance
        .collection("users")
        .where("likedto", arrayContains: currentUser ).getDocuments();



    setState(() {
      futureSearchResultsfirst = allFoundUsersfirst;

    });
  }
}
