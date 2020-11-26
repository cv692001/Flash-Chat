import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RegisterPage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingScreen extends StatefulWidget {
  final String currentUser;

  SettingScreen({
    Key key,
    this.currentUser,
  });
  @override
  _SettingScreenState createState() =>
      _SettingScreenState(currentUser: currentUser);
}

class _SettingScreenState extends State<SettingScreen> {
  SharedPreferences preferences;

  _SettingScreenState({
    Key key,
    this.currentUser,
  });

  final String currentUser;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => RegisterPage()),
        (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();

    readDataFromLocal();
  }

  TextEditingController nicknameTextEditingController = TextEditingController();
  TextEditingController aboutMeTextEditingController = TextEditingController();

  String id = "";
  String nickname = "";
  String aboutMe = "";
  String photourl = "";
  File imageFileAvatar;
  bool isLoading = false;
  final FocusNode nicknameFocusNide = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();

  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();

    id = preferences.getString("id");
    nickname = preferences.getString("nickname");
    aboutMe = preferences.getString("aboutMe");
    photourl = preferences.getString("photourl");

    nicknameTextEditingController = TextEditingController(
      text: nickname,
    );

    aboutMeTextEditingController = TextEditingController(
      text: aboutMe,
    );

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
            await preferences.setString("photourl", photourl);

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

  void updateData() {
    nicknameFocusNide.unfocus();
    aboutMeFocusNode.unfocus();

    setState(() {
      isLoading = false;
    });

    Firestore.instance.collection("users").document(id).updateData({
      "photourl": photourl,
      "aboutMe": aboutMe,
      "nickname": nickname,
    }).then((data) async {
      await preferences.setString("photourl", photourl);
      await preferences.setString("nickname", nickname);
      await preferences.setString("aboutMe", aboutMe);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Updated Sucessfully");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.lightBlue,
        title: Text(
          "Account Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  child: Center(
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
                            Icons.camera_alt,
                            size: 100,
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
                      ],
                    ),
                  ),
                  width: double.infinity,
                  margin: EdgeInsets.all(20.0),
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(1.0),
                      child: isLoading ? circularProgress() : Container(),
                    ),
                    Container(
                      child: Text(
                        "Profile Name:",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 10, top: 10, bottom: 5.0),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: Colors.lightBlueAccent,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "e.g. Chirag Vaishnav",
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          controller: nicknameTextEditingController,
                          onChanged: (value) {
                            nickname = value;
                          },
                          focusNode: nicknameFocusNide,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                    Container(
                      child: Text(
                        "About Me:",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 10, top: 10, bottom: 5.0),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: Colors.lightBlueAccent,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "e.g. Bio",
                            contentPadding: EdgeInsets.all(5.0),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          controller: aboutMeTextEditingController,
                          onChanged: (value) {
                            aboutMe = value;
                          },
                          focusNode: aboutMeFocusNode,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30.0, right: 30.0),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                Container(
                  child: FlatButton(
                    onPressed: () {
                      print("jkl");
                      updateData();
                    },
                    child: Text(
                      "Update",
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    color: Colors.lightBlueAccent,
                    highlightColor: Colors.grey,
                    splashColor: Colors.transparent,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(30, 10, 30.0, 10.0),
                  ),
                  margin: EdgeInsets.only(top: 50.0, bottom: 1.0),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 50, right: 50),
                  child: RaisedButton(
                    color: Colors.red,
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                    ),
                    onPressed: () {
                      logoutUser();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
