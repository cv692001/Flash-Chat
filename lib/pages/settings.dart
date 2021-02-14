import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/widgets/NavigationPillWIdget.dart';
import 'package:flash_chat/widgets/ProgressWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RegisterPage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
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

    editingMode = false;

    readDataFromLocal();
  }

  TextEditingController nicknameTextEditingController = TextEditingController();
  TextEditingController aboutMeTextEditingController = TextEditingController();
  TextEditingController ageTextEditingController = TextEditingController();

  String id = "";
  String age ="";
  String nickname = "";
  String aboutMe = "";
  String photourl = "";
  File imageFileAvatar;
  bool isLoading = false;
  final FocusNode nicknameFocusNide = FocusNode();
  final FocusNode ageFocusNode = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();
  int likes =0;

  void readDataFromLocal() async {
    preferences = await SharedPreferences.getInstance();



    id = preferences.getString("id");
    age = preferences.getString("age");
    nickname = preferences.getString("nickname");
    aboutMe = preferences.getString("aboutMe");
    photourl = preferences.getString("photourl");

    print(age);

    Firestore.instance.collection("users").document(id).get().then((value){
      List a = value.data["likedby"];
      setState(() {
        likes = a.length;


      });
    });

    nicknameTextEditingController = TextEditingController(
      text: nickname,
    );

    ageTextEditingController= TextEditingController(
      text: age,
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
    ageFocusNode.unfocus();


    setState(() {
      isLoading = false;
    });


    Firestore.instance.collection("users").document(id).updateData({
      "photourl": photourl,
      "aboutMe": aboutMe,
      "nickname": nickname,
      "age": age,
    }).then((data) async {
      await preferences.setString("photourl", photourl);
      await preferences.setString("nickname", nickname);
      await preferences.setString("aboutMe", aboutMe);
      await preferences.setString("age", age);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Updated Sucessfully");
    });
  }

  bool editingMode =false ;


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,

      body: Stack(


        children: [
          SingleChildScrollView(
            child: Column(

              children: <Widget>[
                SizedBox(
                  height: 87,
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 3,
                    right: 3,

                  ),
                  child: Stack(
                    children: [
                      Container(
                        height: 460,

                        child: Material(

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
                              children: <Widget>[
                                (imageFileAvatar == null)
                                    ? (photourl != null)
                                    ? Container(
                                  // display the old image
                                  child: Center(

                                    child: ClipRRect(

                                      child: CachedNetworkImage(
                                        placeholder: (context, url) => Container(
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.lightBlueAccent),
                                              strokeWidth: 1.0,

                                            ),
                                          ),


                                        ),
                                        imageUrl: photourl,
                                        height: 460,
                                        width: MediaQuery.of(context).size.width,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),


                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(0)),
                                  ),




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
                                    width: MediaQuery.of(context).size.width,
                                    height:460,
                                    fit: BoxFit.cover,
                                  ),

                                ),
                                Center(
                                  child:editingMode == true ? IconButton(
                                    icon: Icon(
                                      Icons.add_a_photo,
                                      size: 50,
                                      color: Colors.white54.withOpacity(0.6),
                                    ),
                                    onPressed: () {
                                      getImage();
                                    },
                                    padding: EdgeInsets.all(0.0),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.grey,
                                    iconSize: 200,
                                  ):Container()
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 396,
                        ),
                        child: Expanded(
                          child: Container(




                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)

                              ),
                            ),
                            child: Column(
                              children: [
                                Row(

                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                  children: [
                                    Column(

                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left:20, top: 20),
                                          child: Row(

                                            children: [
                                              editingMode == true ? SizedBox(
                                                width: 200,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(right: 20),
                                                  child: TextField(
                                                    decoration: InputDecoration(


                                                      labelStyle: GoogleFonts.quicksand(
                                                        textStyle: TextStyle(
                                                          fontSize: 30,

                                                          fontWeight: FontWeight.w500,
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),




                                                      hintText: "e.g. Chirag Vaishnav",
                                                      contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                                      hintStyle: GoogleFonts.quicksand(
                                                        textStyle: TextStyle(
                                                          fontSize: 15,

                                                          fontWeight: FontWeight.w500,

                                                        ),
                                                      )
                                                    ),
                                                    controller: nicknameTextEditingController,
                                                    onChanged: (value) {
                                                      nickname = value;
                                                    },
                                                    focusNode: nicknameFocusNide,
                                                  ),
                                                ),
                                              ):
                                              Text(


                                                (nickname).length <= 15 ?  (nickname) :
                                                (nickname).replaceRange(15,  (nickname).length, '...') ,

                                                textAlign: TextAlign.start,

                                                style: GoogleFonts.quicksand(
                                                  textStyle: TextStyle(
                                                    fontSize: 22,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,

                                                  ),
                                                )
                                              ),




                                              editingMode== true ? SizedBox(
                                                width: 50,
                                                child: TextField(
                                                  textAlign: TextAlign.center,
                                                  decoration: InputDecoration(
                                                    focusColor: Colors.black,


                                                    labelStyle:GoogleFonts.quicksand(
                                                      textStyle:  TextStyle(
                                                        fontSize: 25,

                                                        fontWeight: FontWeight.w500,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),

                                                    hintText: "e.g. 19",
                                                    contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                                    hintStyle: TextStyle(
                                                      fontSize: 15,

                                                      fontWeight: FontWeight.w500,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                  controller: ageTextEditingController,
                                                  onChanged: (value) {
                                                    age = value;
                                                  },
                                                  focusNode: ageFocusNode,
                                                ),
                                              )
                                                  : Text(
                                                ", "+ age,

                                                style: GoogleFonts.quicksand(
                                                  textStyle: TextStyle(
                                                    fontSize: 22,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,
                                                    letterSpacing: 1
                                                  ),
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
                                          Text("Likes: $likes",
                                            style: GoogleFonts.quicksand(
                                              textStyle: TextStyle(
                                                color: Colors.deepOrange,
                                              ),
                                            ),
                                            textAlign: TextAlign.right,
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.black54,
                                  thickness: 0.2,

                                ),

                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                      top: 20,
                                      bottom: 80
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    //crossAxisAlignment: CrossAxisAlignment.end,
                                    //mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        constraints: new BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width - 84),
                                        child:editingMode == true ? TextField(
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          decoration: InputDecoration(


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
                                        ) :
                                        Text(


                                          aboutMe,

                                          textAlign: TextAlign.start,

                                          style:GoogleFonts.quicksand(
                                            textStyle:  TextStyle(

                                                fontSize: 17,
                                                color: Colors.black,


                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                FlatButton(
                                  textColor: Colors.black,
                                  onPressed: () {
                                    logoutUser();
                                  },
                                  child: Text("  Logout  ",
                                    style: GoogleFonts.quicksand(
                                      textStyle: TextStyle(
                                        fontSize: 17,
                                      ),
                                    ) ,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.blue,
                                        width: 1,
                                        style: BorderStyle.solid
                                    ),
                                    borderRadius: new BorderRadius.circular(15),

                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),



              ],
            ),
          ),


          Positioned(
            right: 10,
            top: 100,
            child: FlatButton(
              color: Colors.white,
              textColor: Colors.black,
              onPressed: () {
                setState(() {
                  if(editingMode == true){
                    updateData();
                  }
                  editingMode = !editingMode;
                });

              },
              child: editingMode == true ?Row(
                children: [
                  Icon(Icons.done),
                  Text(" Update",
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  ),
                ],
              ) : Row(
                children: [
                  Icon(
                    Icons.edit,
                    size: 20,
                  ),
                  Text(" Edit",
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                      fontSize: 17,
                    ),
                  ),),
                ],
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Colors.blue,
                    width: 1,
                    style: BorderStyle.solid
                ),
                borderRadius: new BorderRadius.circular(15),

              ),
            ),
          ),
        ],

      ),
    );
  }
}
