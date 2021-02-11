import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/pages/RegisterPage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash_chat/widgets/ChatAppBar.dart';
import 'package:flash_chat/config/style.dart';
import 'package:intl/intl.dart';
import 'package:flash_chat/config/color_palette.dart';
import 'fullImageWidget.dart';
import 'package:flash_chat/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class chat extends StatelessWidget {
  final String recieverAbout;
  final String recieverId;
  final String recieverAvatar;
  final String recieverName;
  final String recieverAge;
  final bool isLiked;

  chat({
    Key key,
    this.recieverAbout,
    @required this.recieverAvatar,
    @required this.recieverId,
    @required this.recieverName,
    @required this.recieverAge,
    @required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: Material(
            child: Container(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlue[100],
                  borderRadius: new BorderRadius.vertical(
                      bottom: new Radius.elliptical(
                          MediaQuery.of(context).size.width, 20.0)),
                  boxShadow: kElevationToShadow[50],
                ),
                //color: Palette.primaryBackgroundColor,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (value) => UserProfileScreen(
                                  recieverAbout: recieverAbout,
                                  recieverAvatar: recieverAvatar,
                                  recieverId: recieverId,
                                  recieverName: recieverName,
                                  recieverAge: recieverAge,
                                )));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(flex: 2, child: Container()),
                      Expanded(
                        flex: 7,
                        child: Center(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 6,
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  child: Container(
                                    padding: EdgeInsets.only(top: 25),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                            recieverName[0].toUpperCase() +
                                                recieverName.substring(1),
                                            // recieverName.toUpperCas5e(),
                                            textAlign: TextAlign.end,
                                            style: Styles.textHeading),
                                        Text(



                                            (recieverAbout[0].toUpperCase() +
                                                recieverAbout.substring(1)).length <= 15 ?  (recieverAbout[0].toUpperCase() +
                                                recieverAbout.substring(1)) :
                                            (recieverAbout[0].toUpperCase() +
                                                recieverAbout.substring(1)).replaceRange(15,  (recieverAbout[0].toUpperCase() +
                                                recieverAbout.substring(1)).length, '...'),
                                            textAlign: TextAlign.end,
                                            style: Styles.subHeading)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundImage:
                                    CachedNetworkImageProvider(recieverAvatar),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body:
            ChatScreen(recieverAvatar: recieverAvatar, recieverId: recieverId));
  }
}

class ChatScreen extends StatefulWidget {
  final String recieverAvatar;
  final String recieverId;
  final bool isLiked;

  ChatScreen({
    Key key,
    @required this.recieverAvatar,
    @required this.recieverId,
    @required this.isLiked,
  }) : super(key: key);
  @override
  _ChatScreenState createState() =>
      _ChatScreenState(recieverAvatar: recieverAvatar, recieverId: recieverId);
}

class _ChatScreenState extends State<ChatScreen> {
  final String recieverAvatar;
  final String recieverId;
  final bool isLiked;

  _ChatScreenState({
    Key key,
    @required this.recieverAvatar,
    @required this.recieverId,
    @required this.isLiked,
  });

  readLocal() async {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id") ?? "";

    if (id.hashCode <= recieverId.hashCode) {
      chatId = '$id-$recieverId';
    } else {
      chatId = '$recieverId-$id';
    }

    Firestore.instance
        .collection("users")
        .document(id)
        .updateData({'chattingWith': recieverId});

    setState(() {});
  }

  TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  bool isDisplayStickers;
  bool isLoading;
  ScrollController listScrollController = ScrollController();

  File imageFile;
  String imageUrl;

  String chatId;
  SharedPreferences preferences;
  String id;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    focusNode.addListener(onFocusChange);

    isDisplayStickers = false;
    isLoading = false;
    chatId = null;

    readLocal();
  }

  onFocusChange() {
    //hide stickers whenever keypad appears
    if (focusNode.hasFocus) {
      setState(() {
        isDisplayStickers = false;
      });
    }
  }

  void onSendMessage(String contentMsg, int type) {
    //type 0 message
    //type 2 gif
    //type 1 images

    if (contentMsg != "") {
      textEditingController.clear();

      var docRef = Firestore.instance
          .collection("messages")
          .document(chatId)
          .collection(chatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          docRef,
          {
            //sender of the message
            "idFrom": id,
            //reciever of the message
            "idTo": recieverId,
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
            "content": contentMsg,
            "type": type,
          },
        );
      });

      listScrollController.animateTo(0.0,
          duration: Duration(microseconds: 100), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: "Empty message Can't be send");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      createListMessagaes(),
                      (isDisplayStickers ? createStickers() : Container()),
                      createInput(),
                    ],
                  ),
                ),
              ],
            ),
            createLoading(),
          ],
        ),
        onWillPop: onBackPress);
  }

  createLoading() {
    return Positioned(child: isLoading ? circularProgress() : Container());
  }

  Future<bool> onBackPress() {
    if (isDisplayStickers) {
      setState(() {
        isDisplayStickers = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  createStickers() {
    print("yes");
    return Container(
      child: Column(
        children: <Widget>[
          //first Row
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/BMPSCLh0SQxvGQ81uP/giphy.gif",
                    2),
                child: Image.network(
                  'https://media.giphy.com/media/BMPSCLh0SQxvGQ81uP/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/RfXmmUJf9G26Za3dLB/giphy.gif",
                    2),
                child: Image.network(
                  'https://media.giphy.com/media/RfXmmUJf9G26Za3dLB/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/5adFM0HmVdP8s/giphy.gif", 2),
                child: Image.network(
                  'https://media.giphy.com/media/5adFM0HmVdP8s/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/pVVKJJuEQre3219fLh/giphy.gif",
                    2),
                child: Image.network(
                  'https://media.giphy.com/media/pVVKJJuEQre3219fLh/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/X7sdcJ1kA5u41SWEqa/giphy.gif",
                    2),
                child: Image.network(
                  'https://media.giphy.com/media/X7sdcJ1kA5u41SWEqa/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/3FjuotitkhOffmPamc/giphy.gif",
                    2),
                child: Image.network(
                  'https://media.giphy.com/media/3FjuotitkhOffmPamc/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),

          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/z1RIYMGmxZjwc/giphy.gif", 2),
                child: Image.network(
                  'https://media.giphy.com/media/z1RIYMGmxZjwc/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/LThD8JVDd19hm/giphy.gif", 2),
                child: Image.network(
                  'https://media.giphy.com/media/LThD8JVDd19hm/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage(
                    "https://media.giphy.com/media/xUOxf9qA9iupNWfT3y/giphy.gif",
                    2),
                child: Image.network(
                  'https://media.giphy.com/media/xUOxf9qA9iupNWfT3y/giphy.gif',
                  loadingBuilder: (context, child, progress) {
                    return progress == null
                        ? child
                        : CircularProgressIndicator();
                  },
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  void getSticker() {
    focusNode.unfocus();

    setState(() {
      isDisplayStickers = !isDisplayStickers;
    });
  }

  var listMessage;

  createListMessagaes() {
    return Flexible(
        child: chatId == null
            ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                ),
              )
            : StreamBuilder(
                stream: Firestore.instance
                    .collection('messages')
                    .document(chatId)
                    .collection(chatId)
                    .orderBy("timestamp", descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshots) {
                  if (!snapshots.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.lightBlueAccent),
                      ),
                    );
                  } else {
                    listMessage = snapshots.data.documents;

                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          createItem(index, snapshots.data.documents[index]),
                      itemCount: snapshots.data.documents.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  }
                }));
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idFrom"] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]["idFrom"] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  createItem(int index, DocumentSnapshot document) {
    if (document["idFrom"] == id) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          document['type'] == 0
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Material(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                    elevation: 5,
                    color: Palette.selfMessageBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Text(
                        document['content'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                )
              : document['type'] == 1
                  ? Container(
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullPhoto(
                                        url: document['content'],
                                      )));
                        },
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                    Colors.lightBlueAccent),
                              ),
                              width: 200,
                              height: 200,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                "images/img_not_available.jpeg",
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document['content'],
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
                  : Container(
                      child: Image.network(
                        document['content'],
                        loadingBuilder: (context, child, progress) {
                          return progress == null
                              ? child
                              : CircularProgressIndicator();
                        },
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
        ],
      );
    } else {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                  Colors.lightBlueAccent),
                            ),
                            width: 35,
                            height: 35,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: recieverAvatar,
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(
                        width: 35.0,
                      ),
                document['type'] == 0
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Material(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              elevation: 5,
                              color: Palette.otherMessageBackgroundColor,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Text(
                                  document['content'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : document['type'] == 1
                        ? Container(
                            child: FlatButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FullPhoto(
                                              url: document['content'],
                                            )));
                              },
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                          Colors.lightBlueAccent),
                                    ),
                                    width: 200,
                                    height: 200,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      "images/img_not_available.jpeg",
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document['content'],
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          )
                        : Container(
                            child: Image.network(
                              document['content'],
                              loadingBuilder: (context, child, progress) {
                                return progress == null
                                    ? child
                                    : CircularProgressIndicator();
                              },
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          )
              ],
            ),
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      "Last Seen :" +
                          DateFormat("dd MM yyyy - hh:mm:aa").format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(document['timestamp']))),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    margin: EdgeInsets.only(bottom: 5.0, left: 50.0, top: 0.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  createInput() {
    return Container(
        child: Row(
          children: <Widget>[
            Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 1.0),
                child: IconButton(
                    icon: Icon(
                      Icons.image,
                      color: Colors.lightBlueAccent,
                    ),
                    onPressed: () {
                      getImage();
                    }),
              ),
              color: Colors.white,
            ),
            Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 1.0),
                child: IconButton(
                    icon: Icon(
                      Icons.insert_emoticon,
                      color: Colors.lightBlueAccent,
                    ),
                    onPressed: () {
                      print("yes1");
                      getSticker();
                    }),
              ),
              color: Colors.white,
            ),
            Flexible(
                child: GestureDetector(
              onVerticalDragEnd: (details) {
                print('Dragged Down');
                if (details.primaryVelocity < 50) {
                  Navigator.pop(context);
                }
              },
              child: Container(
                child: TextField(
                  focusNode: focusNode,
                  controller: textEditingController,
                  decoration: InputDecoration(
                      hintText: "Write here..",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      )),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                  ),
                ),
              ),
            )),
            Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.lightBlueAccent,
                  ),
                  onPressed: () {
                    onSendMessage(textEditingController.text, 0);
                  },
                ),
              ),
            ),
          ],
        ),
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          )),
          color: Colors.white,
        ));
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      isLoading = true;
      uploadImageFile();
    }
  }

  Future uploadImageFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("Chat Images").child(fileName);

    StorageUploadTask storageUploadTask = storageReference.putFile(imageFile);

    StorageTaskSnapshot storageTaskSnapshot =
        await storageUploadTask.onComplete;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;

      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (error) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Error : " + error);
    });
  }
}

class UserProfileScreen extends StatefulWidget {
  final String recieverAbout;
  final String recieverId;
  final String recieverAvatar;
  final String recieverName;
  final String recieverAge;
  final bool isLiked;

  UserProfileScreen({
    Key key,
    this.recieverAbout,
    this.recieverAvatar,
    this.recieverId,
    this.recieverName,
    this.recieverAge,
    this.isLiked,
  }) : super(key: key);
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState(
        recieverAbout,
        recieverId,
        recieverAvatar,
        recieverName,
        recieverAge,
        isLiked,
      );
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final String recieverAbout;
  final String recieverId;
  final String recieverAvatar;
  final String recieverName;
  final String recieverAge;
   bool isLiked;

  _UserProfileScreenState(
    this.recieverAbout,
    this.recieverId,
    this.recieverAvatar,
    this.recieverName,
      this.recieverAge,
      this.isLiked,
  );

  int likes =0;

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    //likes = eachUser.likes;
    readDataFromLocal();

  }

  List a;

  SharedPreferences preferences;

  String id = "";

  void readDataFromLocal() async {

    preferences = await SharedPreferences.getInstance();

    id = preferences.getString("id");


    Firestore.instance.collection("users").document(recieverId).get().then((value){
      List a = value.data["likedby"];
      setState(() {
        likes = a.length;
        for(int i =0; i< a.length; i++){
          print(a[i]);
          print("Id $id");
          if(a[i] == id){
            print("I AM IN");
            isLiked = true;
            break;
          }else{
            isLiked = false;
          }
        }

      });
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
          "Flash Chat " ,
          style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
      ),











      body: Column(
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
                                        url: recieverAvatar,
                                      )));
                        },
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.lightBlueAccent),
                            ),
                            width: 150,
                            height: 150,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: recieverAvatar,

                          width: MediaQuery.of(context).size.width,
                          height: 350,
                          fit: BoxFit.cover,
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
                                Text(
                                  recieverName[0].toUpperCase() + recieverName.substring(1)  + ", ",

                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),

                                Text(
                                  recieverAge,

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
                            isLiked==true ?Icon(
                              Icons.favorite,
                              size: 35,
                              color: Colors.red.shade700,
                            ): Icon(
                              Icons.favorite,
                              color: Palette.greyColor,
                              size: 35,

                            ),
                            Text(" $likes Likes",
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
                  child: Text(


    (recieverAbout[0].toUpperCase() +
    recieverAbout.substring(1)),

                    textAlign: TextAlign.start,

                    style: TextStyle(

                        fontSize: 17,
                        color: Colors.orange,
                        fontStyle: FontStyle.italic

                    ),
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
