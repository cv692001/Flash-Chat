import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RegisterPage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'fullImageWidget.dart';

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
  int age = 18;
  File imageFileAvatar;
  bool isLoading = false;
  final FocusNode nicknameFocusNide = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();

  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();

    id = preferences.getString("id");
    nickname = preferences.getString("nickname");
    aboutMe = preferences.getString("aboutMe");
    age = preferences.getInt("age");
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
    imageQuality: 30
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
        quality: 40);




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
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);

          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.deepOrange,

          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(5),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.white,
        title: Text(
          "Flash Chat",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.only(
                left: 3,
                right: 3,

              ),
              child: Container(

                height: 430,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.orange,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],

                ),

                child: Column(
                  children: [
                    Container(
                      height: 350,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(80),
                        ),
                        boxShadow: [

                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Material(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(80),
                        ),

                        clipBehavior: Clip.hardEdge,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FullPhoto(
                                      url: photourl,
                                    )));
                          },
                          child: Stack(

                            children: [

                              imageFileAvatar == null ?
                              (photourl!= null) ?
                              Material(
                                child: CachedNetworkImage(
                                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                                      Center(child: CircularProgressIndicator(value: downloadProgress.progress,
                                        strokeWidth: 1.0,

                                      )),
                                  imageUrl: photourl,

                                  width: MediaQuery.of(context).size.width,
                                  height: 350,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Icon(
                                Icons.account_circle,
                                size: 90,
                                color: Colors.grey,
                              )
                                  : Material(
                                child: Image.file(
                                  imageFileAvatar,
                                  width: MediaQuery.of(context).size.width,
                                  height: 350,
                                  fit: BoxFit.cover,
                                ),

                                clipBehavior: Clip.hardEdge,
                              ),
                              Center(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.camera_alt,
                                    size: 100,
                                    color: Colors.white54.withOpacity(0.5),
                                  ),
                                  onPressed: () {
                                    getImage();
                                  },
                                  padding: EdgeInsets.all(0.0),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.grey,
                                  iconSize: 200,
                                ),
                              ),

                            ],

                          ),
                        ),
                      ),
                    ),
                    Row(

                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Column(

                          children: [
                            Padding(
                              padding: EdgeInsets.only(left:20, top: 20),
                              child: Row(

                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: TextField(
                                      decoration: InputDecoration(

                                        suffixIcon: Icon(
                                          Icons.edit,
                                          color: Colors.orange,
                                        ),
                                        labelStyle: TextStyle(
                                          fontSize: 30,
                                          color: Colors.deepOrange,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        
                                        hintText: "e.g. Chirag Vaishnav",
                                        contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                        hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.deepOrange,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      controller: nicknameTextEditingController,
                                      onChanged: (value) {
                                        nickname = value;
                                      },
                                      focusNode: nicknameFocusNide,
                                    ),
                                  ),
                                  Text(
                                      " , ",

                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),

                                  Text(
                                    "Age",

                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.deepOrange,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),

                                ],
                              ),

                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 30,
                            top: 10,
                          ),
                          child: Column(
                            children: [
                             Icon(
                                Icons.favorite,
                                size: 35,
                                color: Colors.red.shade700,
                              ),
                              Text(" 10 Likes",
                                style: TextStyle(
                                  color: Colors.deepOrange,
                                ),
                                textAlign: TextAlign.right,
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 40,
                left: 20,
                right: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(

                    "About",
                    textAlign: TextAlign.start,
                    style: TextStyle(

                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: Colors.deepOrange,
                        fontStyle: FontStyle.italic

                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                //crossAxisAlignment: CrossAxisAlignment.end,
                //mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    constraints: new BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 84),
                    child: TextField(
                      decoration: InputDecoration(
                       d
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
