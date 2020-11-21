import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash_chat/widgets/ChatAppBar.dart';
import 'package:flash_chat/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class chat extends StatelessWidget {
  final String recieverId;
  final String recieverAvatar;
  final String recieverName;

  chat({
    Key key,
    @required this.recieverAvatar,
    @required this.recieverId,
    @required this.recieverName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(recieverAvatar),
            ),
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          recieverName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(recieverAvatar: recieverAvatar, recieverId: recieverId),
    );
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
                createListMessagaes(),
                (isDisplayStickers ? createStickers() : Container()),
                createInput(),
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
                onPressed: () => onSendMessage("mimi1", 2),
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
                onPressed: () => onSendMessage("mimi1", 2),
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
                onPressed: () => onSendMessage("mimi1", 2),
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
                onPressed: () => onSendMessage("mimi1", 2),
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
                onPressed: () => onSendMessage("mimi1", 2),
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
                onPressed: () => onSendMessage("mimi1", 2),
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
                onPressed: () => onSendMessage("mimi1", 2),
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
                onPressed: () => onSendMessage("mimi1", 2),
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
                onPressed: () => onSendMessage("mimi1", 2),
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
                      //  itemBuilder: (context, index) {
                      //      createItam(index , snapshots , data , documents[index] );

                      //    },
                      itemCount: snapshots.data.documents.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  }
                }));
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
            ),
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
