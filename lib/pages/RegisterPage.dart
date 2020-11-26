import 'dart:ffi';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/widgets/CircleIndicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/config/color_palette.dart';
import 'package:flash_chat/config/style.dart';
import 'package:flash_chat/config/Transitions.dart';
import 'package:flash_chat/pages/ConversationPageSlide.dart';
import 'package:flash_chat/widgets/NumberPicker.dart';
import 'package:flash_chat/widgets/ProgressWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final GoogleSignIn googledignin = GoogleSignIn();
  final FirebaseAuth firebaseauth = FirebaseAuth.instance;
  SharedPreferences preferences;
  bool isLoggedIn = false;
  bool isLoading = false;
  FirebaseUser currentuser;

  int currentPage = 0;
  int age = 18;
  var isKeyboardOpen =
      false; //this variable keeps track of the keyboard, when its shown and when its hidden

  PageController pageController =
      PageController(); // this is the controller of the page. This is used to navigate back and forth between the pages

  //Fields related to animation of the gradient
  Alignment begin = Alignment.center;
  Alignment end = Alignment.bottomRight;

  //Fields related to animating the layout and pushing widgets up when the focus is on the username field
  AnimationController usernameFieldAnimationController;
  Animation profilePicHeightAnimation,
      usernameAnimation,
      ageAnimation,
      picAnimation;
  FocusNode usernameFocusNode = FocusNode();

  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    usernameFieldAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    profilePicHeightAnimation =
        Tween(begin: 100.0, end: 0.0).animate(usernameFieldAnimationController)
          ..addListener(() {
            setState(() {});
          });
    usernameAnimation =
        Tween(begin: 30.0, end: 0.0).animate(usernameFieldAnimationController)
          ..addListener(() {
            setState(() {});
          });
    ageAnimation =
        Tween(begin: 80.0, end: 0.0).animate(usernameFieldAnimationController)
          ..addListener(() {
            setState(() {});
          });

    picAnimation =
        Tween(begin: 60.0, end: 45.0).animate(usernameFieldAnimationController)
          ..addListener(() {
            setState(() {});
          });

    usernameFocusNode.addListener(() {
      if (usernameFocusNode.hasFocus) {
        usernameFieldAnimationController.forward();
      } else {
        usernameFieldAnimationController.reverse();
      }
    });
    pageController.addListener(
      () {
        setState(() {
          begin = Alignment(pageController.page, pageController.page);
          end = Alignment(1 - pageController.page, 1 - pageController.page);
        });
      },
    );

    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });

    super.initState();

    isSignedIn();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoggedIn = true;
    });

    preferences = await SharedPreferences.getInstance();

    isLoggedIn = await googledignin.isSignedIn();
    if (isLoggedIn) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationPageSlide(
                  currentUserId: preferences.getString("id"))));
    }

    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onWillPop, //user to override the back button press
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          //  avoids the bottom overflow warning when keyboard is shown
          body: SafeArea(
              child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(begin: begin, end: end, colors: [
                    Colors.lightBlue,
                    Palette.gradientEndColor
                  ])),
                  child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: <Widget>[
                        AnimatedContainer(
                            duration: Duration(milliseconds: 1500),
                            child: PageView(
                                controller: pageController,
                                physics: NeverScrollableScrollPhysics(),
                                onPageChanged: (int page) =>
                                    updatePageState(page),
                                children: <Widget>[
                                  buildPageOne(),
                                  buildPageTwo()
                                ])),
                        Container(
                          margin: EdgeInsets.only(bottom: 30),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              for (int i = 0; i < 2; i++)
                                CircleIndicator(i == currentPage),
                            ],
                          ),
                        ),
                        AnimatedOpacity(
                            opacity: currentPage == 1
                                ? 1.0
                                : 0.0, //shows only on page 1
                            duration: Duration(milliseconds: 500),
                            child: Container(
                                margin: EdgeInsets.only(right: 20, bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    FloatingActionButton(
                                      onPressed: () => navigateToHome(),
                                      elevation: 0,
                                      backgroundColor: Palette.primaryColor,
                                      child: Icon(
                                        Icons.done,
                                        color: Palette.accentColor,
                                      ),
                                    )
                                  ],
                                )))
                      ]))),
        ));
  }

  buildPageOne() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  //margin: EdgeInsets.only(top: 150),
                  child: Image.asset('images/launcher/logo.png',
                      height: controller.value * 130)),
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Container(
                    margin: EdgeInsets.only(top: 35),
                    child: Text('Flash Chat',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            fontSize: 30))),
              ),
            ],
          ),
          Container(
              margin: EdgeInsets.only(top: 125),
              child: ButtonTheme(
                  height: 40,
                  child: FlatButton.icon(
                      onPressed: () => controlSignIn(),
                      color: Colors.transparent,
                      icon: Image.asset(
                        'images/google.png',
                        height: 28,
                      ),
                      label: Text(
                        'Sign In with Google',
                        style: TextStyle(
                            color: Palette.primaryTextColorLight,
                            fontWeight: FontWeight.w800),
                      )))),
          Padding(
            padding: EdgeInsets.all(8),
            child: isLoading ? circularProgress() : Container(),
          )
        ],
      ),
    );
  }

  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photourl = "";
  File imageFileAvatar;
  TextEditingController nicknameTextEditor = TextEditingController();

  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();

    id = preferences.getString("id");

    aboutMe = preferences.getString("aboutMe");
    photourl = preferences.getString("photourl");

    setState(() {});
  }

  Future getImage() async {
    File newImageFile =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    if (newImageFile != null) {
      setState(() {
        this.imageFileAvatar = newImageFile;
        isLoading = true;
      });
    }

    uploadImageToFireStoreAndStorage();
  }

  Future uploadImageToFireStoreAndStorage() async {
    String mFileName = id;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(mFileName);

    StorageUploadTask storageUplaodTask =
        storageReference.putFile(imageFileAvatar);

    StorageTaskSnapshot storageTaskSnapshot;

    storageUplaodTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;

        storageTaskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
          photourl = newImageDownloadUrl;

          Firestore.instance.collection("users").document(id).updateData({
            "photourl": photourl,
          }).then((data) async {
            await preferences.setString("photourl", newImageDownloadUrl);

            setState(() {
              isLoading = false;
            });

            Fluttertoast.showToast(msg: "Updated Sucessfully");
          });
        }, onError: (errormsg) {
          setState(() {
            isLoading = false;
          });

          Fluttertoast.showToast(msg: "Error occured in getting DownloadUrl");
        });
      }
    }, onError: (errorMsg) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: errorMsg.toString());
    });
  }

  buildPageTwo() {
    readDataFromLocal();
    return InkWell(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: profilePicHeightAnimation.value * .3),
              Container(
                  child: Flexible(
                child: GestureDetector(
                  onTap: () {
                    getImage();
                  },
                  child: CircleAvatar(
                    child: Stack(
                      children: <Widget>[
                        (imageFileAvatar == null)
                            ? (photourl != null)
                                ? Material(
                                    // display the old image
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) => Container(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.lightBlueAccent),
                                          strokeWidth: 2.0,
                                        ),
                                        height: 200,
                                        width: 200,
                                        padding: EdgeInsets.all(20.0),
                                      ),
                                      imageUrl: photourl,
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(125.0)),
                                    clipBehavior: Clip.hardEdge,
                                  )
                                : Icon(
                                    Icons.account_circle,
                                    size: 90,
                                    color: Colors.grey,
                                  )
                            : Material(
                                child: Image.file(
                                  imageFileAvatar,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(125.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                        IconButton(
                          icon: Icon(
                            Icons.camera,
                            size: 50,
                            color: Colors.white54.withOpacity(0.3),
                          ),
                          onPressed: () {
                            getImage();
                          },
                          padding: EdgeInsets.all(0.0),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.grey,
                          iconSize: 200,
                        ),
                        isLoading ? circularProgress() : Container(),
                      ],
                    ),
                    radius: picAnimation.value,
                  ),
                ),
              )),
              SizedBox(
                height: ageAnimation.value,
              ),
              Text(
                'How old are you?',
                style: Styles.questionLight,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  NumberPicker.horizontal(
                      initialValue: age,
                      minValue: 15,
                      maxValue: 100,
                      highlightSelectedValue: true,
                      onChanged: (num value) {
                        setState(() {
                          age = value;
                        });
                        //   print(age);
                      }),
                  Text('Years', style: Styles.textLight)
                ],
              ),
              SizedBox(
                height: usernameAnimation.value,
              ),
              Container(
                child: Text(
                  'Choose a username',
                  style: Styles.questionLight,
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 20),
                  width: 120,
                  child: TextField(
                    controller: nicknameTextEditor,
                    textAlign: TextAlign.center,
                    style: Styles.subHeadingLight,
                    focusNode: usernameFocusNode,
                    decoration: InputDecoration(
                      hintText: '@username',
                      hintStyle: Styles.hintTextLight,
                      contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Palette.primaryColor, width: 0.1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Palette.primaryColor, width: 0.1),
                      ),
                    ),
                  ))
            ],
          ),
        ));
  }

  updatePageState(index) {
    if (index == 1)
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);

    setState(() {
      currentPage = index;
    });
  }

  Future<bool> onWillPop() {
    if (currentPage == 1) {
      //go to first page if currently on second page

      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    usernameFieldAnimationController.dispose();
    usernameFocusNode.dispose();
    controller.dispose();
    super.dispose();
    isLoading = false;
  }

  ///
  /// This routine is invoked when the window metrics have changed.
  ///
  @override
  void didChangeMetrics() {
    final value = MediaQuery.of(context).viewInsets.bottom;
    if (value > 0) {
      if (isKeyboardOpen) {
        onKeyboardChanged(false);
      }
      isKeyboardOpen = false;
    } else {
      isKeyboardOpen = true;
      onKeyboardChanged(true);
    }
  }

  onKeyboardChanged(bool isVisible) {
    if (!isVisible) {
      FocusScope.of(context).requestFocus(FocusNode());
      usernameFieldAnimationController.reverse();
    }
  }

  navigateToHome() {
    usernameFocusNode.unfocus();

    setState(() {
      isLoading = false;
    });

    Firestore.instance.collection("users").document(id).updateData({
      "age": age.toString(),
      "nickname": nicknameTextEditor.text,
    }).then((data) async {
      await preferences.setString("nickname", nicknameTextEditor.text);
      await preferences.setString("age", age.toString());

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Updated Sucessfully");
    });

    Navigator.push(
      context,
      SlideLeftRoute(
          page: ConversationPageSlide(
        currentUserId: preferences.getString("id"),
      )),
    );
  }

  Future<Null> controlSignIn() async {
    preferences = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googledignin.signIn();
    GoogleSignInAuthentication googleAuthentication =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      idToken: googleAuthentication.idToken,
      accessToken: googleAuthentication.accessToken,
    );

    FirebaseUser firebaseUser =
        (await firebaseauth.signInWithCredential(credential)).user;

    //signin success
    if (firebaseUser != null) {
      final QuerySnapshot resultQuery = await Firestore.instance
          .collection("users")
          .where("id", isEqualTo: firebaseUser.uid)
          .getDocuments();

      final List<DocumentSnapshot> documentSnapshots = resultQuery.documents;

      if (documentSnapshots.length == 0) {
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          "nickname": firebaseUser.displayName,
          "photourl": firebaseUser.photoUrl,
          "id": firebaseUser.uid,
          "age": "18",
          "aboutMe": "Doing Great",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "chattingWith": null,
        });

        currentuser = firebaseUser;
        await preferences.setString("id", currentuser.uid);
        await preferences.setString("photourl", currentuser.photoUrl);
        await preferences.setString("nickname", currentuser.displayName);
        await preferences.setString("aboutMe", "Doing Great");
      } else {
        currentuser = firebaseUser;
        await preferences.setString("id", documentSnapshots[0]["id"]);
        await preferences.setString(
            "photourl", documentSnapshots[0]["photourl"]);
        await preferences.setString(
            "nickname", documentSnapshots[0]["nickname"]);
        await preferences.setString("aboutMe", documentSnapshots[0]["aboutMe"]);
      }

      Fluttertoast.showToast(msg: "Congratulations , Sign In Successful !!");
      this.setState(() {
        isLoading = false;
      });

      this.setState(() {
        updatePageState(1);
      });
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => ConversationPageSlide(
      //             currentUserId: preferences.getString("id"))));
    } else {
      Fluttertoast.showToast(msg: "Try Again , Sign In Failed");
      this.setState(() {
        isLoading = false;
      });
    }
  }
}
