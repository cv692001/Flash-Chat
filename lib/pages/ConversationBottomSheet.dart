import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:share/share.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash_chat/pages/AllUser.dart';
import 'package:flash_chat/pages/BottomNavigation.dart';
import 'package:flash_chat/pages/RecentChats.dart';
import 'package:flash_chat/pages/serachPage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  _ConversationBottomSheetState({
    Key key,
    this.currentUser,
    this.first_entry,
  });
  final String currentUser;


  Future<QuerySnapshot> futureSearchResults;

  bool first;
  PageController _pageController;
  final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey(debugLabel: "Main Navigator");
  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    controlSearching();
    registerNotification();
    configLocalNotification();
    readDataFromLocal();
    _pageController = PageController();

    if (first_entry == false) {
      first = true;
    }
  }

  String applink =" Flash Chat !! ";

 List a;
  void readDataFromLocal() async {

    Firestore.instance.collection("applink").document("applink").get().then((value){
      print("link");
     print(value.data["link"]);

      applink = value.data["link"];
      setState(() {

      applink = applink;

      });
    });



    // print("check");
    // print(currentUser);




    setState(() {});
  }



  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) {
          print("onM essafew");
      print(message['notification']['title']);



          // Navigator.of(context, rootNavigator:true).push( // ensures fullscreen
          //     CupertinoPageRoute(
          //         builder: (BuildContext context) {
          //           return chat(
          //             recieverId: eachUser.id,
          //             recieverName: eachUser.nickname,
          //             recieverAvatar: eachUser.photourl,
          //             recieverAbout: eachUser.aboutMe,
          //             recieverAge: age11,
          //             isLiked : isLiked,
          //           );
          //         }
          //     ) );
          setState(() => selectedIndex = 2);
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      setState(() => selectedIndex = 2);
     // print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      setState(() => selectedIndex = 2);
   //   print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
     // print('token: $token');
      Firestore.instance
          .collection('users')
          .document(currentUser)
          .updateData({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('logo');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.aifly.flutterchatdemo'
          : 'com.aifly.flutterchatdemo',
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

 //   print(message);
//    print(message['body'].toString());
//    print(json.encode(message));

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));

//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
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


  DateTime currentBackPressTime;
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
                  color: Colors.yellow.shade800,
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

                        SettingScreen(
                          currentUser: currentUser,
                        )

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
                                    color: Colors.yellow.shade800,
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
                   selectedIndex == 3 ? Positioned(
                      right: 10,
                      top: statusBarHeight+3,
                      child: IconButton(icon: Icon(Icons.share,

                        color: Colors.blue.shade700,
                        ), onPressed:(){

                        Share.share(applink, subject: 'Look what I made!');

                      },

                      ),
                    ):Container(),
                  ],
                ),
              ),

          ),
        ));
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Double Tap to Exit !!");
      return Future.value(false);
    }
    return Future.value(true);
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
          List a;
          Firestore.instance.collection("users").document(currentUser).get().then((value) {
             a = value.data["blockedto"];
          });

          print(a);


            if (  !a.contains(document["id"])) {
              print("yoyoyoyoyooy");
            searchUserResult.add(userResult);
          }else{
              if(a.contains(document["id0"])){
                print("lnmiit");
                print(currentUser);
              }
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

