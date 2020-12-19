import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:flutter/material.dart';
import 'package:flash_chat/config/color_palette.dart';
import 'package:flash_chat/config/style.dart';
import 'package:flash_chat/widgets/ChatRowWidget.dart';
import 'package:flash_chat/widgets/NavigationPillWIdget.dart';
import 'package:flash_chat/pages/settings.dart';
import 'serachPage.dart';
import 'settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: camel_case_types
class centerChatPage extends StatefulWidget {
  final String currentUser;

  centerChatPage({
    Key key,
    this.currentUser,
  });
  @override
  _centerChatScreenState createState() =>
      _centerChatScreenState(currentUser: currentUser);
}

// ignore: camel_case_types
class _centerChatScreenState extends State<centerChatPage> {
  TextEditingController searchTextController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;

  _centerChatScreenState({
    Key key,
    this.currentUser,
  });

  final String currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchFocusNode.requestFocus();
    controlSearching();
  }

  final FocusNode searchFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        GestureDetector(
          onVerticalDragEnd: (details) {
            print('Dragged Down');
            if (details.primaryVelocity > 50) {
              Navigator.pop(context);
            }
          },
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      IconButton(
                        alignment: Alignment.bottomRight,
                        icon: Icon(Icons.search),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => searchScreen(
                                        currentUser: currentUser,
                                      )));
                        },
                      ),
                      IconButton(
                        alignment: Alignment.bottomRight,
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingScreen()));
                        },
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        futureSearchResults == null
            ? displayNoSearchResultScreen()
            : displayUserFoundScreen(),
      ],
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

        return ListView(
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

  sendUserToChatPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (value) => chat(
                  recieverId: eachUser.id,
                  recieverName: eachUser.nickname,
                  recieverAvatar: eachUser.photourl,
                )));
  }
}
