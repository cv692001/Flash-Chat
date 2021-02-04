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
import 'package:shared_preferences/shared_preferences.dart';
import 'serachPage.dart';
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
  int likes =0;

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



class UserResult extends StatefulWidget {
  final User eachUser;

  UserResult({
    @required this.eachUser,
  });
  @override
  _UserResultState createState() => _UserResultState(eachUser);
}

int likes =0;
class _UserResultState extends State<UserResult> {
  User eachUser;
  _UserResultState(
      this.eachUser,
      );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SharedPreferences preferences;



     likes = eachUser.likes;


  }


















  @override
  Widget build(BuildContext context) {

    Future<bool> onLikeButtonTapped(bool isLiked) async{
      /// send your request here
      // final bool success= await sendRequest();

      /// if failed, you can do nothing
      // return success? !isLiked:isLiked;

      isLiked ? likes-- : likes++;









      Firestore.instance.collection("users").document(eachUser.id).updateData({

        "likes": likes,
      });


      return !isLiked;
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => sendUserToChatPage(context),
            child: Card(

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(

                    height: 155 ,

                    width: MediaQuery.of(context).size.width/2,

                    child: CachedNetworkImage(
                      imageUrl: eachUser.photourl,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,


                          ),
                        ),
                      ),
                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                          Center(child: CircularProgressIndicator(value: downloadProgress.progress,
                            strokeWidth: 1.0,

                          )),
                      errorWidget: (context, url, error) => Icon(Icons.error),


                    ),



                    // Image.network(eachUser.photourl,fit: BoxFit.cover,
                    //   loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                    //     if (loadingProgress == null) return child;
                    //     return Center(
                    //       child: CircularProgressIndicator(
                    //         value: loadingProgress.expectedTotalBytes != null ?
                    //         loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                    //             : null,
                    //       ),
                    //     );
                    //   },
                    // ),



                    //                 child: Image.network(
                    //                   eachUser.photourl,
                    //                   loadingBuilder: (context,child,progress){
                    //                     return progress == null ? child:
                    //                     LinearProgressIndicator(
                    //                     backgroundColor: Colors.cyanAccent,
                    // valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                    // value: progress.dou,
                    // ),
                    //                 ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 10,top: 5,bottom: 4 ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                eachUser.nickname[0].toUpperCase() +
                                    eachUser.nickname.substring(1),
                                textAlign: TextAlign.left,
                                style: TextStyle(

                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                )
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    eachUser.aboutMe,
                                    style: TextStyle(
                                        color: Colors.orange
                                    )
                                ),


                              ],
                            ),

                          ],
                        ),
                        LikeButton(
                          onTap: onLikeButtonTapped,
                          //size: buttonSize,
                          circleColor:
                          CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
                          bubblesColor: BubblesColor(
                            dotPrimaryColor: Color(0xff33b5e5),
                            dotSecondaryColor: Color(0xff0099cc),
                          ),
                          likeBuilder: (bool isLiked) {
                            return Icon(
                              Icons.favorite,
                              color: isLiked ? Colors.deepOrange : Colors.grey,
                              size: 33,
                            );
                          },
                          likeCount: likes,
                          countBuilder: (int count, bool isLiked, String text) {
                            var color = isLiked ? Colors.deepOrange : Colors.grey;
                            Widget result;
                            if (count == 0) {
                              result = Text(
                                "0",
                                style: TextStyle(color: color),
                              );
                            } else
                              result = Text(
                                text,
                                style: TextStyle(color: color,
                                  fontSize: 8,
                                ),
                              );
                            return result;
                          },
                        ),
                      ],
                    ),
                  )



                ],
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 3,

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

