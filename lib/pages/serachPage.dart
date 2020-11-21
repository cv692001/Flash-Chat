import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/models/user.dart';
import 'package:flash_chat/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/pages/settings.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.settings,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (value) => SettingScreen()));
              }),
        ],
        backgroundColor: Colors.lightBlue,
        title: Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
          child: TextField(
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
            controller: searchTextController,
            autofocus: true,
            focusNode: searchFocusNode,
            autocorrect: true,
            decoration: InputDecoration(
              hintText: 'Type Text Here...',
              hintStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white70,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.white),
              ),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.black87,
                size: 30.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.black87,
                ),
                onPressed: emptyTextFormField(),
              ),
            ),
            onSubmitted: controlSearching,
          ),
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
        child: ListView(
          children: <Widget>[
            Icon(
              Icons.group,
              color: Colors.grey,
              size: 150,
            ),
            Text(
              "Search Users",
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
            print("not same");
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
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: CachedNetworkImageProvider(eachUser.photourl),
              ),
              title: Text(
                eachUser.nickname,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "joined" +
                    DateFormat("dd MMMM, yyyy - hh:mm:ss").format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(eachUser.createdAt))),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
