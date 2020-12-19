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

  chat({
    Key key,
    this.recieverAbout,
    @required this.recieverAvatar,
    @required this.recieverId,
    @required this.recieverName,
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
                                            recieverAbout[0].toUpperCase() +
                                                recieverAbout.substring(1),
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

  ChatScreen({
    Key key,
    @required this.recieverAvatar,
    @required this.recieverId,
  }) : super(key: key);
  @override
  _ChatScreenState createState() =>
      _ChatScreenState(recieverAvatar: recieverAvatar, recieverId: recieverId);
}

class _ChatScreenState extends State<ChatScreen> {
  final String recieverAvatar;
  final String recieverId;

  _ChatScreenState({
    Key key,
    @required this.recieverAvatar,
    @required this.recieverId,
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

  UserProfileScreen({
    Key key,
    this.recieverAbout,
    this.recieverAvatar,
    this.recieverId,
    this.recieverName,
  }) : super(key: key);
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState(
        recieverAbout,
        recieverId,
        recieverAvatar,
        recieverName,
      );
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final String recieverAbout;
  final String recieverId;
  final String recieverAvatar;
  final String recieverName;

  _UserProfileScreenState(
    this.recieverAbout,
    this.recieverId,
    this.recieverAvatar,
    this.recieverName,
  );

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
          recieverName[0].toUpperCase() +
              recieverName.substring(1) +
              "s Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Center(
            child: Material(
              borderRadius: BorderRadius.all(
                Radius.circular(18.0),
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
                    width: 170,
                    height: 170,
                    padding: EdgeInsets.all(10.0),
                  ),
                  imageUrl: recieverAvatar,
                  width: 170,
                  height: 170,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Column(
            children: <Widget>[
              Icon(Icons.person),
              SizedBox(
                width: 50,
              ),
              Text(
                recieverName[0].toUpperCase() + recieverName.substring(1),
                style: TextStyle(fontSize: 25, fontStyle: FontStyle.italic),
              ),
              SizedBox(
                height: 30,
              ),
              Icon(Icons.info_outline),
              SizedBox(
                height: 10,
              ),
              Text(
                recieverAbout[0].toUpperCase() + recieverAbout.substring(1),
                style: TextStyle(fontSize: 15, fontStyle: FontStyle.normal),
              ),
            ],
          )
        ],
      ),
    );
  }
}
