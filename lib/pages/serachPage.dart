import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/config/style.dart';
import 'package:flash_chat/models/user.dart';
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

// ignore: camel_case_types
class searchScreen extends StatefulWidget {
  final String currentUser;

  searchScreen({
    Key key,
    this.currentUser,
  });
  @override
  _searchScreenState createState() =>
      _searchScreenState(currentUser: currentUser);
}

// ignore: camel_case_types
class _searchScreenState extends State<searchScreen> {
  TextEditingController searchTextController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;

  _searchScreenState({
    Key key,
    this.currentUser,
  });

  final String currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchFocusNode.requestFocus();
  }

  final FocusNode searchFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(104),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: statusBarHeight,
            ),
            AppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(35),
                ),
              ),
              automaticallyImplyLeading: false,
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.settings,
                      size: 30,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (value) => SettingScreen()));
                    }),
              ],
              backgroundColor: Colors.lightBlue[100],
              title: TextField(
                style: TextStyle(
                  fontSize: 18,
                ),
                controller: searchTextController,
                autofocus: true,
                focusNode: searchFocusNode,
                autocorrect: true,
                decoration: InputDecoration(
                  //fillColor: Colors.green

                  hintText: 'Type Text Here...',
                  hintStyle: TextStyle(color: Colors.grey),
                  // filled: true,
                  //fillColor: Colors.blue[100],
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.black54,
                    size: 30.0,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.black54,
                    ),
                    onPressed: emptyTextFormField(),
                  ),
                ),
                onSubmitted: controlSearching,
              ),
            ),
          ],
        ),
      ),
      body: futureSearchResults == null
          ? displayNoSearchResultScreen()
          : displayUserFoundScreen(),
    );
  }

  displayNoSearchResultScreen() {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      child: Center(
          child: Column(
        children: <Widget>[
          Center(
            child: Icon(
              Icons.group,
              color: Colors.amber,
              size: 100,
            ),
          ),
          Center(
            child: Text(
              "Search Users",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.normal,
                fontSize: 30,
              ),
            ),
          ),
        ],
      )),
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

        return ListView(
          children: searchUserResult,
        );
      },
    );
  }

  emptyTextFormField() {
    searchTextController.clear();
  }

  controlSearching(String userName) {
    Future<QuerySnapshot> allFoundUsers = Firestore.instance
        .collection("users")
        .where("nickname", isGreaterThanOrEqualTo: userName)
        .getDocuments();

    setState(() {
      futureSearchResults = allFoundUsers;
    });
  }
}
