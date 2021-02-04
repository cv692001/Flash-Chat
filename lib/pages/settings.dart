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
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
        await ImagePicker.pickImage(source: ImageSource.gallery,
          imageQuality: 10,
        );

    final filePath = newImageFile.absolute.path;

    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    File compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 25);



    if (compressedImage != null) {
      setState(() {
        this.imageFileAvatar = compressedImage;
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
        leading: Container(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(35),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[100],
        title: Text(
          "Account Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
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
                          color: Colors.black54,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 10, top: 10, bottom: 0.0),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: Colors.lightBlueAccent,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.black54,
                              size: 25.0,
                            ),
                            suffixIcon: Icon(
                              Icons.edit,
                              color: Colors.black54,
                            ),
                            hintText: "e.g. Chirag Vaishnav",
                            contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                      margin:
                          EdgeInsets.only(left: 30.0, right: 30.0, bottom: 10),
                    ),
                    Container(
                      child: Text(
                        "About Me:",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 10, top: 10, bottom: 0.0),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: Colors.lightBlueAccent,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.info_outline,
                              color: Colors.black54,
                              size: 25.0,
                            ),
                            suffixIcon: Icon(
                              Icons.edit,
                              color: Colors.black54,
                            ),
                            hintText: "e.g. Bio",
                            contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: Colors.blue,
                              width: 1,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(50)),
                      clipBehavior: Clip.hardEdge,
                      onPressed: () {
                        updateData();
                      },
                      child: Text(
                        "  Update  ",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16.0,
                        ),
                      ),
                      color: Colors.lightBlueAccent,
                      highlightColor: Colors.grey,
                      splashColor: Colors.transparent,
                      textColor: Colors.white,
                    ),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: Colors.blue,
                              width: 1,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(50)),
                      color: Colors.red,
                      child: Text(
                        "  Logout  ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                      onPressed: () {
                        logoutUser();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
